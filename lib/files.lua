--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Example Files

]]--

local lib = beduino.lib
local io  = beduino.io

local iom_c = [[
func read(port, cmnd) {
  output(port, cmnd);
  return input(port); 
}

func send_cmnd(port, ident, add_data, resp) {
  system(SEND_CMND1, port, ident);
  system(SEND_CMND2, port, add_data);
  system(SEND_CMND3, port, resp);
}
]]

local comm_c = [[
const SEND_MSG = 1;
const RECV_MSG = 2;

static var buff[64];

func send_msg(dst_addr, ptr) {
  return system(SEND_MSG, dst_addr, ptr);
}

func recv_msg(ptr) {
  return system(RECV_MSG, ptr);
}
]]

local example1_asm = [[
; Read button on input #1 and
; control demo lamp on output #1.

  move A, #00  ; color value in A

loop:
  nop          ; 100 ms delay
  nop          ; 100 ms delay
  in   B, #1   ; read switch value
  bze  B, loop
  and  A, #$3F ; values from 1 to 64
  add  A, #01
  out  #01, A  ; output color value
  jump loop
]]

local example1_c = [[
// Read button on input #1 and
// control demo lamp on output #1.

static var idx = 0;

func init() {
  system(0, 'In');
  system(0, 'it');
}

func loop() {
  if(input(1) == 1) {
    output(1, idx);
    idx = (idx + 1) % 64;
  } else {
    output(1, 0);
  }
}
]]

local example2_c = [[
// Output some characters on the
// programmer status line (system #0).

var max = 32;

func get_char(i) {
  return 0x40 + i;
}

func main() {
  var i;

  for(i = 0; i < max; i++) {
    system(0, get_char(i));
  }
}
]]

local example3_c = [[
// Example with inline assembler

func main() {
  var idx = 0;

  while(1){
    if(input(1) == 1) {
      output(1, idx);
      //idx = (idx + 1) % 64;
      _asm_{
        add [SP+0], #1
        mod [SP+0], #64
      }
    } else {
      output(1, 0);
    }
    sleep(2);
  }
}

]]

local example4_c = [[
// Show the use of library functions

import "stdio.asm"
import "mem.asm"

var arr1[4] = {1, 2, 3, 4};
var arr2[4];
var str[] = "Hello world!";


func main() {
  var i;

  memcpy(arr2, arr1, 4);
  for(i = 0; i < 4; i++) {
    putnum(arr2[i]);
  }

  putchar('  ');
  putstr(str);
  putchar('  ');
  puthex(0x321);

  return;
}
]]

function beduino.lib.add_ro_files(prog_pos)
	vm16.add_ro_file(prog_pos, "command.c",    lib.get_command_file())
	vm16.add_ro_file(prog_pos, "example1.c",   example1_c)
	vm16.add_ro_file(prog_pos, "example2.c",   example2_c)
	vm16.add_ro_file(prog_pos, "example3.c",   example3_c)
	vm16.add_ro_file(prog_pos, "example4.c",   example4_c)
	vm16.add_ro_file(prog_pos, "example1.asm", example1_asm)
end
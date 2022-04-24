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

if minetest.global_exists("techage") then

local iom_c = [[
func event() {
  var ptr = 2;
  var res = *ptr;
  *ptr = 0; 
  return res;
}

func read(port, cmnd) {
  output(port, cmnd);
  return input(port); 
}

func send_cmnd(address, ident, add_data) {
  system(0x100, address, ident, add_data);
}

func request_data(address, ident, add_data, resp) {
  system(0x101, address, resp);
  system(0x102, address, ident, add_data);
}
]]
vm16.register_ro_file("beduino", "ta_iom.c", iom_c)
vm16.register_ro_file("beduino", "ta_cmnd.c", lib.get_command_file())

elseif minetest.global_exists("tubelib") then

local iom_c = [[
func event() {
  var ptr = 2;
  var res = *ptr;
  *ptr = 0; 
  return res;
}

func read(port, cmnd) {
  output(port, cmnd);
  return input(port); 
}

func send_cmnd(address, ident, add_data) {
  system(0x120, address, ident, add_data);
}

func request_data(address, ident, add_data, resp) {
  system(0x121, address, resp);
  system(0x122, address, ident, add_data);
}
]]
vm16.register_ro_file("beduino", "tp_iom.c", iom_c)
vm16.register_ro_file("beduino", "tp_cmnd.c", lib.get_command_file())

end

local stdlib_asm = [[
;===================================
; stdlib v1.0
; - itoa(c, str)
; - itoha(c, str)
;===================================

global itoa
global itoha

  .code

;===================================
; [01] itoa(val, str)
; val: [SP+2]
; str: [SP+1]
;===================================
itoa:
  move A, [SP+2]
  move X, [SP+1]  
  move D, X      ; return val
  push #0        ; end-of-string

loop01:
  move B, A
  div  B, #10    ; rest in B
  move C, A
  mod  C, #10    ; digit in C
  add  C, #48
  push C         ; store on stack
  move A, B
  bnze A, loop01 ; next digit

output01:
  pop  B
  move [X]+, B
  bnze B, output01

exit01:
  move A, D
  ret

;===================================
; [02] itoha(val, str)
; val: [SP+2]
; str: [SP+1]
;===================================
itoha:
  move A, [SP+2]
  move X, [SP+1]  
  move D, X      ; return val
  push #0        ; end-of-string
  move C, #4     ; num digits

loop02:
  move B, A
  div  B, #$10   ; rest in B
  mod  A, #$10   ; digit in C
  sklt A, #10    ; C < 10 => jmp +2
  add  A, #7     ; A-F offset
  add  A, #48    ; 0-9 offset
  push A         ; store on stack
  move A, B
  dbnz C, loop02 ; next digit

output02:
  pop  B
  move [X]+, B
  bnze B, output02

exit02:
  move A, D
  ret
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
// Read button on input #0 and
// control demo lamp on output #1.

static var idx = 0;

func init() {
  system(0, 'In');
  system(0, 'it');
}

func loop() {
  if(input(0) == 1) {
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

vm16.register_ro_file("beduino", "stdio.asm",  vm16.libc.stdio_asm)
vm16.register_ro_file("beduino", "mem.asm",    vm16.libc.mem_asm)
vm16.register_ro_file("beduino", "string.asm", vm16.libc.string_asm)
vm16.register_ro_file("beduino", "math.asm",   vm16.libc.math_asm)
vm16.register_ro_file("beduino", "stdlib.asm", stdlib_asm)

vm16.register_ro_file("beduino", "example1.c",   example1_c)
vm16.register_ro_file("beduino", "example2.c",   example2_c)
vm16.register_ro_file("beduino", "example3.c",   example3_c)
vm16.register_ro_file("beduino", "example4.c",   example4_c)
vm16.register_ro_file("beduino", "example1.asm", example1_asm)

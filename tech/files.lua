--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Example Files

]]--

local lib = beduino.lib

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

func clear_screen(address) {
  system(0x103, address);
}

func append_line(address, text) {
  system(0x104, address, text);
}

func write_line(address, row, text) {
  system(0x105, address, row, text);
}
]]

local example1_c = [[
// Output some characters on the
// programmer status line (system #0).
import "ta_iom.c"

const MAX = 32;

func bin_to_ascii(i) {
  return 0x40 + i;
}

func init() {
  var i;

  for(i = 0; i < MAX; i++) {
    system(0, bin_to_ascii(i));
  }
}

func loop() {
  halt(); // abort execution
}
]]

local example2_c = [[
// Read button on input #0 and
// control signal tower on output #1.
import "ta_cmnd.c"
import "ta_iom.c"

static var idx = 0;

func init() {
  output(1, IO_OFF);
}

func loop() {
  if(input(0) == 1) {
    output(1, IO_GREEN + idx);
    idx = (idx + 1) % 3;
  } else {
    output(1, 0);
  }
}
]]

local example3_c = [[
// SmartLine Display/Player Detector example
// Connect detector to port #0 and display to port #1
// The detector event is used to read the detector input
// and output the player name to the display (row 3)

import "stdlib.asm"
import "ta_cmnd.c"
import "ta_iom.c"
import "string.asm"

static var buff[80];

func init() {
  clear_screen(1);
  write_line(1, 2, "Hello");
}

func loop() {
  var sts;

  if(event()) {
    if(input(0) == 1) {
      request_data(0, "name", "", buff);
      write_line(1, 3, buff);
    } else {
      write_line(1, 3, "~");
    }
  }
}
]]

local example4_c = [[
// Block/machine state example
// Output the block state on the signal tower
// Connect block to port #0 and tower to port #1
import "ta_cmnd.c"
import "ta_iom.c"

func init() {
  output(1, IO_OFF);
}

func loop() {
  var sts = read(0, IO_STATE);
  if(sts > IO_FAULT) {
    output(1, IO_OFF);
  }
  else if(sts > IO_STANDBY) {
    output(1, IO_RED);
  }
  else if(sts > IO_RUNNING) {
    output(1, IO_AMBER);
  }
  else {
    output(1, IO_GREEN);
  }
}
]]

vm16.register_ro_file("beduino", "ta_iom.c",   iom_c)
vm16.register_ro_file("beduino", "ta_cmnd.c",  lib.get_command_file())
vm16.register_ro_file("beduino", "example1.c", example1_c)
vm16.register_ro_file("beduino", "example2.c", example2_c)
vm16.register_ro_file("beduino", "example3.c", example3_c)
vm16.register_ro_file("beduino", "example4.c", example4_c)

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

func clear_screen(address) {
  system(0x123, address);
}

func append_line(address, text) {
  system(0x124, address, text);
}

func write_line(address, row, text) {
  system(0x125, address, row, text);
}
]]

local example1_c = [[
// Output some characters on the
// programmer status line (system #0).
import "tp_iom.c"

const MAX = 32;

func bin_to_ascii(i) {
  return 0x40 + i;
}

func init() {
  var i;

  for(i = 0; i < MAX; i++) {
    system(0, bin_to_ascii(i));
  }
}

func loop() {
  halt(); // abort execution
}
]]

local example2_c = [[
// Read button on input #0 and
// control signal tower on output #1.
import "tp_cmnd.c"
import "tp_iom.c"

static var idx = 0;

func init() {
  output(1, IO_OFF);
}

func loop() {
  if(input(0) == 1) {
    output(1, IO_GREEN + idx);
    idx = (idx + 1) % 3;
  } else {
    output(1, 0);
  }
}
]]

local example3_c = [[
// SmartLine Display/Player Detector example
// Connect detector to port #0 and display to port #1
// The detector event is used to read the detector input
// and output the player name to the display (row 5)

import "stdlib.asm"
import "tp_cmnd.c"
import "tp_iom.c"
import "string.asm"

static var buff[80];

func init() {
  clear_screen(1);
  write_line(1, 3, "Hello");
}

func loop() {
  var sts;

  if(event()) {
    if(input(0) == 1) {
      request_data(0, "name", "", buff);
      write_line(1, 5, buff);
    } else {
      write_line(1, 5, "~");
    }
  }
}
]]

local example4_c = [[
// Block/machine state example
// Output the block state on the signal tower
// Connect block to port #0 and tower to port #1
import "tp_cmnd.c"
import "tp_iom.c"

func init() {
  output(1, IO_OFF);
}

func loop() {
  var sts = read(0, IO_STATE);
  if(sts == IO_STOPPED) {
    output(1, IO_OFF);
  }
  else if(sts > IO_STANDBY) {
    output(1, IO_RED);
  }
  else if(sts > IO_RUNNING) {
    output(1, IO_AMBER);
  }
  else {
    output(1, IO_GREEN);
  }
}
]]

vm16.register_ro_file("beduino", "tp_iom.c",   iom_c)
vm16.register_ro_file("beduino", "tp_cmnd.c",  lib.get_command_file())
vm16.register_ro_file("beduino", "example1.c", example1_c)
vm16.register_ro_file("beduino", "example2.c", example2_c)
vm16.register_ro_file("beduino", "example3.c", example3_c)
vm16.register_ro_file("beduino", "example4.c", example4_c)

end

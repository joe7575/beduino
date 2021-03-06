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

// 'ident' and 'add_data' are strings
func send_tas_cmnd(port, ident, add_data) {
  system(0x100, port, ident, add_data);
}

// 'ident' and 'add_data' are strings, 'resp' is a pointer
func request_tas_data(port, ident, add_data, resp) {
  system(0x101, port, resp);
  system(0x102, port, ident, add_data);
}

// 'topic' is a number, 'payload' is an array or string
func send_cmnd(port, topic, payload) {
  system(0x106, port, topic, payload);
}

// 'topic' is a number, 'payload' and 'resp' is arr[8]
func request_data(port, topic, payload, resp) {
  system(0x101, port, resp);
  system(0x107, port, topic, payload);
}

func clear_screen(port) {
  system(0x103, port);
}

func append_line(port, text) {
  system(0x104, port, text);
}

func write_line(port, row, text) {
  system(0x105, port, row, text);
}
]]

local seg14_c = [[
import "ta_iom.c"

static var Chars[] = {
  0x2237, 0x0A8F, 0x0039, 0x088F, 0x2039, 0x2031, 0x023D, 0x2236,
  0x0889, 0x001E, 0x2530, 0x0038, 0x0176, 0x0476, 0x003F, 0x2233,
  0x043F, 0x2633, 0x222D, 0x0881, 0x003E, 0x1130, 0x1436, 0x1540,
  0x0940, 0x1109 };

static var Numbers[] = {
  0x003F, 0x0106, 0x221B, 0x020F, 0x2226, 0x222D, 0x223D, 0x0901,
  0x223F, 0x222F};

func seg14_putchar(port, c) {
  var i;
  
  if(c > 64) {
    i = c - 65;  // A - Z
    send_cmnd(port, 16, &Chars[i]); 
  } else {
    i = c - 48;  // 0 - 9 
    send_cmnd(port, 16, &Numbers[i]); 
  }
}

func seg14_putdigit(port, val) {
  send_cmnd(port, 16, &Numbers[val]); 
}
]]

local example1_c = [[
// Output some characters on the
// programmer status line (system #0).
import "stdlib.asm"
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
      request_tas_data(0, "name", "", buff);
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
vm16.register_ro_file("beduino", "seg14.c",    seg14_c)
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
import "stdlib.asm"
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
      request_tas_data(0, "name", "", buff);
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

--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Example Files

]]--

local lib = beduino.lib

local comm_c = [[
// Send a message via router.
func send_msg(address, msg) {
  system(0x040, address, msg);
}

// Receive a message via router.
// Function returns the sender address or 0.
func recv_msg(buff, size) {
  system(0x041, buff, size);
}
]]

local tx_demo_c = [[
// Comm Tx Demo
// Send cyclic text messages to router #2.
// Byte 0 of the buffer is the msg size.

import "stdlib.asm"
import "comm.c"

static var cnt = 0;
static var buff1[] = {2, '\b', '\0'};  // clear screen
static var buff2[] = {4, 'He', 'll', 'o', '\0'};
static var buff3[] = {5, 'Be', 'du', 'in', 'o!', '\0'};

func init() {
  send_msg(2, buff1);
}

func loop() {
  cnt++;
  if(cnt % 8 == 0) {
    send_msg(2, buff2);
  } else if(cnt % 8 == 4) {
    send_msg(2, buff3);
  }
}
]]

local rx_demo_c = [[
// Receive text messages via router.
// The messages are shown on the programmers terminal.

import "stdio.asm"
import "comm.c"

const MAX = 64;

static var buff[MAX];

func init() {
}

func loop() {
  var sts;
  var len;  
  var addr = recv_msg(buff, MAX);

  if(addr != 0) {
    len = buff[0];     // string length
    buff[len] = 0;     // to be safe
    putstr(buff + 1);  // output string
    putchar('\n');     // flush output stream
  }
}

]]


vm16.register_ro_file("beduino", "comm.c",    comm_c)
vm16.register_ro_file("beduino", "tx_demo.c", tx_demo_c)
vm16.register_ro_file("beduino", "rx_demo.c", rx_demo_c)

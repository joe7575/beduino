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
// Send a message via router
func send_msg(address, msg) {
  system(0x040, address, msg);
}

// Receive a message via router
// Function returns the sender address or 0
func recv_msg(buff, size) {
  system(0x041, buff, size);
}
]]

local tx_demo_c = [[
// Comm Tx Demo
// Send a msg "Hello!" (with msg size in buff[0]) 
// to router #2

import "stdlib.asm"
import "comm.c"

var buff[] = {4, 'He', 'll', 'o!', '\0'};

func init() {
  send_msg(2, buff);
}

func loop() {
  halt();
}
]]

local rx_demo_c = [[
// Receive a message via router
// The message is shown on the programmers status line

import "stdio.asm"
import "stdlib.asm"
import "comm.c"

const MAX = 64;

static var buff[MAX];

func init() {
}

func loop() {
  var sts;
  var addr = recv_msg(buff, MAX);

  if(addr != 0) {
    putstr(buff + 1);
    halt();
  }
}

]]


vm16.register_ro_file("beduino", "comm.c",    comm_c)
vm16.register_ro_file("beduino", "tx_demo.c", tx_demo_c)
vm16.register_ro_file("beduino", "rx_demo.c", rx_demo_c)

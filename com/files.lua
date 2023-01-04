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

// Send a message to the broker.
func publish_msg(address, topic, msg) {
  system(0x042, address, topic, msg);
}

// Read a message from the broker.
// Function returns 1 (success) or 0 (no msg).
func request_msg(address, topic, buff, size) {
  buff[0] = size;
  system(0x043, address, topic, buff);
}
]]

local tx_demo_c = [[
// Comm Transmit Demo
// Send a text messages to router #2.
// Word 0 of the messages buffer is the msg size.

import "sys/comm.c"

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
// Comm Receive Demo
// Receive a text messages via router.
// The message is shown on the programmers terminal.

import "sys/stdio.asm"
import "sys/comm.c"

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

local pub_demo_c = [[
// Broker Publish Demo
// Send messages to the broker #5.
// Word 0 of the messages array is the msg size.

import "sys/comm.c"

const MY_TOPIC = 1;

static var cnt = 0;
static var msg[] = {1, 0};

func init() {
}

func loop() {
  cnt++;
  if(cnt % 8 == 0) {
    msg[1]++;
    publish_msg(5, MY_TOPIC, msg);
  }
}
]]

local req_demo_c = [[
// Broker Request Demo
// Read a message from the broker.
// The messages are shown on the programmers terminal.

import "sys/stdio.asm"
import "sys/comm.c"

const MAX = 64;
const MY_TOPIC = 1;

static var cnt = 0;
static var buff[MAX];

func init() {
}

func loop() {
  var sts;

  cnt++;
  if(cnt % 8 == 0) {
    sts = request_msg(5, MY_TOPIC, buff, MAX);
    if(sts == 1) {
      putstr("MyTopic: ");
      putnum(buff[1]);
      putchar('\n');     // flush output stream
    }
  }
}
]]

vm16.register_ro_file("beduino", "sys/comm.c",     comm_c)
vm16.register_ro_file("beduino", "demo/tx_demo.c",  tx_demo_c)
vm16.register_ro_file("beduino", "demo/rx_demo.c",  rx_demo_c)
vm16.register_ro_file("beduino", "demo/pub_demo.c", pub_demo_c)
vm16.register_ro_file("beduino", "demo/req_demo.c", req_demo_c)

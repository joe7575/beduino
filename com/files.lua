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
// addr = destination address
// msg = [size, topic, data...]
// size = number of following words (1..63)
func send_msg(addr, msg) {
  system(0x040, addr, msg);
}

// Receive a message via router.
// buff = buffer for the message: [size, topic, data...]
// size = buffer size in words
// Function returns the sender address or 0.
func recv_msg(buff, size) {
  system(0x041, buff, size);
}

// Send a message to the broker.
// addr = broker address
// msg = [size, topic, data...]
// size = number of following words (1..63)
func publish_msg(addr, msg) {
  system(0x042, addr, msg);
}

// Read a message from the broker.
// addr = broker address
// topic = topic number
// buff = buffer for the message: [size, topic, data...]
// size = buffer size in words
// Function returns 1 (success) or 0 (no msg).
func fetch_msg(addr, topic, buff, size) {
  buff[0] = size;
  system(0x043, addr, topic, buff);
}

// Request to a message from the broker.
// Response is received asynchron via 'recv_msg'.
// addr = broker address
// topic = topic number
// Function returns 1 (success) or 0 (error).
func request_msg(addr, topic) {
  system(0x044, addr, topic);
}
]]

local tx_demo_c = [[
// Comm Send Demo
// Send a text messages to router #2.
// Word 0 of the messages buffer is the msg size.

import "sys/comm.c"

const STRING = 1; // topic
const DEST = 2;   // address

static var cnt = 0;
static var buff1[] = {3, STRING, '\b', '\0'};  // clear screen
static var buff2[] = {5, STRING, 'He', 'll', 'o', '\0'};
static var buff3[] = {6, STRING, 'Be', 'du', 'in', 'o!', '\0'};

func init() {
  send_msg(DEST, buff1);
}

func loop() {
  cnt++;
  if(cnt % 8 == 0) {
    send_msg(DEST, buff2);
  } else if(cnt % 8 == 4) {
    send_msg(DEST, buff3);
  }
}
]]

local rx_demo_c = [[
// Comm Receive Demo
// Receive a text messages via router.
// The message is shown on the programmers terminal.

import "sys/stdio.asm"
import "sys/comm.c"

const STRING = 1; // topic
const MAX = 64;

static var buff[MAX];

func init() {
  setstdout(1); // use terminal windows for stdout
}

func loop() {
  var sts;
  var len;
  var addr = recv_msg(buff, MAX);

  if(addr != 0) {
    len = buff[0];    // msg length
    buff[len] = 0;    // to be safe
    putstr(buff + 2); // output string
    putchar('\n');    // flush output stream
  }
}
]]

local pub_demo_c = [[
// Broker Publish Demo
// Send messages to the broker #5.
// Word 0 of the messages array is the msg size.
// Word 1 of the messages array is the topic.

import "sys/comm.c"

const TOPIC = 123;

static var cnt = 0;
static var msg[] = {2, TOPIC, 0};

func init() {
}

func loop() {
  cnt++;
  if(cnt % 8 == 0) {
    msg[2]++;
    publish_msg(5, msg);
  }
}
]]

local fec_demo_c = [[
// Broker Fetch Demo
// Fetch messages from the broker #5
// with immediate response,
// The messages are shown on the programmers terminal.

import "sys/stdio.asm"
import "sys/comm.c"

const MAX = 32;
const TOPIC = 123;

static var cnt = 0;
static var buff[MAX];

func init() {
  setstdout(1); // use terminal windows for stdout
}

func loop() {
  var sts;

  cnt++;
  if(cnt % 8 == 0) {
    sts = fetch_msg(5, TOPIC, buff, MAX);
    if(sts == 1) {
      putstr("Topic ");
      putnum(buff[1]);
      putstr(": ");
      putnum(buff[2]);
      putchar('\n'); // flush output stream
    }
  }
}
]]

local req_demo_c = [[
// Broker Request Demo
// Request messages from the broker #5.
// The response is provided after a broker message update.

import "sys/comm.c"
import "sys/stdio.asm"

const MAX = 32;
const TOPIC = 123;

static var buff[MAX];

func init() {
  setstdout(1); // use terminal windows for stdout
  request_msg(5, TOPIC);  // initial
}

func loop() {
  var addr = recv_msg(buff, MAX);

  if(addr != 0) {
    putstr("Topic ");
    putnum(buff[1]);
    putstr(": ");
    putnum(buff[2]);
    putchar('\n'); // flush output stream
    request_msg(5, TOPIC);  // again
  }
}
]]

vm16.register_ro_file("beduino", "sys/comm.c",     comm_c)
vm16.register_ro_file("beduino", "demo/tx_demo.c",  tx_demo_c)
vm16.register_ro_file("beduino", "demo/rx_demo.c",  rx_demo_c)
vm16.register_ro_file("beduino", "demo/pub_demo.c", pub_demo_c)
vm16.register_ro_file("beduino", "demo/req_demo.c", req_demo_c)
vm16.register_ro_file("beduino", "demo/fec_demo.c", fec_demo_c)

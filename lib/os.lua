--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	OS functions

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end

local lib = beduino.lib
local io  = beduino.io

local iom_c = [[
func read(port, cmnd) {
  output(port, cmnd);
  return input(port); 
}

func send_cmnd(address, ident, add_data, resp) {
  system(0x10, address, resp);
  system(0x11, ident, add_data);
}
]]


local function sys_resp_buff(pos, num, regA, regB)
	local mem = lib.get_mem(pos)
	local baseaddr = M(pos):get_int("baseaddr")
	local port = regA - baseaddr
	mem.dst_num = lib.get_node_number(pos, port)
	mem.resp_addr = regB
	return 0
end

local function sys_send_cmnd(pos, num, regA, regB)
	local mem = lib.get_mem(pos)
	local ident = vm16.read_ascii(pos, regA, 16)
	local add_data = vm16.read_ascii(pos, regB, 32)
	local own_num = M(pos):set_string("own_number")
	local resp = lib.send_single(own_num, mem.dst_num, ident, add_data)
	vm16.write_ascii(pos, mem.resp_addr, resp)
	return 0
end

io.register_SystemHandler(0x10, sys_resp_buff)
io.register_SystemHandler(0x11, sys_send_cmnd)


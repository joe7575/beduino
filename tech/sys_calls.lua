--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	System calls for techage/techpack

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end
local H = minetest.hash_node_position

local lib = beduino.lib
local tech = beduino.tech

local Port2Num = {}
local RespAddr = {}

function tech.register_system_address(cpu_pos, port, own_num, dest_num)
	--print("register_system_address", port, own_num, dest_num)
	assert(cpu_pos and port)
	local hash = H(cpu_pos)
	Port2Num[hash] = Port2Num[hash] or {}
	Port2Num[hash][port] = {own_num = own_num, dest_num = dest_num}
end

local function get_numbers(cpu_pos, port)
	assert(cpu_pos and port)
	local hash = H(cpu_pos)
	Port2Num[hash] = Port2Num[hash] or {}
	return Port2Num[hash][port].own_num, Port2Num[hash][port].dest_num
end

local function sys_resp_buff(cpu_pos, address, regA, regB, regC)
	--print("sys_resp_buff",  P2S(cpu_pos), address, regA, regB, regC)
	RespAddr[H(cpu_pos)] = regB
	return 0
end

local function sys_send_cmnd(cpu_pos, address, regA, regB, regC)
	--print("sys_send_cmnd", P2S(cpu_pos), address, regA, regB, regC)
	local own_num, dest_num = get_numbers(cpu_pos, regA)
	local ident = vm16.read_ascii(cpu_pos, regB, 16)
	local add_data = vm16.read_ascii(cpu_pos, regC, 32)
	tech.send_single(own_num, dest_num, ident, add_data)
	return 0
end

local function sys_request_data(cpu_pos, address, regA, regB, regC)
	--print("sys_request_data", P2S(cpu_pos), address, regA, regB, regC)
	local own_num, dest_num = get_numbers(cpu_pos, regA)
	local ident = vm16.read_ascii(cpu_pos, regB, 16)
	local add_data = vm16.read_ascii(cpu_pos, regC, 32)
	local resp = tech.send_single(own_num, dest_num, ident, add_data)
	local resp_addr = RespAddr[H(cpu_pos)]
	if resp_addr and resp_addr ~= 0 then
		vm16.write_ascii(cpu_pos, resp_addr, resp)
	end

	return 0
end

if minetest.global_exists("techage") then

	lib.register_SystemHandler(0x100, sys_send_cmnd)
	lib.register_SystemHandler(0x101, sys_resp_buff)
	lib.register_SystemHandler(0x102, sys_request_data)

elseif minetest.global_exists("tubelib") then

	lib.register_SystemHandler(0x120, sys_send_cmnd)
	lib.register_SystemHandler(0x121, sys_resp_buff)
	lib.register_SystemHandler(0x122, sys_request_data)

end


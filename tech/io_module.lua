--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	I/O Module as converter between 16 bit port numbers and techage node numbers

]]--

-- for lazy programmers
local M = minetest.get_meta
local H = minetest.hash_node_position
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end

local lib = beduino.lib
local tech = beduino.tech

local MP = minetest.get_modpath("beduino")
local fs = dofile(MP.."/tech/fs_lib.lua")

----------------------------------------------------------------------
-- Node definition
----------------------------------------------------------------------
fs.DESCRIPTION = "Beduino I/O Module"

local function on_init_io(pos, cpu_pos)
	M(pos):set_string("cpu_pos", P2S(cpu_pos))
	fs.store_port_number_relation(pos)
	return M(pos):get_int("baseaddr")
end

local function on_start_io(pos, cpu_pos)
	M(pos):set_string("cpu_pos", P2S(cpu_pos))
	fs.store_port_number_relation(pos)
end

minetest.register_node("beduino:io_module", {
	description = fs.DESCRIPTION,
	inventory_image = "beduino_iom_inventory.png",
	wield_image = "beduino_iom_inventory.png",
	tiles = {
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png^beduino_iom.png",
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/32, -6/32, 12/32,  6/32,  6/32, 16/32},
		},
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local own_num = tech.add_node(pos, "beduino:io_module")
		meta:set_string("node_number", own_num)
		meta:set_string("owner", placer:get_player_name())
		lib.infotext(meta, fs.DESCRIPTION)
		meta:set_string("formspec", fs.formspec_place(pos))
	end,
	after_dig_node = function(pos)
		local meta = M(pos)
		tech.reset_node_data(pos)
		tech.del_mem(pos)
	end,

	on_receive_fields = fs.on_receive_fields,
	on_init_io = on_init_io,
	on_start_io = on_start_io,
	on_rightclick = fs.on_rightclick,

	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	stack_max = 1,
})

beduino.register_io_nodes({"beduino:io_module"})
beduino.tech.register_node({"beduino:inp_module"}, {
	on_node_load = function(pos)
		fs.store_port_number_relation(pos)
	end,
})
----------------------------------------------------------------------
-- System calls
----------------------------------------------------------------------
local RespAddr = {}

local function sys_resp_buff(cpu_pos, address, regA, regB, regC)
	RespAddr[H(cpu_pos)] = regB
	return 1
end

local function sys_send_cmnd(cpu_pos, address, regA, regB, regC)
	local own_num, dest_num = tech.get_node_numbers(cpu_pos, regA)
	if own_num and dest_num then
		local topic = regB
		local payload
		if topic >= 64 then
			payload = vm16.read_ascii(cpu_pos, regC, 32)
		else
			payload = vm16.read_mem(cpu_pos, regC, 8)
		end
		techage.counting_add(M(cpu_pos):get_string("owner"), 1)
		return techage.beduino_send_cmnd(own_num, dest_num, topic, payload)
	end
	return 1
end

local function sys_request_data(cpu_pos, address, regA, regB, regC)
	local own_num, dest_num = tech.get_node_numbers(cpu_pos, regA)
	if own_num and dest_num then
		local topic = regB
		local payload = vm16.read_mem(cpu_pos, regC, 8)
		local sts, resp = techage.beduino_request_data(own_num, dest_num, topic, payload)
		local resp_addr = RespAddr[H(cpu_pos)]
		if sts == 0 and resp and resp_addr and resp_addr ~= 0 then
			if type(resp) == "table" then
				vm16.write_mem(cpu_pos, resp_addr, resp)
			else
				vm16.write_ascii_16(cpu_pos, resp_addr, resp .. "\0")
			end
		end
		return sts
	end
	return 1
end

local function sys_clear_screen(cpu_pos, address, regA, regB, regC)
	local own_num, dest_num = tech.get_node_numbers(cpu_pos, regA)
	if own_num and dest_num then
		tech.send_single(own_num, dest_num, "clear")
		return 1
	end
	return 0
end

local function sys_add_line(cpu_pos, address, regA, regB, regC)
	local own_num, dest_num = tech.get_node_numbers(cpu_pos, regA)
	if own_num and dest_num then
		local text = vm16.read_ascii(cpu_pos, regB, 64)
		if tech.tubelib then
			tech.send_single(own_num, dest_num, "text", text)
		else
			tech.send_single(own_num, dest_num, "add", text)
		end
		return 1
	end
	return 0
end

local function sys_write_line(cpu_pos, address, regA, regB, regC)
	local own_num, dest_num = tech.get_node_numbers(cpu_pos, regA)
	if own_num and dest_num then
		local row = regB
		local text = vm16.read_ascii(cpu_pos, regC, 64)
		if tech.tubelib then
			tech.send_single(own_num, dest_num, "row", {row = row, str = text})
		else
			local payload = safer_lua.Store()
			payload.set("row", row)
			payload.set("str", text)
			tech.send_single(own_num, dest_num, "set", payload)
		end
		return 1
	end
	return 0
end

lib.register_SystemHandler(0x101, sys_resp_buff)
lib.register_SystemHandler(0x103, sys_clear_screen)
lib.register_SystemHandler(0x104, sys_add_line)
lib.register_SystemHandler(0x105, sys_write_line)
lib.register_SystemHandler(0x106, sys_send_cmnd)
lib.register_SystemHandler(0x107, sys_request_data)

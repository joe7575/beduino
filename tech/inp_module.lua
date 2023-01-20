--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Input block to collect and pass on received techage commands

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
-- Event queue
----------------------------------------------------------------------
local Events = {}

local function set_event(cpu_pos, inp_port)
	local hash = H(cpu_pos)
	Events[hash] = Events[hash] or {}
	if #Events[hash] < 8 then
		table.insert(Events[hash], inp_port)
	end
end

local function get_event(cpu_pos)
	local hash = H(cpu_pos)
	Events[hash] = Events[hash] or {}
	if Events[hash] and #Events[hash] > 0 then
		return table.remove(Events[hash], 1)
	end
end

----------------------------------------------------------------------
-- Node definition
----------------------------------------------------------------------
fs.DESCRIPTION = "Beduino Input Module"

local function on_input(pos, address)
	local baseaddr = M(pos):get_int("baseaddr")
	--print("on_input", baseaddr, address)
	if baseaddr == address then
		local nvm = tech.get_nvm(pos)
		local resp = nvm.input_val
		nvm.input_val = nil
		return resp or 65535
	end
	return 65535
end

local function on_init_io(pos, cpu_pos)
	local meta = M(pos)
	meta:set_string("cpu_pos", P2S(cpu_pos))
	fs.store_port_number_relation(pos)
	local baseaddr = meta:get_int("baseaddr")
	for addr = baseaddr, baseaddr + 7 do
		beduino.register_input_address(pos, cpu_pos, addr, on_input)
	end
	return baseaddr
end

local function on_start_io(pos, cpu_pos)
	fs.store_port_number_relation(pos)
end

minetest.register_node("beduino:inp_module", {
	description = fs.DESCRIPTION,
	inventory_image = "beduino_inp_inventory.png",
	wield_image = "beduino_inp_inventory.png",
	tiles = {
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png^beduino_inp.png",
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
		local own_num = tech.add_node(pos, "beduino:inp_module")
		meta:set_string("node_number", own_num)
		meta:set_string("owner", placer:get_player_name())
		lib.infotext(meta, fs.DESCRIPTION)
		meta:set_string("formspec", fs.formspec_place(pos))
	end,
	after_dig_node = function(pos)
		local meta = M(pos)
		tech.reset_node_data(pos)
		local cpu_pos = S2P(meta:get_string("cpu_pos"))
		local baseaddr = meta:get_int("baseaddr")
		for addr = baseaddr, baseaddr + 7 do
			beduino.unregister_address(pos, cpu_pos, addr)
		end
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

beduino.register_io_nodes({"beduino:inp_module"})
beduino.tech.register_node({"beduino:inp_module"}, {
	on_recv_message = function(pos, src, topic, payload)
		if tech.tubelib then
			pos, src, topic = pos, topic, src
		end
		local nvm = tech.get_nvm(pos)
		if not nvm.input_val then
			nvm.input_val = tonumber(topic) or topic == "on" and 1 or 0
			local baseaddr = M(pos):get_int("baseaddr")
			local cpu_pos = S2P(M(pos):get_string("cpu_pos"))
			set_event(cpu_pos, baseaddr)
		end
	end,
	on_node_load = function(pos)
		fs.store_port_number_relation(pos)
	end,
})

----------------------------------------------------------------------
-- System calls
----------------------------------------------------------------------
local function sys_get_event(cpu_pos, address, regA, regB, regC)
	return get_event(cpu_pos) or 0xffff
end

lib.register_SystemHandler(0x108, sys_get_event)

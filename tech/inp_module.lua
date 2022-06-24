--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Input block

]]--

-- for lazy programmers
local M = minetest.get_meta
local H = minetest.hash_node_position
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end

local lib = beduino.lib
local tech = beduino.tech

local DESCRIPTION = "Beduino Input Module"

local BaseAddr2Idx = {[0]=1, [8]=2, [16]=3, [24]=4, [32]=5, [40]=6, [48]=7, [56]=8}

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

local function on_output(pos, address, value)
end

local function formspec_place(pos)
	local baseaddr = M(pos):get_int("baseaddr")
	local val = BaseAddr2Idx[baseaddr] or 0

	return "size[4,2]"..
		"label[0.1,0.0;I/O base port:]"..
		"dropdown[0.1,0.6;1.5;baseaddr;0,8,16,24,32,40,48,56;"..val.."]"..
		"button_exit[2.0,0.55;2,1;exit;Save]"
end

local function formspec_use(pos)
	local baseaddr = M(pos):get_int("baseaddr")
	local nvm = tech.get_nvm(pos)
	local val = nvm.input_val or "-"

	return "size[5,3]"..
		"real_coordinates[true]"..
		"label[0.5,0.8;Input Port:]"..
		"label[3.5,0.8;#" .. baseaddr .. "]"..
		"label[0.5,1.4;Input value:]"..
		"label[3.5,1.4;" .. val .. "]"..
		"button[1.0,2;3.0,0.8;update;Update]"
end

local function on_init_io(pos, cpu_pos)
	local meta = M(pos)
	meta:set_int("running", 0)
	meta:set_string("cpu_pos", P2S(cpu_pos))
	local baseaddr = meta:get_int("baseaddr")
	beduino.register_input_address(pos, cpu_pos, baseaddr, on_input)
	beduino.register_output_address(pos, cpu_pos, baseaddr, on_output)
	return baseaddr
end

local function on_start_io(pos, cpu_pos)
	local nvm = tech.get_nvm(pos)
	nvm.input_val = nil
end

local function store_settings(pos, meta, fields)
	local numbers = {}
	local labels = {}
	for i = 0,7 do
		numbers[i] = fields["num"..i]
		labels[i] = fields["lbl"..i]
	end
	meta:set_string("numbers", T2S(numbers))
	meta:set_string("labels", T2S(labels))
end

local function on_receive_fields(pos, formname, fields, player)
	if not player or minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = M(pos)
	local nvm = tech.get_nvm(pos)
	if fields.update then
		meta:set_string("formspec", formspec_use(pos))
	elseif fields.exit and fields.baseaddr then
		local baseaddr = tonumber(fields.baseaddr) or 1
		meta:set_int("baseaddr", baseaddr)
		lib.infotext(meta, DESCRIPTION)
		meta:set_string("formspec", formspec_use(pos))
	end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if not clicker or minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	if M(pos):contains("baseaddr") then
		M(pos):set_string("formspec", formspec_use(pos))
	end
end

minetest.register_node("beduino:inp_module", {
	description = DESCRIPTION,
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
		meta:set_string("node_number", own_num)  -- for techage
		meta:set_string("own_number", own_num)  -- for tubelib
		meta:set_string("owner", placer:get_player_name())
		lib.infotext(meta, DESCRIPTION)
		meta:set_string("formspec", formspec_place(pos))
	end,
	after_dig_node = function(pos)
		local meta = M(pos)
		tech.reset_node_data(pos)
		local cpu_pos = S2P(meta:get_string("cpu_pos"))
		local baseaddr = meta:get_int("baseaddr")
		for addr = baseaddr, baseaddr + 8 do
			beduino.unregister_address(pos, cpu_pos, addr)
		end
		tech.del_mem(pos)
	end,

	on_receive_fields = on_receive_fields,
	on_init_io = on_init_io,
	on_start_io = on_start_io,
	on_rightclick = on_rightclick,

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
			nvm.input_val = lib.get_num_cmnd(topic) or tonumber(topic) or 0
			local cpu_pos = S2P(M(pos):get_string("cpu_pos"))
			beduino.set_event(cpu_pos, 1)
		end
	end,
})


--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Router for controller to controller communication

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end

local DESCRIPTION = "Beduino Router"
local MAX_MSG_SIZE = 64
local MAX_NUM_MSG = 5

local lib = beduino.lib
local comm = beduino.comm

local MsgQue = {}
local MsgCnt = {}
local RouterPos = {}

local function count_transmit(addr)
	MsgCnt[addr] = MsgCnt[addr] or {rx = 0, tx = 0}
	MsgCnt[addr].tx = MsgCnt[addr].tx + 1
end

local function count_receive(addr)
	MsgCnt[addr] = MsgCnt[addr] or {rx = 0, tx = 0}
	MsgCnt[addr].rx = MsgCnt[addr].rx + 1
end

local function send_msg(src_addr, dst_addr, msg)
	RouterPos[dst_addr] = RouterPos[dst_addr] or lib.get_pos(dst_addr)
	if lib.valid_address(RouterPos[dst_addr], src_addr) then
		MsgQue[dst_addr] = MsgQue[dst_addr] or {}
		table.insert(MsgQue[dst_addr], {src_addr = src_addr, msg = msg})
		count_transmit(src_addr)
		count_receive(dst_addr)
		if #MsgQue[dst_addr] > MAX_NUM_MSG then
			table.remove(MsgQue[dst_addr], 1)
		end
		return 1
	end
	return 0
end

local function receive_msg(dst_addr)
	MsgQue[dst_addr] = MsgQue[dst_addr] or {}
	local data = table.remove(MsgQue[dst_addr], 1)
	if data then
		return data.src_addr, data.msg
	end
	return 0, ""
end

local function on_init_io(pos, cpu_pos)
	local meta = M(pos)
	meta:set_string("cpu_pos", P2S(cpu_pos))
	return meta:get_int("src_addr")
end

local function on_start_io(pos, cpu_pos)
	local src_addr = M(pos):get_int("src_addr")
	M(cpu_pos):set_int("router_addr", src_addr)
	MsgQue[src_addr] = nil
end

local function preserve_router_address(pos, itemstack)
	local imeta = itemstack:get_meta()
	if imeta and imeta:contains("src_addr") then
		M(pos):set_int("src_addr", imeta:get_int("src_addr"))
	end
end

local function preserve_metadata(pos, oldnode, oldmetadata, drops)
	if oldmetadata.src_addr then
		local meta = drops[1]:get_meta()
		meta:set_int("src_addr", oldmetadata.src_addr)
		meta:set_string("description", DESCRIPTION .. " #" .. oldmetadata.src_addr)
	end
end

local function formspec(pos, tx_cnt, rx_cnt)
	local addr = M(pos):get_int("src_addr")
	local s = M(pos):get_string("address_list")
	local cnts = MsgCnt[addr] or {rx = 0, tx = 0}
	return "size[8,3]"..
		"label[0.2,0.0;Messages: " .. cnts.rx .. " received,   ".. cnts.tx .. " sent]" ..
		"field[0.2,1.6;8.1,1;address;Valid Addresses (separated by spaces);" .. s .. "]"..
		"button[3.4,2.2;2,1;update;Update]" ..
		"button_exit[6.0,2.2;2,1;exit;Save]"
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = M(pos)
	preserve_router_address(pos, itemstack)
	if not meta:contains("src_addr") then
		local addr = lib.get_next_address()
		M(pos):set_int("src_addr", addr)
	end
	lib.register_pos(pos, M(pos):get_int("src_addr"))
	meta:set_string("infotext", DESCRIPTION .. " #" .. M(pos):get_int("src_addr"))
	meta:set_string("formspec", formspec(pos))
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	lib.del_address(pos)
	lib.unregister_pos(pos, tonumber(oldmetadata.fields.src_addr))
end

local function on_receive_fields(pos, formname, fields, player)
	if not player or minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	if fields.save then
		local s = fields.address:gsub("^%s*(.-)%s*$", "%1")
		M(pos):set_string("address_list", s)
	end
	M(pos):set_string("formspec", formspec(pos))
end

local function on_rightclick(pos, node, clicker)
	if not clicker or minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	M(pos):set_string("formspec", formspec(pos))
end

minetest.register_node("beduino:router", {
	description = DESCRIPTION,
	inventory_image = "beduino_router_inventory.png",
	wield_image = "beduino_router_inventory.png",
	tiles = {
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		{
			image = 'beduino_controller_side2.png^beduino_router2.png',
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.5,
			},
		},
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/32, -6/32, 12/32,  6/32,  6/32, 16/32},
		},
	},

	after_place_node = after_place_node,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		lib.del_address(pos)
		lib.unregister_pos(pos, tonumber(oldmetadata.fields.src_addr))
	end,

	on_init_io = on_init_io,
	on_start_io = on_start_io,
	preserve_metadata = preserve_metadata,
	on_receive_fields = on_receive_fields,
	on_rightclick = on_rightclick,

	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	stack_max = 1,
})

beduino.register_io_nodes({"beduino:router"})

-- address is fix 0x100, regA = dst_addr, regB = msg
local function sys_send_msg(cpu_pos, address, regA, regB, regC)
	local size = vm16.peek(cpu_pos, regB) + 1
	local msg = vm16.read_mem_as_str(cpu_pos, regB, math.min(size, MAX_MSG_SIZE))
	local src_addr = M(cpu_pos):get_int("router_addr")
	return send_msg(src_addr, regA, msg)
end

-- address is fix 0x100, regA = buff, regB = buff_size
local function sys_receive_msg(cpu_pos, address, regA, regB, regC)
	local addr = M(cpu_pos):get_int("router_addr")
	local src_addr, msg = receive_msg(addr)
	msg = msg:sub(1, regB * 4)
	vm16.write_mem_as_str(cpu_pos, regA, msg)
	return src_addr
end

-- address is fix 0x100, regA = dst_addr, regB = topic, regC = msg
local function sys_publish_msg(cpu_pos, address, regA, regB, regC)
	local size = vm16.peek(cpu_pos, regC) + 1
	local msg = vm16.read_mem_as_str(cpu_pos, regC, math.min(size, MAX_MSG_SIZE))
	local src_addr = M(cpu_pos):get_int("router_addr")
	count_transmit(src_addr)
	return comm.publish_msg(src_addr, regA, regB, msg)
end

-- address is fix 0x100, regA = dst_addr, regB = topic, regC = buff
local function sys_request_msg(cpu_pos, address, regA, regB, regC)
	local msg = comm.request_msg(regA, regB)
	if msg then
		local size = vm16.peek(cpu_pos, regC) + 1
		msg = msg:sub(1, size * 4)
		vm16.write_mem_as_str(cpu_pos, regC, msg)
		local src_addr = M(cpu_pos):get_int("router_addr")
		count_receive(src_addr)
		return 1
	end
	return 0
end

lib.register_SystemHandler(0x040, sys_send_msg)
lib.register_SystemHandler(0x041, sys_receive_msg)
lib.register_SystemHandler(0x042, sys_publish_msg)
lib.register_SystemHandler(0x043, sys_request_msg)



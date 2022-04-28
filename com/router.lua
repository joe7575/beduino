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
local S2P = function(s) return minetest.string_to_pos(s) end
local S2T = function(s) return minetest.deserialize(s) or {} end
local T2S = function(t) return minetest.serialize(t) or 'return {}' end

local DESCRIPTION = "Beduino Router"
local BASE_ADDR = 0x100
local MAX_MSG_SIZE = 64
local MAX_NUM_MSG = 5

local lib = beduino.lib
local storage = minetest.get_mod_storage()
local MsgQue = {}

local function get_next_address()
	local addr = storage:get_int("RouterAddress") + 1
	storage:set_int("RouterAddress", addr)
	return addr
end

local function send_msg(src_addr, dst_addr, msg)
	MsgQue[dst_addr] = MsgQue[dst_addr] or {}
	table.insert(MsgQue[dst_addr], {src_addr = src_addr, msg = msg})
	if #MsgQue[dst_addr] > MAX_NUM_MSG then
		table.remove(MsgQue[dst_addr], 1)
	end
	return 1
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
	M(pos):set_string("cpu_pos", P2S(cpu_pos))
	return BASE_ADDR
end

local function on_start_io(pos, cpu_pos)
	local src_addr = M(pos):get_int("src_addr")
	M(cpu_pos):set_int("router_addr", src_addr)
	MsgQue[src_addr] = nil
end

local function preserve_router_address(pos, itemstack)
	local imeta = itemstack:get_meta()
	if imeta then
		M(pos):set_int("src_addr", imeta:get_int("src_addr"))
	end
end

local function preserve_metadata(pos, oldnode, oldmetadata, drops)
	local meta = drops[1]:get_meta()
	meta:set_int("src_addr", oldmetadata.src_addr)
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

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = M(pos)
		preserve_router_address(pos, itemstack)
		if not meta:contains("src_addr") then
			local addr = get_next_address()
			M(pos):set_int("src_addr", addr)
		end
		meta:set_string("infotext", DESCRIPTION .. " #" .. M(pos):get_int("src_addr"))
	end,

	on_start_io = on_start_io,
	preserve_metadata = preserve_metadata,

	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
})

beduino.register_io_nodes({"beduino:router"})

-- address is fix 0x100, regA = dst_addr, regB = msg
local function sys_send_msg(cpu_pos, address, regA, regB, regC)
	--print("sys_send_msg", regA, regB)
	local size = vm16.peek(cpu_pos, regB) + 1
	local msg = vm16.read_mem_as_str(cpu_pos, regB, math.min(size, MAX_MSG_SIZE))
	local src_addr = M(cpu_pos):get_int("router_addr")
	return send_msg(src_addr, regA, msg)
end

-- address is fix 0x100, regA = buff, regB = buff_size
local function sys_receive_msg(cpu_pos, address, regA, regB, regC)
	--print("sys_receive_msg", regA, regB)
	local size = vm16.peek(cpu_pos, regB)
	local addr = M(cpu_pos):get_int("router_addr")
	local src_addr, msg = receive_msg(addr)
	msg = msg:sub(1, size*4)
	vm16.write_mem_as_str(cpu_pos, regA, msg)
	return src_addr
end

lib.register_SystemHandler(0x040, sys_send_msg)
lib.register_SystemHandler(0x041, sys_receive_msg)



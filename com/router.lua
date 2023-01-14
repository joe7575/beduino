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
local MAX_NUM_MSG = 16

local lib = beduino.lib
local comm = beduino.comm
local storage = beduino.storage

local MsgQue = minetest.deserialize(storage:get_string("MsgQue")) or {}

local function store_data()
	storage:set_string("MsgQue", minetest.serialize(MsgQue))
	minetest.after(74*60, function() store_data() end)
end

minetest.register_on_shutdown(store_data)
minetest.after(74*60, store_data)

----------------------------------------------------------------------
-- Formspec
----------------------------------------------------------------------
local function get_textsize(pos)
	local textsize = M(pos):get_int("textsize")
	if textsize >= 0 then
		textsize = "+" .. textsize
	else
		textsize = tostring(textsize)
	end
	return textsize
end

local function get_msg_text(my_addr)
	local out = {}
	local default = "  No message"
	for _,v in ipairs(MsgQue[my_addr] or {}) do
		table.insert(out, string.format("%4u", v.src_addr) .. ": " .. v.msg)
		default = nil
	end
	table.insert(out, default)
	return table.concat(out, "\n")
end

local function formspec(pos)
	local my_addr = M(pos):get_int("my_addr")
	local s = M(pos):get_string("beduino_address_list")
	local textsize = get_textsize(pos)
	local text = get_msg_text(my_addr)
	return "formspec_version[4]" ..
		"size[14,12]" ..
		"button[12.6,0;0.6,0.6;larger;+]" ..
		"button[13.2,0;0.6,0.6;smaller;-]" ..
		"field[0.2,1.0;13.6,0.7;address;Valid Addresses (separated by spaces);" .. s .. "]"..
		"box[0.2,2.4;13.6,8.4;#000]" ..
		"style_type[textarea;font=mono;textcolor=#FFF;border=false;font_size="  .. textsize .. "]" ..
		"textarea[0.2,2.4;13.6,8.4;;Pending receive messages (source-address: message);" .. text .. "]" ..
		"button[4.4,11;2,0.7;update;Update]" ..
		"button_exit[7.0,11;2,0.7;save;Save]"
end

----------------------------------------------------------------------
-- Communication
----------------------------------------------------------------------
local function send_msg(my_addr, dst_addr, msg)
	--print("send_msg", my_addr, dst_addr)
	if lib.valid_route(my_addr, dst_addr) then
		MsgQue[dst_addr] = MsgQue[dst_addr] or {}
		table.insert(MsgQue[dst_addr], {src_addr = my_addr, msg = msg})
		if #MsgQue[dst_addr] > MAX_NUM_MSG then
			table.remove(MsgQue[dst_addr], 1)
		end
		return 1
	end
	return 0
end

local function receive_msg(my_addr)
	--print("receive_msg", my_addr)
	if MsgQue[my_addr] then
		local data = table.remove(MsgQue[my_addr], 1)
		if data then
			return data.src_addr, data.msg
		end
	end
	return 0, ""
end

local function on_init_io(pos, cpu_pos)
	local meta = M(pos)
	meta:set_string("cpu_pos", P2S(cpu_pos))
	return meta:get_int("my_addr")
end

local function on_start_io(pos, cpu_pos)
	local my_addr = M(pos):get_int("my_addr")
	M(cpu_pos):set_int("router_addr", my_addr)
end

local function preserve_router_address(pos, itemstack)
	local imeta = itemstack:get_meta()
	if imeta and imeta:contains("my_addr") then
		M(pos):set_int("my_addr", imeta:get_int("my_addr"))
	end
end

local function preserve_metadata(pos, oldnode, oldmetadata, drops)
	if oldmetadata.my_addr then
		local meta = drops[1]:get_meta()
		meta:set_int("my_addr", oldmetadata.my_addr)
		meta:set_string("description", DESCRIPTION .. " #" .. oldmetadata.my_addr)
	end
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = M(pos)
	preserve_router_address(pos, itemstack)
	if not meta:contains("my_addr") then
		local my_addr = lib.get_next_address(pos)
		meta:set_int("my_addr", my_addr)
	else
		local my_addr = meta:get_int("my_addr")
		lib.claim_address(pos, my_addr)
	end
	meta:set_string("infotext", DESCRIPTION .. " #" .. M(pos):get_int("my_addr"))
	meta:set_string("formspec", formspec(pos))
	meta:set_string("beduino_address_list", "-")
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	local my_addr = tonumber(oldmetadata.fields.my_addr) or 0
	lib.del_filter_address(pos, my_addr)
	MsgQue[my_addr] = nil
	MsgCnt[my_addr] = nil
end

local function on_receive_fields(pos, formname, fields, player)
	if not player or minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	beduino.lib.on_receive_fields(pos, fields)
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
	after_dig_node = after_dig_node,
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

-- address is fix 0x040, regA = dst_addr, regB = msg
local function sys_send_msg(cpu_pos, address, regA, regB, regC)
	local size = math.min(vm16.peek(cpu_pos, regB) + 1, MAX_MSG_SIZE)
	local msg = vm16.read_mem_as_str(cpu_pos, regB, size)
	local my_addr = M(cpu_pos):get_int("router_addr")
	return send_msg(my_addr, regA, msg)
end

-- address is fix 0x041, regA = buff, regB = buff_size
local function sys_recv_msg(cpu_pos, address, regA, regB, regC)
	local my_addr = M(cpu_pos):get_int("router_addr")
	local src_addr, msg = receive_msg(my_addr)
	local size = math.min(regB, MAX_MSG_SIZE)
	msg = msg:sub(1, size * 4)
	vm16.write_mem_as_str(cpu_pos, regA, msg)
	return src_addr
end

lib.register_SystemHandler(0x040, sys_send_msg)
lib.register_SystemHandler(0x041, sys_recv_msg)

comm.router_send_msg = send_msg

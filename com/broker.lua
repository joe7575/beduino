--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Broker for publish/request communication

]]--

-- for lazy programmers
local M = minetest.get_meta

local DESCRIPTION = "Beduino Broker"
local MAX_TOPIC_NUM = 100

local lib = beduino.lib

local MsgTbl = {}
local MsgCnt = {}
local BrokerPos = {}

local function count_request(addr)
	MsgCnt[addr] = MsgCnt[addr] or {req = 0, pub = 0}
	MsgCnt[addr].req = MsgCnt[addr].req + 1
end

local function count_publish(addr)
	MsgCnt[addr] = MsgCnt[addr] or {req = 0, pub = 0}
	MsgCnt[addr].pub = MsgCnt[addr].pub + 1

end

function beduino.comm.publish_msg(src_addr, dst_addr, topic, msg)
	BrokerPos[dst_addr] = BrokerPos[dst_addr] or lib.get_pos(dst_addr)
	if lib.valid_address(BrokerPos[dst_addr], src_addr) and topic <= MAX_TOPIC_NUM then
		MsgTbl[dst_addr] = MsgTbl[dst_addr] or {}
		MsgTbl[dst_addr][topic] = msg
		count_publish(dst_addr)
		return 1
	end
	return 0
end

function beduino.comm.request_msg(dst_addr, topic)
	MsgTbl[dst_addr] = MsgTbl[dst_addr] or {}
	count_request(dst_addr)
	return MsgTbl[dst_addr][topic]
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
	local cnts = MsgCnt[addr] or {pub = 0, req = 0}
	return "size[8,3]"..
		"label[0.2,0.0;Messages: " .. cnts.pub .. " published,   ".. cnts.req .. " requested]" ..
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

minetest.register_node("beduino:broker", {
	description = DESCRIPTION,
	inventory_image = "beduino_broker_inventory.png",
	wield_image = "beduino_broker_inventory.png",
	tiles = {
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		'beduino_controller_side.png^beduino_broker.png',
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

beduino.register_io_nodes({"beduino:broker"})

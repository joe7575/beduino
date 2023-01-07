--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Broker for publish/fetch/request communication

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end

local DESCRIPTION = "Beduino Broker"
local MAX_NUM_MSG = 100
local MAX_MSG_SIZE = 32

local lib = beduino.lib
local comm = beduino.comm

local MsgTbl = {} -- received messages
local ReqTbl = {} -- received requests
local TopicCnt = {} -- to limit the max topic number

----------------------------------------------------------------------
-- Formspec
----------------------------------------------------------------------
local function in_list(list, x)
    for _, v in ipairs(list) do
        if v == x then return true end
    end
    return false
end

local function get_textsize(pos)
	local textsize = M(pos):get_int("textsize")
	if textsize >= 0 then
		textsize = "+" .. textsize
	else
		textsize = tostring(textsize)
	end
	return textsize
end

local function dump_table(tbl)
	local out = {}
	for _,v in ipairs(tbl or {}) do
		table.insert(out, "#" .. v)
	end
	return table.concat(out, ", ")
end

local function get_msg_text(my_addr)
	local out = {}
	table.insert(out, "### Messages ###")
	local default = "  No message"
	for k,v in pairs(MsgTbl[my_addr] or {}) do
		table.insert(out, "- " .. k .. ":  " .. v)
		default = nil
	end
	table.insert(out, default)
	table.insert(out, "### Requests ###")
	default = "  No request"

	for k,v in pairs(ReqTbl[my_addr] or {}) do
		table.insert(out, "- " .. k .. ":  " .. dump_table(v))
		default = nil
	end
	table.insert(out, default)
	return table.concat(out, "\n")
end

local function below_topic_limit(dst_addr, topic)
	if MsgTbl[dst_addr][topic] then
		return true
	end
	if TopicCnt[dst_addr] < MAX_NUM_MSG then
		TopicCnt[dst_addr] = TopicCnt[dst_addr] + 1
		return true
	end
	return false
end

local function formspec(pos, tx_cnt, rx_cnt)
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
		"textarea[0.2,2.4;13.6,8.4;;Messages/Requests;" .. text .. "]" ..
		"button[4.4,11;2,0.7;update;Update]" ..
		"button_exit[7.0,11;2,0.7;save;Save]"
end

----------------------------------------------------------------------
-- Communication
----------------------------------------------------------------------
local function answer_requests(dst_addr, topic, msg)
	if ReqTbl[dst_addr] and ReqTbl[dst_addr][topic] then
		for _, addr in ipairs(ReqTbl[dst_addr][topic]) do
			comm.router_send_msg(dst_addr, addr, msg)
		end
		ReqTbl[dst_addr][topic] = nil
	end
end

local function publish_msg(src_addr, dst_addr, topic, msg)
	--print("publish_msg", src_addr, dst_addr, topic)
	MsgTbl[dst_addr] = MsgTbl[dst_addr] or {}
	TopicCnt[dst_addr] = TopicCnt[dst_addr] or 0
	if below_topic_limit(dst_addr, topic) then
		MsgTbl[dst_addr][topic] = msg
		answer_requests(dst_addr, topic, msg)
		return 1
	end
	return 0
end

local function fetch_msg(dst_addr, topic)
	--print("fetch_msg", dst_addr, topic)
	if MsgTbl[dst_addr] then
		return MsgTbl[dst_addr][topic]
	end
end

local function request_msg(src_addr, dst_addr, topic)
	--print("request_msg", src_addr, dst_addr, topic)
	ReqTbl[dst_addr] = ReqTbl[dst_addr] or {}
	ReqTbl[dst_addr][topic] = ReqTbl[dst_addr][topic] or {}
	if not in_list(ReqTbl[dst_addr][topic], src_addr) then
		if below_topic_limit(dst_addr, topic) then
			table.insert(ReqTbl[dst_addr][topic], src_addr)
			return 1
		end
	end
	return 0
end

----------------------------------------------------------------------
-- Node handling
----------------------------------------------------------------------
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
	MsgTbl[my_addr] = nil
	TopicCnt[my_addr] = nil
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

----------------------------------------------------------------------
-- Beduino API
----------------------------------------------------------------------
-- regA = dst_addr, regB = topic_str, regC = msg
local function sys_publish_msg(cpu_pos, address, regA, regB, regC)
	local topic = vm16.read_ascii(cpu_pos, regB, 16)
	local size = vm16.peek(cpu_pos, regC) + 1
	local msg = vm16.read_mem_as_str(cpu_pos, regC, math.min(size, MAX_MSG_SIZE))
	local my_addr = M(cpu_pos):get_int("router_addr")
	if lib.valid_route(my_addr, regA) then
		return publish_msg(my_addr, regA, topic, msg)
	end
	return 0
end

-- regA = dst_addr, regB = topic_str, regC = buff
local function sys_fetch_msg(cpu_pos, address, regA, regB, regC)
	local my_addr = M(cpu_pos):get_int("router_addr")
	if lib.router_available(my_addr) then
		local topic = vm16.read_ascii(cpu_pos, regB, 16)
		local msg = fetch_msg(regA, topic)
		if msg then
			local size = vm16.peek(cpu_pos, regC) + 1
			msg = msg:sub(1, size * 4)
			vm16.write_mem_as_str(cpu_pos, regC, msg)
			return 1
		end
	end
	return 0
end

-- regA = dst_addr, regB = topic_str
local function sys_request_msg(cpu_pos, address, regA, regB, regC)
	local topic = vm16.read_ascii(cpu_pos, regB, 16)
	local my_addr = M(cpu_pos):get_int("router_addr")
	if lib.valid_route(my_addr, regA) then
		return request_msg(my_addr, regA, topic)
	end
	return 0
end

lib.register_SystemHandler(0x042, sys_publish_msg)
lib.register_SystemHandler(0x043, sys_fetch_msg)
lib.register_SystemHandler(0x044, sys_request_msg)

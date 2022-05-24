--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

-- for lazy programmers
local M = minetest.get_meta
local H = minetest.hash_node_position
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end
local S2T = function(s) return minetest.deserialize(s) or {} end
local T2S = function(t) return minetest.serialize(t) or 'return {}' end

local storage = minetest.get_mod_storage()

----------------------------------------------------------------------------------
--  Address to position translation
----------------------------------------------------------------------------------
local PosList = {}

local function register_pos(pos, address)
	storage:set_string("A" .. address, P2S(pos))
end

local function get_pos(address)
	PosList[address] = PosList[address] or S2P(storage:get_string("A" .. address))
	return PosList[address]
end

local function unregister_pos(address)
	storage:set_string("A" .. address, "")
	PosList[address] = nil
end

----------------------------------------------------------------------------------
--  Router address lists for message filterung
----------------------------------------------------------------------------------
local AddressList = {}

local function get_addresses(meta)
	local s =  meta:get_string("beduino_address_list")
	if s ~= "-" then
		local out = {}
		for addr in s:gmatch("%w+") do  --- white spaces
			out[tonumber(addr) or 0] = true
		end
		return out
	end
	return true
end

local function valid_filter_address(pos, address)
	local meta = M(pos)
	if meta:contains("beduino_address_list") then
		local hash = H(pos)
		AddressList[hash] = AddressList[hash] or get_addresses(meta)
		return AddressList[hash] == true or AddressList[hash][address] ~= nil
	end
end

function beduino.lib.get_next_address(pos)
	local addr = storage:get_int("RouterAddress") + 1
	storage:set_int("RouterAddress", addr)
	register_pos(pos, addr)
	return addr
end

function beduino.lib.claim_address(pos, address)
	register_pos(pos, address)
end

function beduino.lib.router_available(my_address)
	local pos = get_pos(my_address)
	if pos then
		return M(pos):contains("beduino_address_list")
	end
end

function beduino.lib.valid_route(my_addr, dst_addr)
	local pos1 = get_pos(my_addr)
	local pos2 = get_pos(dst_addr)
	if pos1 and pos2 then
		return valid_filter_address(pos2, my_addr)
	end
end

function beduino.lib.on_receive_fields(pos, fields)
	if fields.save then
		local s = fields.address:gsub("^%s*(.-)%s*$", "%1")
		if s == "" then
			s = "-"
		end
		M(pos):set_string("beduino_address_list", s)
		local hash = H(pos)
		AddressList[hash] = nil
	end
end

function beduino.lib.del_filter_address(pos, my_addr)
	unregister_pos(my_addr)
	local hash = H(pos)
	AddressList[hash] = nil
end

----------------------------------------------------------------------------------
--  Router infotext
----------------------------------------------------------------------------------
function beduino.lib.infotext(meta, descr, text)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	if numbers ~= "" then
		meta:set_string("infotext", descr .. " " .. own_num .. ": " .. "connected to " .. numbers)
	elseif text then
		meta:set_string("infotext", descr .. " " .. own_num .. ": " .. text)
	else
		meta:set_string("infotext", descr .. " " .. own_num)
	end
end

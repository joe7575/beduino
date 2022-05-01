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

function beduino.lib.get_next_address()
	local addr = storage:get_int("RouterAddress") + 1
	storage:set_int("RouterAddress", addr)
	return addr
end

----------------------------------------------------------------------------------
--  Router address lists for message filterung
----------------------------------------------------------------------------------
local AddressList = {}

local function get_addresses(pos)
	local s = M(pos):get_string("address_list")
	if s ~= "" then
		local out = {}
		for addr in s:gmatch("%w+") do  --- white spaces
			out[addr] = true
		end
		return out
	end
	return true
end

function beduino.lib.valid_address(pos, address)
	local hash = H(pos)
	AddressList[hash] = AddressList[hash] or get_addresses(pos)
	return AddressList[hash] == true or AddressList[hash][address] ~= nil
end

function beduino.lib.del_address(pos)
	local hash = H(pos)
	AddressList[hash] = nil
end

----------------------------------------------------------------------------------
--  Router address lists for message filterung
----------------------------------------------------------------------------------
function beduino.lib.infotext(meta, descr, text)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	if numbers ~= "" then
		meta:set_string("infotext", descr .. " " .. own_num .. ": " .. "connected with" .. " " .. numbers)
	elseif text then
		meta:set_string("infotext", descr .. " " .. own_num .. ": " .. text)
	else
		meta:set_string("infotext", descr .. " " .. own_num)
	end
end

function beduino.lib.register_pos(pos, address)
	storage:set_string("A" .. address, P2S(pos))
end

function beduino.lib.get_pos(address)
	return S2P(storage:get_string("A" .. address))
end

function beduino.lib.unregister_pos(pos, address)
	storage:set_string("A" .. address, "")
end

--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

   System Call Dispatcher
   
]]--

-- for lazy programmers
local M = minetest.get_meta
local H = minetest.hash_node_position
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end

local SystemHandlers = {}  -- on startup generated: t[address] = func

beduino.SysDesc = ""

function beduino.io.register_SystemHandler(address, func, desc)
	SystemHandlers[address] = func
	if desc then
		desc = desc:gsub(",", "\\,")
		desc = desc:gsub("\n", ",")
		desc = desc:gsub("#", "\\#")
		desc = desc:gsub(";", "\\;")
		beduino.SysDesc = beduino.SysDesc..","..desc
	end
end

function beduino.io.on_system(pos, address, val1, val2, val3)
	if SystemHandlers[address] then
		local sts, resp = pcall(SystemHandlers[address], pos, address, val1, val2, val3)
		if sts then
			return resp
		else
			minetest.log("warning", "[beduino] pcall exception: "..resp)
		end
	end
	return 0xFFFF
end

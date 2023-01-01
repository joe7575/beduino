--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

   stdio connection

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end
local lib = beduino.lib

-- To be overwritten by a terminal application
function lib.putchar(cpu_pos, val)
	return 0, 200
end

local function set_stdout(cpu_pos, val)
	M(cpu_pos):set_int("stdout", val)
	local prog_pos = S2P(M(cpu_pos):get_string("prog_pos"))
	vm16.set_stdout(prog_pos, val)
	return 1, 500
end

local function putchar(cpu_pos, val)
	local stdout = M(cpu_pos):get_int("stdout")
	if stdout == 2 then
		if val > 255 then
			lib.putchar(cpu_pos, math.floor(val / 256))
			return lib.putchar(cpu_pos, val % 256)
		else
			return lib.putchar(cpu_pos, val)
		end
	else
		local prog_pos = S2P(M(cpu_pos):get_string("prog_pos"))
		vm16.putchar(prog_pos, val)
		return 1, 500
	end
end

lib.register_SystemHandler(0, function(cpu_pos, address, regA, regB, regC)
	return putchar(cpu_pos, regA)
end)

lib.register_SystemHandler(1, function(cpu_pos, address, regA, regB, regC)
	return set_stdout(cpu_pos, regA)
end)

--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	OS functions

]]--

local function get_timeofday(pos, number, regA, regB, regC)
	local t = minetest.get_timeofday()
	return math.floor(t * 1440)
end

local function get_day_count(pos, number, regA, regB, regC)
	return minetest.get_day_count()
end

beduino.lib.register_SystemHandler(0x20, get_timeofday)
beduino.lib.register_SystemHandler(0x21, get_day_count)


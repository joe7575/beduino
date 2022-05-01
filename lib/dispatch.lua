--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

   System Call Dispatcher

]]--

local SystemHandlers = {}  -- on startup generated: t[number] = func

beduino.SysDesc = ""

function beduino.lib.register_SystemHandler(number, func)
	SystemHandlers[number] = func
end

function beduino.lib.on_system(cpu_pos, address, regA, regB, regC)
	if SystemHandlers[address] then
		local sts, resp = pcall(SystemHandlers[address], cpu_pos, address, regA, regB, regC)
		if sts then
			return resp
		else
			minetest.log("warning", "[Beduino] pcall exception: " .. resp)
		end
	end
	return 0xFFFF
end

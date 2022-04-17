--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Key/value store for string/number command conversion

]]--

local lNum2str = {[0] = "off"}
local lNum2const = {[0] = "OFF"}
local tStr2num = {off = 0}

function beduino.lib.register_cmnd(command, const)
	const = const or command:upper()
	lNum2str[#lNum2str + 1] = command
	lNum2const[#lNum2const + 1] = const
	tStr2num[command] = #lNum2str
end

function beduino.lib.get_description()
	local out = {"   Beduino I/O Commands", ""}
	for idx = 0, #lNum2str, 2 do
		out[#out + 1] = string.format("%3d - %-16s | %3d - %-16s", idx, lNum2str[idx], idx + 1, lNum2str[idx + 1] or "")
	end
	return table.concat(out, ",")
end

function beduino.lib.get_command_file()
	local out = {"// Beduino I/O Command Constants", ""}
	for idx, const in ipairs(lNum2const) do
		out[#out + 1] = string.format("const %-16s = %d;", const, idx)
	end
	return table. concat(out, "\n")
end

if minetest.global_exists("techage") then

	-- "off" is zero by default
	beduino.lib.register_cmnd("on")
	beduino.lib.register_cmnd("green")
	beduino.lib.register_cmnd("amber")
	beduino.lib.register_cmnd("red")
	beduino.lib.register_cmnd("state")
	beduino.lib.register_cmnd("fuel")
	beduino.lib.register_cmnd("depth")
	beduino.lib.register_cmnd("load")
	beduino.lib.register_cmnd("delivered")
	beduino.lib.register_cmnd("count")
	beduino.lib.register_cmnd("running")
	beduino.lib.register_cmnd("blocked")
	beduino.lib.register_cmnd("standby")
	beduino.lib.register_cmnd("nopower")
	beduino.lib.register_cmnd("fault")
	beduino.lib.register_cmnd("stopped")
	beduino.lib.register_cmnd("unloaded")
	beduino.lib.register_cmnd("empty")
	beduino.lib.register_cmnd("loaded")
	beduino.lib.register_cmnd("full")
	beduino.lib.register_cmnd("flowrate")
	beduino.lib.register_cmnd("action")
	beduino.lib.register_cmnd("stacks")
	beduino.lib.register_cmnd("count")
	beduino.lib.register_cmnd("output")
	beduino.lib.register_cmnd("input")

elseif minetest.global_exists("tubelib") then

	-- "off" is zero by default
	beduino.lib.register_cmnd("on")
	beduino.lib.register_cmnd("green")
	beduino.lib.register_cmnd("amber")
	beduino.lib.register_cmnd("red")
	beduino.lib.register_cmnd("state")
	beduino.lib.register_cmnd("close")
	beduino.lib.register_cmnd("open")
	beduino.lib.register_cmnd("running")
	beduino.lib.register_cmnd("blocked")
	beduino.lib.register_cmnd("standby")
	beduino.lib.register_cmnd("defect")
	beduino.lib.register_cmnd("fault")
	beduino.lib.register_cmnd("stopped")
	beduino.lib.register_cmnd("full")
	beduino.lib.register_cmnd("empty")

end

function beduino.lib.get_text_cmnd(num)
	return lNum2str[num]
end

function beduino.lib.get_num_cmnd(str)
	return tStr2num[str]
end
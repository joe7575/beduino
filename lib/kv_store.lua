--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Key/value store for string/number command conversion

]]--

local lNum2str = {}
local lNum2const = {}
local tStr2num = {}

function beduino.lib.register_cmnd(command, const)
	const = const or command:upper()
	if not next(lNum2str) then
		table.insert(lNum2str, 0, command)
		table.insert(lNum2const, 0, "IO_" .. const)
		tStr2num[command] = 0
	else
		table.insert(lNum2str, command)
		table.insert(lNum2const, "IO_" .. const)
		tStr2num[command] = #lNum2str
	end
end

function beduino.lib.get_description()
	local out = {"   Beduino I/O Commands", ""}
	for idx = 0, #lNum2str do
		out[#out + 1] = minetest.formspec_escape(string.format('%-16s = "%s"', lNum2const[idx], lNum2str[idx]))
	end
	return table.concat(out, ",")
end

function beduino.lib.get_command_file()
	local out = {"// Beduino I/O Command Constants", ""}
	for idx = 0, #lNum2str do
		out[#out + 1] = string.format("const %-16s = %d;", lNum2const[idx], idx)
	end
	return table.concat(out, "\n")
end

function beduino.lib.get_text_cmnd(num)
	return lNum2str[num]
end

function beduino.lib.get_num_cmnd(str)
	return tStr2num[str]
end

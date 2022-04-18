--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Key/value store for string/number command conversion

]]--

local lNum2str = {[0] = "off"}
local lNum2const = {[0] = "IO_OFF"}
local tStr2num = {off = 0}

function beduino.lib.register_cmnd(command, const)
	const = const or command:upper()
	lNum2str[#lNum2str + 1] = command
	lNum2const[#lNum2const + 1] = "IO_" .. const
	tStr2num[command] = #lNum2str
end

function beduino.lib.get_description()
	local out = {"   Beduino I/O Commands", ""}
	for idx = 0, #lNum2str do
		out[#out + 1] = minetest.formspec_escape(string.format('%-16s = "%s"', lNum2const[idx], lNum2str[idx]))
	end
	out[#out + 1] = ""
	out[#out + 1] = minetest.formspec_escape("value = input(port);")
	out[#out + 1] = minetest.formspec_escape("output(port, value);")
	out[#out + 1] = minetest.formspec_escape("state = read(port, IO_STATE);  // read machine state")
	out[#out + 1] = minetest.formspec_escape("send_cmnd(port, ident, add_data, resp); // see manual")
	
	return table.concat(out, ",")
end

function beduino.lib.get_command_file()
	local out = {"// Beduino I/O Command Constants", ""}
	out[#out + 1] = string.format("const %-16s = %d;", lNum2const[0], 0)
	for idx, const in ipairs(lNum2const) do
		out[#out + 1] = string.format("const %-16s = %d;", const, idx)
	end
	return table.concat(out, "\n")
end

function beduino.lib.get_text_cmnd(num)
	return lNum2str[num]
end

function beduino.lib.get_num_cmnd(str)
	return tStr2num[str]
end

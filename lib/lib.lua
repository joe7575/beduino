--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

function beduino.lib.infotext(meta, descr, text)
	local own_num = meta:get_string("node_number") or ""
	local numbers = meta:get_string("numbers") or ""
	if numbers ~= "" then
		meta:set_string("infotext", descr.." "..own_num..": "..S("connected with").." "..numbers)
	elseif text then
		meta:set_string("infotext", descr.." "..own_num..": "..text)
	else
		meta:set_string("infotext", descr.." "..own_num)
	end
end
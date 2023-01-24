--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Formspec library for I/O and input modules

]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end
local S2T = function(s) return minetest.deserialize(s) or {} end
local T2S = function(t) return minetest.serialize(t) or 'return {}' end
local S   = function(s) return tostring(s or "-") end

local tech = beduino.tech
local lib = {}

local BaseAddr2Idx = {
	[0]=1, [8]=2, [16]=3, [24]=4, [32]=5, [40]=6, [48]=7, [56]=8,
	[64]=9, [72]=10, [80]=11, [88]=12, [96]=13, [104]=14, [112]=15, [120]=16,
}

local function get_node_name(pos, lbl, port, dest_num)
	if lbl and lbl ~= "" and lbl ~= "-" then
		return lbl
	end
	if port and dest_num and tonumber(dest_num) then
		return tech.get_node_name(pos, port, dest_num) or "-"
	end
	return "-"
end

local function store_settings(pos, meta, fields)
	local numbers = {}
	local labels = {}
	for i = 0,7 do
		numbers[i] = fields["num"..i]
		labels[i] = fields["lbl"..i]
	end
	meta:set_string("numbers", T2S(numbers))
	meta:set_string("labels", T2S(labels))
end

local function input_value(cpu_pos, port)
	local nvm = tech.get_nvm(cpu_pos)
	return nvm.inputs and nvm.inputs[port] or "-"
end

function lib.formspec_place(pos)
	local baseaddr = M(pos):get_int("baseaddr")
	local val = BaseAddr2Idx[baseaddr] or 0

	return "size[4,2]"..
		"label[0.1,0.0;I/O base port:]"..
		"dropdown[0.1,0.6;1.5;baseaddr;0,8,16,24,32,40,48,56;"..val.."]"..
		"button_exit[2.0,0.55;2,1;exit;Save]"
end

function lib.formspec_use(pos)
	local meta = M(pos)
	local numbers = S2T(meta:get_string("numbers"))
	local labels  = S2T(meta:get_string("labels"))
	local baseaddr = meta:get_int("baseaddr")
	local nvm = tech.get_nvm(pos)
	local lines = {}
	local buttons = ""
	local has_inputs = nvm.in_use and minetest.get_node(pos).name == "beduino:inp_module"
	local desc_posX = has_inputs and "6.5" or "5.0"
	local tab = nvm.in_use and 1 or 2
	if not nvm.in_use then
		buttons = "button[6.7,8.6;3.5,1.0;save;Save]"
	elseif has_inputs then
		buttons = "button[6.7,8.6;3.5,1.0;update;Update]"
	end

	for i = 0,7 do
		local y = i * 0.8 + 1
		lines[#lines+1] = "label[0.5," .. y .. ";#" .. S(i + baseaddr) .. "]"
		if nvm.in_use then
			lines[#lines+1] = "label[2.3," .. y .. ";" .. S(numbers[i]) .. "]"
			if has_inputs then
				lines[#lines+1] = "label[4.8," .. y .. ";" .. input_value(pos, i + baseaddr) .. "]"
			end
			lines[#lines+1] = "label[" .. desc_posX .. ","..y..";"..get_node_name(pos, labels[i], i, numbers[i]).."]"
		else
			lines[#lines+1] = "field[2.3," .. (y-0.3) .. ";2.3,0.7;num" .. S(i) .. ";;" .. S(numbers[i]) .. "]"
			lines[#lines+1] = "field[5.0," .. (y-0.3) .. ";5.9,0.7;lbl" .. S(i) .. ";;" .. S(labels[i]) .. "]"
		end
	end

	return "size[12,10]"..
		"real_coordinates[true]" ..
		"tabheader[0,0;tab;I/O,config;" .. tab .. ";;true]" ..
		"container[0.3,1]" ..
		"label[0.5,0;Port]" ..
		"label[2.3,0;Number]" ..
		(has_inputs and "label[4.8,0;Input]" or "") ..
		"label[" .. desc_posX .. ",0;Description]" ..
		table.concat(lines) ..
		"container_end[]" ..
		buttons
end

function lib.store_port_number_relation(pos)
	local meta = M(pos)
	local cpu_pos = S2P(meta:get_string("cpu_pos"))
	local own_num = meta:get_string("node_number")
	local numbers = S2T(meta:get_string("numbers"))
	local baseaddr = meta:get_int("baseaddr")

	if cpu_pos and numbers then
		for i = 0, 7 do
			local port = i + baseaddr
			tech.add_number_port_relation(cpu_pos, port, own_num, numbers[i])
		end
	end
end

function lib.on_receive_fields(pos, formname, fields, player)
	if not player or minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = M(pos)
	local nvm = tech.get_nvm(pos)
	if fields.tab == "2" then
		nvm.in_use = false
		meta:set_string("formspec", lib.formspec_use(pos))
	elseif fields.tab == "1" then
		nvm.in_use = true
		meta:set_string("formspec", lib.formspec_use(pos))
	elseif fields.save then
		nvm.in_use = true
		store_settings(pos, meta, fields)
		--lib.store_port_number_relation(pos)
		meta:set_string("formspec", lib.formspec_use(pos))
	elseif fields.update then
		meta:set_string("formspec", lib.formspec_use(pos))
	elseif fields.exit and fields.baseaddr then
		local baseaddr = tonumber(fields.baseaddr) or 1
		meta:set_int("baseaddr", baseaddr)
		local own_num = meta:get_string("node_number")
		beduino.lib.infotext(meta, lib.DESCRIPTION, '#' .. baseaddr)
		meta:set_string("formspec", lib.formspec_use(pos))
	end
end

function lib.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if not clicker or minetest.is_protected(pos, clicker:get_player_name()) then
		return
	end
	if M(pos):contains("baseaddr") then
		M(pos):set_string("formspec", lib.formspec_use(pos))
	end
end

return lib

--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	I/O port handling I/O modules

]]--

-- for lazy programmers
local H = minetest.hash_node_position
local NUM_PORTS = 16

-- Port is a I/O module local number (0..7)

local NodeInfo = {}    -- [pos_hash][port] = {....}
local Num2port = {}
local Port2num = {}

local function get_node_name(dest_num)
	local info = beduino.tech.get_node_info(dest_num)
	if info then
		local ndef = minetest.registered_nodes[info.name]
		return ndef and ndef.description
	end
end

-- techage like numbers
function beduino.tech.add_number_port_relation(cpu_pos, port, own_num, dest_num)
	--print("add_number_port_relation", port, own_num, dest_num)
	if port and port < NUM_PORTS then
		local hash = H(cpu_pos)
		Num2port[hash] = Num2port[hash] or {}
		Port2num[hash] = Port2num[hash] or {}
		NodeInfo[hash] = NodeInfo[hash] or {}

		if dest_num and dest_num:match("[%d]+") then
			Num2port[hash][dest_num] = port
			Port2num[hash][port] = {own_num = own_num, dest_num = dest_num}
			local name = get_node_name(dest_num)
			if name then
				NodeInfo[hash][port] = {pos = cpu_pos, name = name}
			end
		end
	end
end

function beduino.tech.get_node_name(cpu_pos, port, dest_num)
	local hash = H(cpu_pos)
	NodeInfo[hash] = NodeInfo[hash] or {}
	return NodeInfo[hash][port] or get_node_name(dest_num)
end

function beduino.tech.get_node_numbers(cpu_pos, port)
	local hash = H(cpu_pos)
	Port2num[hash] = Port2num[hash] or {}
	if Port2num[hash][port] then
		return Port2num[hash][port].own_num, Port2num[hash][port].dest_num
	end
end

function beduino.tech.get_node_port(cpu_pos, number)
	local hash = H(cpu_pos)
	Num2port[hash] = Num2port[hash] or {}
	return Num2port[hash][number]
end

function beduino.tech.reset_node_data(cpu_pos)
	local hash = H(cpu_pos)
	NodeInfo[hash] = {}
	Num2port[hash] = {}
	Port2num[hash] = {}
end


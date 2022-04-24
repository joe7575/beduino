--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	I(O port handling I/O modules

]]--

-- for lazy programmers
local H = minetest.hash_node_position

-- Port is a I/O module local number (0..7)

local NodeInfo = {}    -- [pos_hash][port] = {....}
local Num2port = {}
local Port2num = {}

function beduino.tech.set_input(nvm, port, val)
	--print("set_input", port, val)
	if port and port < 8 then
		nvm.input = nvm.input or {}
		nvm.input[port] = val
	end
end

function beduino.tech.get_input(nvm, port)
	--print("get_input", port)
	if port and port < 8 then
		nvm.input = nvm.input or {}
		return nvm.input[port] or 0
	end
end

function beduino.tech.set_output(nvm, port, val)
	--print("set_output", port, val)
	if port and port < 8 then
		nvm.output = nvm.output or {}
		if nvm.output[port] ~= val then
			nvm.output[port] = val
			return true
		end
	end
end

function beduino.tech.get_output(nvm, port)
	--print("get_output", port)
	if port and port < 8 then
		nvm.output = nvm.output or {}
		return nvm.output[port] or 0
	end
end

-- techage/tubelib like numbers
function beduino.tech.add_node_data(pos, port, number)
	if port and port < 8 then
		local hash = H(pos)
		Num2port[hash] = Num2port[hash] or {}
		Port2num[hash] = Port2num[hash] or {}
		NodeInfo[hash] = NodeInfo[hash] or {}
		
		if number and number:match("[%d]+") then
			Num2port[hash][number] = port
			Port2num[hash][port] = number
			local info = beduino.tech.get_node_info(number)
			if info then
				local ndef = minetest.registered_nodes[info.name]
				if ndef and ndef.description then
					NodeInfo[hash][port] = {pos = pos, name = ndef.description}
				end
			end
		end
	end
end

function beduino.tech.get_node_data(pos, port)
	local hash = H(pos)
	NodeInfo[hash] = NodeInfo[hash] or {}
	return NodeInfo[hash][port]
end

function beduino.tech.get_node_number(pos, port)
	local hash = H(pos)
	Port2num[hash] = Port2num[hash] or {}
	return Port2num[hash][port]
end

function beduino.tech.get_node_port(pos, number)
	local hash = H(pos)
	Num2port[hash] = Num2port[hash] or {}
	return Num2port[hash][number]
end

function beduino.tech.reset_node_data(pos)
	local hash = H(pos)
	NodeInfo[hash] = {}
	Num2port[hash] = {}
	Port2num[hash] = {}
end


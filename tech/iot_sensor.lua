--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

   Beduino IOT Sensor

]]--

-- for lazy programmers
local M = minetest.get_meta
local H = minetest.hash_node_position
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end

local lib = beduino.lib
local tech = beduino.tech

local RAM_SIZE = 3
local DESC = "Beduino IOT Sensor"

local Cache = {} -- used for CPU intermediate results

local Info = [[
              Beduino
              =======

The Beduino IOT Sensor is used to control and
monitor your local machines.
This controller can be programmed in mC,
a C like language.

Learn more about mC on:
https://github.com/joe7575/vm16/wiki
]]

----------------------------------------------------------------------
-- Input handling
----------------------------------------------------------------------
local function set_input(cpu_pos, port, value)
	local nvm = tech.get_nvm(cpu_pos)
	nvm.inputs = nvm.inputs or {}
	nvm.inputs[port] = value
end

local function get_input(cpu_pos, port)
	local nvm = tech.get_nvm(cpu_pos)
	nvm.inputs = nvm.inputs or {}
	return nvm.inputs[port] or 0
end

----------------------------------------------------------------------
-- system call handling
----------------------------------------------------------------------
local function on_input(cpu_pos, port)
	return get_input(cpu_pos, port)
end

local function sys_resp_buff(cpu_pos, address, regA, regB, regC)
	Cache[H(cpu_pos)] = regB
	return 1
end

-- regA = port, regB = topic, regC = payload
local function sys_send_cmnd(cpu_pos, address, regA, regB, regC)
	local own_num, dest_num = tech.get_node_numbers(cpu_pos, regA)
	if dest_num then
		local topic = regB
		local payload
		if topic >= 64 then
			payload = vm16.read_ascii(cpu_pos, regC, 32)
		else
			payload = vm16.read_mem(cpu_pos, regC, 8)
		end
		techage.counting_add(M(cpu_pos):get_string("owner"), 1)
		return techage.beduino_send_cmnd(own_num, dest_num, topic, payload)
	end
	return 1
end

-- regA = port, regB = topic, regC = payload
-- response adress in Cache
local function sys_request_data(cpu_pos, address, regA, regB, regC)
	local own_num, dest_num = tech.get_node_numbers(cpu_pos, regA)
	if dest_num then
		local topic = regB
		local payload = vm16.read_mem(cpu_pos, regC, 8)
		local sts, resp = techage.beduino_request_data(own_num, dest_num, topic, payload)
		local resp_addr = Cache[H(cpu_pos)]
		if sts == 0 and resp and resp_addr and resp_addr ~= 0 then
			if type(resp) == "table" then
				vm16.write_mem(cpu_pos, resp_addr, resp)
			else
				vm16.write_ascii_16(cpu_pos, resp_addr, resp .. "\0")
			end
		end
		return sts
	end
	return 1
end

local SystemHandlers = {
	[0x101] = sys_resp_buff,
	[0x106] = sys_send_cmnd,
	[0x107] = sys_request_data,
}

local function on_system(cpu_pos, address, regA, regB, regC)
	if SystemHandlers[address] then
		local sts, resp, costs = pcall(SystemHandlers[address], cpu_pos, address, regA, regB, regC)
		if sts then
			return resp, costs
		else
			minetest.log("warning", "[Beduino] pcall exception: " .. resp)
		end
	else
		return lib.on_system(cpu_pos, address, regA, regB, regC)
	end
end

----------------------------------------------------------------------
-- CPU Initialization / techage node search
----------------------------------------------------------------------
-- The sensor uses 'minetest.rotate_and_place' which fucks up the node param2
local Wall2Facedir = {
	[0] = 4,
	[1] = 13,
	[2] = 10,
	[3] = 19,
	[7] = 2,
	[9] = 0,
	[12] = 3,
	[18] = 1,
	[20] = 8,
	[21] = 15,
	[22] = 6,
	[23] = 17,
}

local function get_node_number(pos, sides, param2)
	local pos2 = networks.get_relpos(pos, sides, param2)
	return tech.determine_node_number(pos2)
end

local function find_io_nodes(cpu_pos)
	local node = minetest.get_node(cpu_pos)
	local param2 = Wall2Facedir[node.param2] or node.param2
	local own_num = M(cpu_pos):get_string("node_number")

	tech.add_number_port_relation(cpu_pos, 0, own_num, get_node_number(cpu_pos, "B",   param2))
	tech.add_number_port_relation(cpu_pos, 1, own_num, get_node_number(cpu_pos, "BU",  param2))
	tech.add_number_port_relation(cpu_pos, 2, own_num, get_node_number(cpu_pos, "BR",  param2))
	tech.add_number_port_relation(cpu_pos, 3, own_num, get_node_number(cpu_pos, "BD",  param2))
	tech.add_number_port_relation(cpu_pos, 4, own_num, get_node_number(cpu_pos, "BL",  param2))
end

local function on_init_cpu(cpu_pos)
	local out = {}

	out[#out + 1] = "The Controller has:"
	out[#out + 1] = string.format(" - %u words RAM", (2 ^ (RAM_SIZE + 6)))

	out[#out + 1] = ""
	out[#out + 1] = "The Controller is connected to:"

	local default = " - nothing yet"
	for port = 0,4 do
		local own_num, dest_num = tech.get_node_numbers(cpu_pos, port)
		if dest_num then
			beduino.register_input_address(cpu_pos, cpu_pos, port, on_input)
			local name = tech.get_node_name(cpu_pos, port, dest_num)
			table.insert(out, string.format(" - #%u: %s (%s)", port, name, dest_num))
			default = nil
		end
	end
	table.insert(out, default)
	return table.concat(out, "\n")
end

----------------------------------------------------------------------
-- CPU definition
----------------------------------------------------------------------
local cpu_def = {
	cpu_type = "beduino",
	cycle_time = 0.2, -- timer cycle time
	instr_per_cycle = 5000,
	input_costs = 1000,  -- number of instructions
	output_costs = 5000, -- number of instructions
	system_costs = 2000, -- number of instructions
	startup_code = {
		-- Reserved area 0002 - 0007:
		"jump 8",
		".org 8",
		"call @init",
		"call init",
		"@loop:",
		"call loop",
		"nop",
		"jump @loop",
	},
	-- Called for each 'input' instruction.
	on_input = on_input,
	-- Called for each 'system' instruction.
	on_system = on_system,
	-- Called when CPU stops.
	on_update = function(pos, resp)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		vm16.update_programmer(pos, prog_pos, resp)
	end,
	-- Called when the programmers info/splash screen is displayed
	on_init = function(pos, prog_pos, server_pos)
		if prog_pos then
			M(pos):set_string("prog_pos", P2S(prog_pos))
		end
		if server_pos then
			find_io_nodes(pos)
			local s = on_init_cpu(pos)
			vm16.write_file(server_pos, "info.txt", Info .. s)
		end
	end,
	on_mem_size = function(pos)
		return RAM_SIZE
	end,
	on_start = function(pos)
		lib.infotext(M(pos), DESC, "(running)")
		M(pos):set_int("running", 1)
	end,
	on_stop = function(pos)
		lib.infotext(M(pos), DESC, "(stopped)")
		M(pos):set_int("running", 0)
	end,
	on_check_connection = function(pos)
		return S2P(M(pos):get_string("prog_pos"))
	end,
	on_infotext = function(pos)
		return Info
	end,
}

----------------------------------------------------------------------
-- Node definition
----------------------------------------------------------------------
local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	return minetest.rotate_and_place(itemstack, placer, pointed_thing)
end

local function on_timer(pos, elapsed)
	local prog_pos = S2P(M(pos):get_string("prog_pos"))
	return vm16.keep_running(pos, prog_pos, cpu_def)
end

local function after_dig_node(pos)
	local prog_pos = S2P(M(pos):get_string("prog_pos"))
	vm16.unload_cpu(pos, prog_pos)
end

local function swap_node_depending_on_aligment(pos)
	local node = minetest.get_node(pos)
	if node.param2 < 4 then
		-- placed on the floor
		minetest.swap_node(pos, {name = "beduino:iot_sensor2", param2 = node.param2})
	elseif node.param2 > 19 then
		-- placed on the ceiling
		minetest.swap_node(pos, {name = "beduino:iot_sensor3", param2 = node.param2})
	end
end

minetest.register_node("beduino:iot_sensor", {
	description = DESC,
	inventory_image = "beduino_sensor_inventory.png",
	wield_image = "beduino_sensor_inventory.png",
	stack_max = 1,
	tiles = {
		"beduino_sensor_side.png^[transformR90",
		"beduino_sensor_side.png^[transformFYR270",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-5/32, -16/32, -5/32,  5/32, -11/32, 5/32},
		},
	},
	vm16_cpu = cpu_def,
	on_place = on_place,
	after_place_node = function(pos, placer)
		local meta = M(pos)
		local own_num = tech.add_node(pos, "beduino:io_module")
		meta:set_string("node_number", own_num)
		meta:set_string("owner", placer:get_player_name())
		lib.infotext(meta, DESC)
		swap_node_depending_on_aligment(pos)
		find_io_nodes(pos)
	end,
	on_timer = on_timer,
	after_dig_node = after_dig_node,
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	stack_max = 1,
})

-- Needed for floor placement
minetest.register_node("beduino:iot_sensor2", {
	description = DESC,
	inventory_image = "beduino_sensor_inventory.png",
	wield_image = "beduino_sensor_inventory.png",
	stack_max = 1,
	tiles = {
		"beduino_sensor_side.png",
		"beduino_sensor_side.png^[transformFY",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-5/32, -16/32, -5/32,  5/32, -11/32, 5/32},
		},
	},
	vm16_cpu = cpu_def,
	on_place = on_place,
	on_timer = on_timer,
	after_dig_node = after_dig_node,
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	is_ground_content = false,
	stack_max = 1,
	drop = "beduino:iot_sensor",
})

-- Needed for ceiling placement
minetest.register_node("beduino:iot_sensor3", {
	description = DESC,
	inventory_image = "beduino_sensor_inventory.png",
	wield_image = "beduino_sensor_inventory.png",
	stack_max = 1,
	tiles = {
		"beduino_sensor_side.png^[transformR180",
		"beduino_sensor_side.png^[transformFYR180",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
		"beduino_sensor_side.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-5/32, -16/32, -5/32,  5/32, -11/32, 5/32},
		},
	},
	vm16_cpu = cpu_def,
	on_place = on_place,
	on_timer = on_timer,
	after_dig_node = after_dig_node,
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2, not_in_creative_inventory=1},
	is_ground_content = false,
	stack_max = 1,
	drop = "beduino:iot_sensor",
})

beduino.tech.register_node({"beduino:iot_sensor", "beduino:iot_sensor2", "beduino:iot_sensor3"}, {
	on_recv_message = function(pos, src_num, topic, payload)
		if tech.tubelib then
			pos, src_num, topic = pos, topic, src_num
		end
		local val = tonumber(topic) or topic == "on" and 1 or 0
		local port = tech.get_node_port(pos, src_num)
		if port then
			set_input(pos, port, val)
		end
	end,
	on_node_load = function(pos)
		find_io_nodes(pos)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		if M(pos):get_int("running") == 1 then
			vm16.load_cpu(pos, prog_pos, cpu_def)
		end
	end,
})

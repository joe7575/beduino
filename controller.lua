--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

   Beduino Controller / CPU

]]--

-- for lazy programmers
local M = minetest.get_meta
local H = minetest.hash_node_position
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end

local lib = beduino.lib

local RADIUS = 3    -- for I/O modules
local Inputs = {}   -- [cpu_pos][port] = {node_pos, clbk}
local Outputs = {}  -- [cpu_pos][port] = {node_pos, clbk}
local IONodes = {}  -- Known I/O nodes

local Info = [[
              Beduino
              =======

The Beduino controller is used to control and
monitor your machines.
This controller can be programmed in Cipol,
a C like language.

Learn more about Cipol on:
https://github.com/joe7575/vm16/wiki

The Controller is connected to:
]]

local function find_io_nodes(cpu_pos)
	local pos1 = {x = cpu_pos.x - RADIUS, y = cpu_pos.y - RADIUS, z = cpu_pos.z - RADIUS}
	local pos2 = {x = cpu_pos.x + RADIUS, y = cpu_pos.y + RADIUS, z = cpu_pos.z + RADIUS}
	return minetest.find_nodes_in_area(pos1, pos2, IONodes)
end


local function on_init_cpu(cpu_pos)
	local out = {}
	for _,pos in ipairs(find_io_nodes(cpu_pos)) do
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_init_io then
			local address = ndef.on_init_io(pos, cpu_pos)
			table.insert(out, string.format(" - %s #%d at %s", node.name, address, P2S(pos)))
		end
	end
	return table.concat(out, "\n")
end

local function on_start_cpu(cpu_pos)
	for _,pos in ipairs(find_io_nodes(cpu_pos)) do
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_start_io then
			ndef.on_start_io(pos, cpu_pos)
		end
	end
end

local function on_stop_cpu(cpu_pos)
	for _,pos in ipairs(find_io_nodes(cpu_pos)) do
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_stop_io then
			ndef.on_stop_io(pos, cpu_pos)
		end
	end
end

-- CPU definition
local cpu_def = {
	cpu_type = "beduino",
	cycle_time = 0.2, -- timer cycle time
	instr_per_cycle = 10000,
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
	on_input = function(pos, address)
		local hash = H(pos)
		local item = Inputs[hash] and Inputs[hash][address]
		if item then
			return item.input(item.pos, address) or 0
		end
		return 0xffff
	end,
	-- Called for each 'output' instruction.
	on_output = function(pos, address, val1, val2)
		local hash = H(pos)
		local item = Outputs[hash] and Outputs[hash][address]
		if item then
			item.output(item.pos, address, val1, val2)
		end
	end,
	-- Called for each 'system' instruction.
	on_system = lib.on_system,
	-- Called when CPU stops.
	on_update = function(pos, resp)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		vm16.update_programmer(pos, prog_pos, resp)
	end,
	-- Called when the programmers info/splash screen is displayed
	on_init = function(pos, prog_pos, server_pos)
		M(pos):set_string("prog_pos", P2S(prog_pos))
		if server_pos then
			local s = on_init_cpu(pos)
			vm16.write_file(server_pos, "info.txt", Info .. s)
		end
	end,
	on_mem_size = function(pos)
		return 5  -- 2048 words
	end,
	on_start = function(pos)
		M(pos):set_string("infotext", "Beduino Controller (running)")
		M(pos):set_int("running", 1)
		on_start_cpu(pos)
	end,
	on_stop = function(pos)
		M(pos):set_string("infotext", "Beduino Controller (stopped)")
		M(pos):set_int("running", 0)
		on_stop_cpu(pos)
	end,
	on_check_connection = function(pos)
		return S2P(M(pos):get_string("prog_pos"))
	end,
	on_infotext = function(pos)
		return Info
	end,
}

minetest.register_node("beduino:controller", {
	description = "Beduino Controller",
	inventory_image = "beduino_controller_inventory.png",
	wield_image = "beduino_controller_inventory.png",
	stack_max = 1,
	tiles = {
		-- up, down, right, left, back, front
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png",
		"beduino_controller_side.png^beduino_controller.png",
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/32, -6/32, 12/32,  6/32,  6/32, 16/32},
		},
	},
	vm16_cpu = cpu_def,
	after_place_node = function(pos, placer)
		M(pos):set_string("infotext", "Beduino Controller")
		M(pos):set_string("owner", placer:get_player_name())
	end,
	on_timer = function(pos, elapsed)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		return vm16.keep_running(pos, prog_pos, cpu_def)
	end,
	after_dig_node = function(pos)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		vm16.unload_cpu(pos, prog_pos)
	end,
	paramtype = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	stack_max = 1,
})

minetest.register_lbm({
	label = "Beduino Load Controller",
	name = "beduino:load_controller",
	nodenames = {"beduino:controller"},
	run_at_every_load = true,
	action = function(pos, node)
		find_io_nodes(pos)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		if M(pos):get_int("running") == 1 then
			vm16.load_cpu(pos, prog_pos, cpu_def)
			cpu_def.on_init(pos, prog_pos)
		end
	end
})

lib.register_SystemHandler(0, function(cpu_pos, address, regA, regB, regC)
	local prog_pos = S2P(M(cpu_pos):get_string("prog_pos"))
	return vm16.putchar(prog_pos, regA) or 0xffff, 500
end)

-------------------------------------------------------------------------------
-- API for I/O nodes
-------------------------------------------------------------------------------
function beduino.register_io_nodes(names)
	for _, name in ipairs(names) do
		table.insert(IONodes, name)
	end
end

function beduino.register_input_address(pos, cpu_pos, address, on_input)
	if pos and cpu_pos and address and on_input then
		local hash = H(cpu_pos)
		Inputs[hash] = Inputs[hash] or {}
		Inputs[hash][address] = {pos = pos, input = on_input}
	end
end

function beduino.register_output_address(pos, cpu_pos, address, on_output)
	if pos and cpu_pos and address and on_output then
		local hash = H(cpu_pos)
		Outputs[hash] = Outputs[hash] or {}
		Outputs[hash][address] = {pos = pos, output = on_output}
	end
end

function beduino.unregister_address(pos, cpu_pos, address)
	if pos and cpu_pos and address then
		local hash = H(cpu_pos)
		Inputs[hash] = Inputs[hash] or {}
		Inputs[hash][address] = nil
	end
end

function beduino.set_event(cpu_pos, address)
	if cpu_pos and address then
		-- Set event variable on address 2
		vm16.poke(cpu_pos, 0x0002, address)
	end
end

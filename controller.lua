--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

   Beduino Controller / CPU

]]--

-- for lazy programmers
local M = minetest.get_meta
local H = minetest.hash_node_position
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = function(s) return minetest.string_to_pos(s) end
local S2T = function(s) return minetest.deserialize(s) or {} end
local T2S = function(t) return minetest.serialize(t) or 'return {}' end

local lib = beduino.lib

local RADIUS = 3    -- for I/O modules
local Inputs = {}   -- [cpu_pos][port] = {node_pos, clbk}
local Outputs = {}  -- [cpu_pos][port] = {node_pos, clbk}
local IONodes = {}  -- Known I/O nodes
local Memory = {["beduino:eeprom2k"] = true, ["beduino:ram2k"] = true, ["beduino:ram4k"] = true}

local Info = [[
              Beduino
              =======

The Beduino controller is used to control and
monitor your machines.
This controller can be programmed in mC,
a C like language.

Learn more about mC on:
https://github.com/joe7575/vm16/wiki

]]

local function find_io_nodes(cpu_pos)
	local pos1 = {x = cpu_pos.x - RADIUS, y = cpu_pos.y - RADIUS, z = cpu_pos.z - RADIUS}
	local pos2 = {x = cpu_pos.x + RADIUS, y = cpu_pos.y + RADIUS, z = cpu_pos.z + RADIUS}
	return minetest.find_nodes_in_area(pos1, pos2, IONodes)
end

local function has_eeprom(pos)
	local inv = M(pos):get_inventory()
	local e2p2k = ItemStack("beduino:eeprom2k")
	return inv:contains_item("memory", e2p2k)
end

local function get_sdcard_code(pos)
	local inv = M(pos):get_inventory()
	local item = ItemStack("vm16:sdcard")
	if inv:contains_item("memory", item) then
		local stack = inv:remove_item("memory", item)
		inv:add_item("memory", stack)
		local data = stack:get_meta():to_table().fields
		return data.text or ""
	end
end

local function ram_size(pos)
	local inv = M(pos):get_inventory()
	local ram2k = ItemStack("beduino:ram2k")
	local ram4k = ItemStack("beduino:ram4k")
	if inv:contains_item("memory", ram4k) and inv:contains_item("memory", ram2k) then
		return 7  -- 8192 words
	elseif inv:contains_item("memory", ram2k) then
		return 6  -- 4096 words
	end
	return 5  -- 2048 words
end

local function on_init_cpu(cpu_pos)
	local out = {}

	out[#out + 1] = "The Controller has:"
	out[#out + 1] = string.format(" - %u K RAM", (2 ^ (ram_size(cpu_pos) + 6)) / 1024)
	if has_eeprom(cpu_pos) then
		out[#out + 1] = " - 2 K EEPROM"
	end

	out[#out + 1] = ""
	out[#out + 1] = "The Controller is connected to:"

    local default = " - nothing yet"
	for _,pos in ipairs(find_io_nodes(cpu_pos)) do
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_init_io then
			local address = ndef.on_init_io(pos, cpu_pos)
			table.insert(out, string.format(" - %s #%d at %s", node.name, address, P2S(pos)))
			default = nil
		end
	end
	table.insert(out, default)
	return table.concat(out, "\n")
end

local function on_start_cpu(cpu_pos)
	for _,pos in ipairs(find_io_nodes(cpu_pos)) do
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.on_start_io then
			ndef.on_start_io(pos, cpu_pos)
		end
		if has_eeprom(cpu_pos) then
			beduino.eeprom_init(cpu_pos)
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

local function get_eeprom_code(stack)
	local name = stack:get_name()
	if name == "beduino:eeprom2k" then
		local meta = stack:get_meta()
		if meta then
			return meta:get_string("code")
		end
	end
end

local function set_eeprom_code(stack, code)
	local name = stack:get_name()
	if name == "beduino:eeprom2k" then
		local meta = stack:get_meta()
		if meta then
			meta:set_string("code", code)
			return true
		end
	end
end

local function formspec()
	return "size[8,7]"..
		"label[3,0;Memory Slots]" ..
		"list[context;memory;3,0.6;2,2;]" ..
		"list[current_player;main;0,3.2;8,4;]" ..
		"button[5.5,1.2;2,0.8;reset;Reset]"
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
		if prog_pos then
			M(pos):set_string("prog_pos", P2S(prog_pos))
		end
		if server_pos then
			local s = on_init_cpu(pos)
			vm16.write_file(server_pos, "info.txt", Info .. s)
		end
	end,
	on_mem_size = function(pos)
		return ram_size(pos)
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

local function start_cpu(pos)
	if vm16.is_loaded(pos) then
		vm16.destroy(pos)
	end
	local mem_size = cpu_def.on_mem_size(pos) or 3
	vm16.create(pos, mem_size)
	if vm16.is_loaded(pos) then
		local h16 = get_sdcard_code(pos)
		if h16 then
			vm16.write_h16(pos, h16)
			vm16.set_pc(pos, 0)
			M(pos):set_string("infotext", "Beduino Controller (running)")
			M(pos):set_int("running", 1)
			on_start_cpu(pos)
			minetest.get_node_timer(pos):start(cpu_def.cycle_time)
		end
	end
end

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
	on_construct = function(pos)
		local inv = M(pos):get_inventory()
		inv:set_size('memory', 4)
	end,
	after_place_node = function(pos, placer)
		M(pos):set_string("infotext", "Beduino Controller")
		M(pos):set_string("owner", placer:get_player_name())
		M(pos):set_string("formspec", formspec())
	end,
	on_timer = function(pos, elapsed)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		return vm16.keep_running(pos, prog_pos, cpu_def)
	end,
	on_receive_fields = function(pos, formname, fields, player)
		if player and minetest.is_protected(pos, player:get_player_name()) then
			return
		end
		start_cpu(pos)
	end,
	after_dig_node = function(pos)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		vm16.unload_cpu(pos, prog_pos)
	end,
	can_dig = function(pos, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("memory")
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local name = stack:get_name()
		local inv = minetest.get_meta(pos):get_inventory()
		if inv:contains_item("memory", {name = name}) then
			return 0
		end
		-- put sdcard is allowed, even if cpu is running
		if name == "vm16:sdcard" then
			return 1
		end
		if vm16.is_loaded(pos) then
			return 0
		end
		if not Memory[name] then
			return 0
		end
		if name == "beduino:ram4k" and not inv:contains_item("memory", {name = "beduino:ram2k"}) then
			return 0
		end
		if name == "beduino:eeprom2k" then
			local code = get_eeprom_code(stack)
			beduino.eeprom_write(pos, code)
		end
		return 1
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		-- take sdcard is allowed, even if cpu is running
		local name = stack:get_name()
		if name == "vm16:sdcard" then
			return 1
		end
		if vm16.is_loaded(pos) then
			return 0
		end
		if name == "beduino:eeprom2k" then
			local inv = minetest.get_meta(pos):get_inventory()
			local stack = inv:get_stack(listname, index)
			local code = beduino.eeprom_read(pos)
			set_eeprom_code(stack, code)
			inv:set_stack(listname, index, stack)
		end
		return stack:get_count()
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
		on_init_cpu(pos)
		local prog_pos = S2P(M(pos):get_string("prog_pos"))
		if M(pos):get_int("running") == 1 then
			vm16.load_cpu(pos, prog_pos, cpu_def)
			if has_eeprom(pos) then
				beduino.eeprom_init(pos)
			end
		end
	end
})

local function on_use(itemstack, user)
	local meta = itemstack:get_meta()
	local tbl = S2T(meta:get_string("code"))

	local out = {}
	for i = 0,31,4 do
		out[#out + 1] = string.format("%04X: %04X %04X %04X %04X",
			i, tbl[i] or 0xFFFF, tbl[i+1] or 0xFFFF, tbl[i+2] or 0xFFFF, tbl[i+3] or 0xFFFF)
	end
	local s = table.concat(out, "\n")
	local formspec = "size[6,3.2]" ..
		"style_type[textarea;font=mono]" ..
		"textarea[0.3,0.3;10,4;;Code:;" .. s .. "]"
	local player_name = user:get_player_name()
	minetest.show_formspec(player_name, "beduino:eeprom2k", formspec)
	return itemstack
end

minetest.register_craftitem("beduino:eeprom2k", {
	description = "EEPROM 2K",
	inventory_image = "beduino_eeprom2k.png",
	on_use = on_use,
})

minetest.register_craftitem("beduino:ram2k", {
	description = "RAM 2K",
	inventory_image = "beduino_ram2k.png",
})

minetest.register_craftitem("beduino:ram4k", {
	description = "RAM 4K",
	inventory_image = "beduino_ram4k.png",
})

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

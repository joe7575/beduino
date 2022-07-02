--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	EEPROM functions

]]--

local M = minetest.get_meta
local H = minetest.hash_node_position
local S2T = function(s) return minetest.deserialize(s) or {} end
local T2S = function(t) return minetest.serialize(t) or 'return {}' end

local Cache = {}

local function e2p_erase(cpu_pos, address, regA, regB, regC)
	local hash = H(cpu_pos)
	local meta = M(cpu_pos)

	if Cache[hash] then
		Cache[hash] = {}
		meta:set_string("eeprom", T2S(Cache[hash]))
		return 1, 10000  -- expensive call
	end
	return 0
end

local function e2p_read_value(cpu_pos, address, regA, regB, regC)
	local hash = H(cpu_pos)
	local meta = M(cpu_pos)

	if Cache[hash] then
		return Cache[hash][regA % 2048] or 0xFFFF, 200
	end
	return 0xFFFF
end

local function e2p_write_value(cpu_pos, address, regA, regB, regC)
	local hash = H(cpu_pos)
	local meta = M(cpu_pos)
	
	if Cache[hash] then
		Cache[hash][regA % 2048] = regB
		meta:set_string("eeprom", T2S(Cache[hash]))
		return 1, 5000  -- expensive call
	end
	return 0
end

local function e2p_read_block(cpu_pos, address, regA, regB, regC)
	local hash = H(cpu_pos)
	local meta = M(cpu_pos)

	if Cache[hash] then
		local resp = {}
		local last = regA + math.min(regC, 32) - 1
		for i = regA, last do
			print("i", i, Cache[hash][i % 2048])
			resp[#resp + 1] = Cache[hash][i % 2048] or 0xFFFF
		end
		vm16.write_mem(cpu_pos, regB, resp)
		return 1, 400
	end
	return 0xFFFF
end

local function e2p_write_block(cpu_pos, address, regA, regB, regC)
	local hash = H(cpu_pos)
	local meta = M(cpu_pos)

	if Cache[hash] then
		local num = math.min(regC, 32)
		local data = vm16.read_mem(cpu_pos, regB, num)
		for i, val in ipairs(data) do
			Cache[hash][(i - 1 + regA) % 2048] = val
		end
		meta:set_string("eeprom", T2S(Cache[hash]))
		return 1, 10000  -- expensive call
	end
	return 0
end

beduino.lib.register_SystemHandler(0x60, e2p_erase)
beduino.lib.register_SystemHandler(0x61, e2p_read_value)
beduino.lib.register_SystemHandler(0x62, e2p_write_value)
beduino.lib.register_SystemHandler(0x63, e2p_read_block)
beduino.lib.register_SystemHandler(0x64, e2p_write_block)


local eeprom_c = [[
// Erase the EEPROM
func e2p_erase() {
  return system(0x60, 0);
}

// Returns the value from the given EEPROM address
func e2p_read_value(address) {
  return system(0x61, address);
}

// Write a value to the given EEPROM address
func e2p_write_value(address, value) {
  return system(0x62, address, value);
}

// Returns the number of values from the EEPROM starting 
// at the given address.
func e2p_read_block(address, buff, num) {
  return system(0x63, address, buff, num);
}

// Write given values to the EEPROM starting 
// at the given address.
func e2p_write_block(address, buff, num) {
  return system(0x64, address, buff, num);
}
]]

vm16.register_ro_file("beduino", "eeprom.c",   eeprom_c)

function beduino.eeprom_init(cpu_pos)
	local hash = H(cpu_pos)
	local meta = M(cpu_pos)

	if not meta:contains("eeprom") then
		meta:set_string("eeprom", T2S({}))
	end
	Cache[hash] = S2T(meta:get_string("eeprom"))
	
	meta:mark_as_private("eeprom")
end

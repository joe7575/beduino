--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	OS functions

]]--

local function get_timeofday(cpu_pos, address, regA, regB, regC)
	local t = minetest.get_timeofday()
	return math.floor(t * 1440)
end

local function get_day_count(cpu_pos, address, regA, regB, regC)
	return minetest.get_day_count() % 0x10000
end

local function get_sec_time(cpu_pos, address, regA, regB, regC)
	return minetest.get_gametime() % 0x10000
end

local function get_time(cpu_pos, address, regA, regB, regC)
	return math.floor(minetest.get_us_time() / 100000) % 0x10000
end

local function get_random(cpu_pos, address, regA, regB, regC)
	return math.random(regA, regB)
end

local function chat_msg(cpu_pos, address, regA, regB, regC)
	local text = vm16.read_ascii(cpu_pos, regA, 40)
	local owner = minetest.get_meta(cpu_pos):get_string("owner")
	minetest.chat_send_player(owner, "[Beduino] "..text)
	return 1
end

local function get_description(cpu_pos, address, regA, regB, regC)
	local name = vm16.read_ascii(cpu_pos, regA, 32)
	local lang_code = vm16.read_ascii(cpu_pos, regB, 4)
	local ndef = minetest.registered_nodes[name] or minetest.registered_items[name]
		or minetest.registered_craftitems[name]
	if ndef then
		local text = minetest.get_translated_string(lang_code, ndef.description)
		vm16.write_ascii(cpu_pos, regC, text)
		return 1
	else
		vm16.write_ascii(cpu_pos, regC, "unknown")
		return 0
	end
end

beduino.lib.register_SystemHandler(0x20, get_timeofday)
beduino.lib.register_SystemHandler(0x21, get_day_count)
beduino.lib.register_SystemHandler(0x22, get_sec_time)
beduino.lib.register_SystemHandler(0x23, get_time)
beduino.lib.register_SystemHandler(0x24, get_random)
beduino.lib.register_SystemHandler(0x25, chat_msg)
beduino.lib.register_SystemHandler(0x26, get_description)

local os_c = [[
// Returns the time of day in minutes(0 - 1439)
func get_timeofday() {
  return system(0x20, 0);
}

// Returns number days elapsed since world was created.
func get_day_count() {
  return system(0x21, 0);
}

// Returns the time in seconds (0 - 65535)
func get_sec_time() {
  return system(0x22, 0);
}

// Returns the time in 100 ms resolution (0 - 65535)
func get_time() {
  return system(0x23, 0);
}

// Returns a pseudo-random number x such that l <= x <= u
func get_random(l, u) {
  system(0x24, l, u);
}

// Sends yourself a chat message (max. length is 40 words)
func chat_msg(text) {
  system(0x25, text);
}

// Copy the description text of 'name' to 'desc_buff'
// 'lang_code' is needed for the translation (e.g. "en" or "de")
func get_description(name, lang_code, desc_buff) {
  system(0x26, name, lang_code, desc_buff);
}
]]

vm16.register_ro_file("beduino", "sys/os.c",   os_c)

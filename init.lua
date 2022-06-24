--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

if not minetest.global_exists("vm16") or vm16.version < 3.5 then
	minetest.log("error", "[Beduino] The mod requires vm16 version 3.5 or newer!")
	return
end
if minetest.global_exists("techage") and techage.version < 1.08 then
	minetest.log("error", "[Beduino] The mod requires techage version 1.08 or newer!")
	return
end

beduino = {}
beduino.lib = {}
beduino.comm = {}
beduino.tech = {}

local MP = minetest.get_modpath("beduino")

dofile(MP.."/lib/lib.lua")
dofile(MP.."/lib/kv_store.lua")
dofile(MP.."/lib/dispatch.lua")
dofile(MP.."/lib/os.lua")
dofile(MP.."/lib/files.lua")

dofile(MP.."/controller.lua")

dofile(MP.."/com/broker.lua")
dofile(MP.."/com/router.lua")
dofile(MP.."/com/files.lua")

if minetest.global_exists("techage") or minetest.global_exists("tubelib") then
	dofile(MP.."/tech/io_ports.lua")
	dofile(MP.."/tech/wrapper.lua")
	dofile(MP.."/tech/commands.lua")
	dofile(MP.."/tech/io_module.lua")
	dofile(MP.."/tech/inp_module.lua")
	dofile(MP.."/tech/sys_calls.lua")
	dofile(MP.."/tech/files.lua")
	dofile(MP.."/tech/recipes.lua")
	dofile(MP.."/manual/techage_DE.lua")
	dofile(MP.."/manual/techage_EN.lua")
	techage.add_manual_items({beduino_controller = "beduino_controller_inventory.png"})
end

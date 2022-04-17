--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

if not minetest.global_exists("vm16") or vm16.version < 3.3 then
	minetest.log("error", "[Beduino] The mod requires vm16 version 3.3 or newer!")
	return
end

beduino = {}
beduino.lib = {}
beduino.io = {}

local MP = minetest.get_modpath("beduino")

dofile(MP.."/lib/lib.lua")
dofile(MP.."/lib/command.lua")
dofile(MP.."/lib/wrapper.lua")
dofile(MP.."/lib/files.lua")
dofile(MP.."/lib/exchange.lua")
dofile(MP.."/controller.lua")
dofile(MP.."/io/system.lua")
dofile(MP.."/io/io_module.lua")
dofile(MP.."/recipes.lua")

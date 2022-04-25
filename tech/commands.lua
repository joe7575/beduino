--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Techage/TechPack commands and states

]]--


if minetest.global_exists("techage") then

	beduino.lib.register_cmnd("off")
	beduino.lib.register_cmnd("on")
	beduino.lib.register_cmnd("green")
	beduino.lib.register_cmnd("amber")
	beduino.lib.register_cmnd("red")
	beduino.lib.register_cmnd("state")
	beduino.lib.register_cmnd("fuel")
	beduino.lib.register_cmnd("depth")
	beduino.lib.register_cmnd("load")
	beduino.lib.register_cmnd("delivered")
	beduino.lib.register_cmnd("count")
	beduino.lib.register_cmnd("running")
	beduino.lib.register_cmnd("blocked")
	beduino.lib.register_cmnd("standby")
	beduino.lib.register_cmnd("nopower")
	beduino.lib.register_cmnd("fault")
	beduino.lib.register_cmnd("stopped")
	beduino.lib.register_cmnd("unloaded")
	beduino.lib.register_cmnd("inactive")
	beduino.lib.register_cmnd("empty")
	beduino.lib.register_cmnd("loaded")
	beduino.lib.register_cmnd("full")
	beduino.lib.register_cmnd("flowrate")
	beduino.lib.register_cmnd("action")
	beduino.lib.register_cmnd("stacks")
	beduino.lib.register_cmnd("count")
	beduino.lib.register_cmnd("output")
	beduino.lib.register_cmnd("input")

elseif minetest.global_exists("tubelib") then

	beduino.lib.register_cmnd("off")
	beduino.lib.register_cmnd("on")
	beduino.lib.register_cmnd("green")
	beduino.lib.register_cmnd("amber")
	beduino.lib.register_cmnd("red")
	beduino.lib.register_cmnd("state")
	beduino.lib.register_cmnd("close")
	beduino.lib.register_cmnd("open")
	beduino.lib.register_cmnd("running")
	beduino.lib.register_cmnd("blocked")
	beduino.lib.register_cmnd("standby")
	beduino.lib.register_cmnd("defect")
	beduino.lib.register_cmnd("fault")
	beduino.lib.register_cmnd("stopped")
	beduino.lib.register_cmnd("full")
	beduino.lib.register_cmnd("empty")

end

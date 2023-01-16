--[[

	Beduino
	=======

	Copyright (C) 2022-2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TechPack commands and states

]]--

if minetest.global_exists("tubelib") then

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

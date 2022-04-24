--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Mod recipes

]]--

if minetest.global_exists("techage") then

	minetest.register_craft({
		output = "vm16:programmer",
		recipe = {
			{"basic_materials:steel_strip", "default:obsidian_glass", ""},
			{"basic_materials:ic", "basic_materials:ic", "basic_materials:ic"},
			{"basic_materials:steel_strip", "basic_materials:gold_wire", "basic_materials:copper_wire"},
		},
	})

	minetest.register_craft({
		output = "vm16:server",
		recipe = {
			{"dye:black", "basic_materials:copper_wire", "dye:black"},
			{"basic_materials:ic", "basic_materials:ic", "basic_materials:ic"},
			{"default:steelblock", "basic_materials:gold_wire", "default:steelblock"},
		},
	})

	minetest.register_craft({
		output = "beduino:controller",
		recipe = {
			{"", "", ""},
			{"default:steelblock", "basic_materials:gold_wire", "default:steelblock"},
			{"basic_materials:ic", "basic_materials:ic", "basic_materials:ic"},
		},
	})

	minetest.register_craft({
		output = "beduino:io_module",
		recipe = {
			{"", "group:wood", ""},
			{"", "default:obsidian_glass", ""},
			{"", "basic_materials:ic", ""},
		},
	})

elseif minetest.global_exists("tubelib") then

	minetest.register_craft({
		output = "vm16:programmer",
		recipe = {
			{"basic_materials:steel_strip", "default:obsidian_glass", ""},
			{"basic_materials:ic", "basic_materials:ic", "basic_materials:ic"},
			{"basic_materials:steel_strip", "basic_materials:gold_wire", "basic_materials:copper_wire"},
		},
	})

	minetest.register_craft({
		output = "vm16:server",
		recipe = {
			{"dye:black", "basic_materials:copper_wire", "dye:black"},
			{"basic_materials:ic", "basic_materials:ic", "basic_materials:ic"},
			{"default:steelblock", "basic_materials:gold_wire", "default:steelblock"},
		},
	})

	minetest.register_craft({
		output = "beduino:controller",
		recipe = {
			{"", "", ""},
			{"default:steelblock", "basic_materials:gold_wire", "default:steelblock"},
			{"basic_materials:ic", "basic_materials:ic", "basic_materials:ic"},
		},
	})

	minetest.register_craft({
		output = "beduino:io_module",
		recipe = {
			{"", "group:wood", ""},
			{"", "default:obsidian_glass", ""},
			{"", "basic_materials:ic", ""},
		},
	})

end
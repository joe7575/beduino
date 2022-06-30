--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	14 segment module

]]--


-- for lazy programmers
local M = minetest.get_meta
local N = pdp13.get_nvm

local lib = beduino.lib
local tech = beduino.tech

local DESCRIPTION = "Beduino 14-Segment"

local function generate_texture(code, background)
	local tbl = {background}
	for i = 1,14 do
		if vm16.testbit(code, i-1) then
			tbl[#tbl + 1] = "beduino_segment" .. i .. ".png"
		end
	end
	return table.concat(tbl, "^")
end

local function register_segment(name, background)
	minetest.register_node(name, {
		description = DESCRIPTION,
		inventory_image = background .. "^beduino_segment1.png^" ..
			"beduino_segment2.png^beduino_segment3.png^beduino_segment4.png^" ..
			"beduino_segment5.png^beduino_segment6.png",
		tiles = {
			"beduino_segment_side.png",
		},
		drawtype = "nodebox",
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "wallmounted",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.01, 1.0},
			},
		},
		light_source = 6,

		display_entities = {
			["techage:display_entity"] = {
				depth = -0.02,
				height = 0.25,
				on_display_update = function(pos, objref)
					pos = vector.round(pos)
					local code = N(pos).code or 0
					objref:set_properties({
						textures = {generate_texture(code, background)},
						visual_size = {x=0.98, y=0.98*1.5},
					})
				end,
			},
		},

		after_place_node = function(pos, placer)
			local meta = M(pos)
			local own_num = tech.add_node(pos, name)
			meta:set_string("node_number", own_num)  -- for techage
			meta:set_string("own_number", own_num)  -- for tubelib
			lib.infotext(meta, DESCRIPTION)
			lcdlib.update_entities(pos)
		end,

		after_dig_node = function(pos, oldnode, oldmetadata)
			tech.del_mem(pos)
		end,

		on_place = lcdlib.on_place,
		on_construct = lcdlib.on_construct,
		on_destruct = lcdlib.on_destruct,
		on_rotate = lcdlib.on_rotate,
		groups = {cracky=2, crumbly=2},
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
	})
end

register_segment("beduino:14segment1", "beduino_segment_bg0.png")
register_segment("beduino:14segment2", "beduino_segment_bg1.png")
register_segment("beduino:14segment3", "beduino_segment_bg2.png")

beduino.tech.register_node({"beduino:14segment1", "beduino:14segment2", "beduino:14segment3"}, {
	on_recv_message = function(pos, src, topic, payload)
		if pdp13.tubelib then
			pos, src, topic, payload = pos, "000", src, topic
		end
		if topic == "value" then
			N(pos).code = tonumber(payload) or 0
			local now = techage.SystemTime
			local mem = pdp13.get_mem(pos)
			if (mem.last_message or 0) + .5 < now then
				lcdlib.update_entities(pos)
				mem.last_message = now
			end
			return true
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		if topic == 16 then
			N(pos).code = payload[1] or 0
			local now = techage.SystemTime
			local mem = pdp13.get_mem(pos)
			if (mem.last_message or 0) + .5 < now then
				lcdlib.update_entities(pos)
				mem.last_message = now
			end
			return 0
		else
			return 2
		end
	end,
})

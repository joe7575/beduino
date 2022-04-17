 --[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Wrapper for alternative support of Techage and TechPack

]]--

local MemStore = {}

local function stub() end

if minetest.global_exists("techage") then

	beduino.lib.tubelib = false
	beduino.lib.get_nvm =  techage.get_nvm
	beduino.lib.get_mem = techage.get_mem
	beduino.lib.del_mem = techage.del_mem
	beduino.lib.add_manual_items = techage.add_manual_items
	beduino.lib.add_to_manual = techage.add_to_manual
	beduino.lib.send_single = techage.send_single
	beduino.lib.get_node_info = techage.get_node_info
	beduino.lib.add_node = techage.add_node
	beduino.lib.remove_node = techage.remove_node
	beduino.lib.register_node = techage.register_node
	beduino.lib.check_numbers = techage.check_numbers

elseif minetest.global_exists("tubelib") then

	beduino.lib.tubelib = true
	beduino.lib.get_nvm =  tubelib2.get_mem
	beduino.lib.get_mem = function(pos)
		local hash = minetest.hash_node_position(pos)
		if not MemStore[hash] then
			MemStore[hash] = {}
		end
		return MemStore[hash]
	end
	beduino.lib.del_mem = tubelib2.del_mem
	beduino.lib.add_manual_items = stub
	beduino.lib.add_to_manual = stub
	beduino.lib.send_single = function(src, number, topic, payload)
		if type(number) == "number" then
			number = string.format("%.04u", number)
		end
		--print("send_single", number, topic, payload)
		return tubelib.send_request(number, topic, payload)
	end
	beduino.lib.get_node_info = function(number)
		number = string.format("%.04u", tonumber(number) or 0)
		return tubelib.get_node_info(number)
	end
	beduino.lib.add_node = tubelib.add_node
	beduino.lib.remove_node = tubelib.remove_node
	beduino.lib.register_node = function(names, node_definition)
		local add_names = {unpack(names, 2)}
		tubelib.register_node(names[1], add_names, node_definition)
	end
	beduino.lib.check_numbers = tubelib.check_numbers

end


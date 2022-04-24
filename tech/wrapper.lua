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

	beduino.tech.tubelib = false
	beduino.tech.get_nvm =  techage.get_nvm
	beduino.tech.get_mem = techage.get_mem
	beduino.tech.del_mem = techage.del_mem
	beduino.tech.add_manual_items = techage.add_manual_items
	beduino.tech.add_to_manual = techage.add_to_manual
	beduino.tech.send_single = techage.send_single
	beduino.tech.get_node_info = techage.get_node_info
	beduino.tech.add_node = techage.add_node
	beduino.tech.remove_node = techage.remove_node
	beduino.tech.register_node = techage.register_node
	beduino.tech.check_numbers = techage.check_numbers

elseif minetest.global_exists("tubelib") then

	beduino.tech.tubelib = true
	beduino.tech.get_nvm =  tubelib2.get_mem
	beduino.tech.get_mem = function(pos)
		local hash = minetest.hash_node_position(pos)
		if not MemStore[hash] then
			MemStore[hash] = {}
		end
		return MemStore[hash]
	end
	beduino.tech.del_mem = tubelib2.del_mem
	beduino.tech.add_manual_items = stub
	beduino.tech.add_to_manual = stub
	beduino.tech.send_single = function(src, number, topic, payload)
		if type(number) == "number" then
			number = string.format("%.04u", number)
		end
		--print("send_single", number, topic, payload)
		return tubelib.send_request(number, topic, payload)
	end
	beduino.tech.get_node_info = function(number)
		number = string.format("%.04u", tonumber(number) or 0)
		return tubelib.get_node_info(number)
	end
	beduino.tech.add_node = tubelib.add_node
	beduino.tech.remove_node = tubelib.remove_node
	beduino.tech.register_node = function(names, node_definition)
		local add_names = {unpack(names, 2)}
		tubelib.register_node(names[1], add_names, node_definition)
	end
	beduino.tech.check_numbers = tubelib.check_numbers

end


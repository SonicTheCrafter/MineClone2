local brewhelp = "This item is used in potion brewing."

minetest.register_craftitem("mcl_potions:fermented_spider_eye", {
	description = "Fermented Spider Eye",
	_doc_items_longdesc = brewhelp,
	wield_image = "mcl_potions_spider_eye_fermented.png",
	inventory_image = "mcl_potions_spider_eye_fermented.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_potions:fermented_spider_eye",
	recipe = { "mcl_mushrooms:mushroom_brown", "mcl_core:sugar", "mcl_mobitems:spider_eye" },
})

minetest.register_craftitem("mcl_potions:glass_bottle", {
	description = "Glass Bottle",
	_doc_items_longdesc = "A glass bottle is used as a container for potions and can be used to collect water directly.",
	_doc_items_usagehelp = "To collect water, it on a cauldron with water (which removes a level of water) or a water source (which removes no water).",
	inventory_image = "mcl_potions_potion_bottle_empty.png",
	wield_image = "mcl_potions_potion_bottle_empty.png",
	groups = {brewitem=1},
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer :get_player_control().sneak then
				if def and def.on_rightclick then
					return def.on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			-- Try to fill glass bottle with water
			local get_water = false
			if not def then
				-- Unknown node: no-op
			elseif def.groups and def.groups.water and def.liquidtype == "source" then
				-- Water source
				get_water = true
			-- Or reduce water level of cauldron by 1
			elseif node.name == "mcl_cauldrons:cauldron_3" then
				get_water = true
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_2"})
			elseif node.name == "mcl_cauldrons:cauldron_2" then
				get_water = true
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_1"})
			elseif node.name == "mcl_cauldrons:cauldron_1" then
				get_water = true
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron"})
			end
			if get_water then
				-- Replace with water bottle, if possible, otherwise
				-- place the water potion at a place where's space
				local water_bottle = ItemStack("mcl_potions:potion_water")
				minetest.sound_play("mcl_potions_bottle_fill", {pos=pointed_thing.under, gain=0.5, max_hear_range=16})
				if itemstack:get_count() == 1 then
					return water_bottle
				else
					local inv = placer:get_inventory()
					if inv:room_for_item("main", water_bottle) then
						inv:add_item("main", water_bottle)
					else
						minetest.add_item(placer:getpos(), water_bottle)
					end
					itemstack:take_item()
				end
			end
		end
		return itemstack
	end,
})

minetest.register_craft( {
	output = "mcl_potions:glass_bottle 3",
	recipe = {
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "", "mcl_core:glass", "" }
	}
})

-- Tempalte function for creating images of filled potions
-- - colorstring must be a ColorString of form “#RRGGBB”, e.g. “#0000FF” for blue.
-- - opacity is optional opacity from 0-255 (default: 127)
local potion_image = function(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_potion_bottle_drinkable.png^(mcl_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity)..")"
end

-- Itemstring of potions is “mcl_potions:potion_<NBT Potion Tag>”

minetest.register_craftitem("mcl_potions:potion_water", {
	description = "Water Bottle",
	_doc_items_longdesc = "Water bottles can be used to brew potions and to fill cauldrons. Drinking water has no effect.",
	_doc_items_usagehelp = "Wield it and rightclick to drink it. Rightclick a cauldron to put the water into the cauldron.",
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if def and def.on_rightclick then
					return def.on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			-- Increase water level of cauldron by 1
			if node.name == "mcl_cauldrons:cauldron" then
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_1"})
				minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16})
				return "mcl_potions:glass_bottle"
			elseif node.name == "mcl_cauldrons:cauldron_1" then
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_2"})
				minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16})
				return "mcl_potions:glass_bottle"
			elseif node.name == "mcl_cauldrons:cauldron_2" then
				minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_3"})
				minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16})
				return "mcl_potions:glass_bottle"
			end
		end

		-- Drink the water by default
		return minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, placer, pointed_thing)
	end,
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})

local how_to_drink = "To drink it, wield it, then rightclick."

minetest.register_craftitem("mcl_potions:potion_awkward", {
	description = "Awkward Potion",
	_doc_items_longdesc = "This potion has an awkward taste and is used for brewing more potions. Drinking it has no effect.",
	_doc_items_usagehelp = how_to_drink,
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1},
	on_place = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})
minetest.register_craftitem("mcl_potions:potion_mundane", {
	description = "Mundane Potion",
	_doc_items_longdesc = "This potion has a clean taste and is used for brewing more potions. Drinking it has no effect.",
	_doc_items_usagehelp = how_to_drink,
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1},
	on_place = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})
minetest.register_craftitem("mcl_potions:potion_thick", {
	description = "Thick Potion",
	_doc_items_longdesc = "This potion has a bitter taste and is used for brewing more potions. Drinking it has no effect.",
	_doc_items_usagehelp = how_to_drink,
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1},
	on_place = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})

minetest.register_craftitem("mcl_potions:speckled_melon", {
	description = "Glistering Melon",
	_doc_items_longdesc = brewhelp,
	stack_max = 64,
	groups = { brewitem = 1 },
	inventory_image = "mcl_potions_melon_speckled.png",
})

minetest.register_craft({
	output = "mcl_potions:speckled_melon",
	recipe = {
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_farming:melon_item', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
	}
})

minetest.register_craftitem("mcl_potions:dragon_breath", {
	description = "Dragon's Breath",
	_doc_items_longdesc = brewhelp,
	wield_image = "mcl_potions_dragon_breath.png",
	inventory_image = "mcl_potions_dragon_breath.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

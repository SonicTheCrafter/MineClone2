local PRESSURE_PLATE_INTERVAL = 0.04

local pp_box_off = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
}

local pp_box_on = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7.5/16, 7/16 },
}

local pplate_rules = {
	{x=-1, y=0, z=0},
	{x=1, y=0, z=0},
	{x=0, y=0, z=-1},
	{x=0, y=0, z=1},

	{x=-1, y=-1, z=0},
	{x=1, y=-1, z=0},
	{x=0, y=-1, z=-1},
	{x=0, y=-1, z=1},

	{x=0, y=-1, z=0},
	{x=0, y=-2, z=0},
	{x=0, y=1, z=0},
}

local function pp_on_timer(pos, elapsed)
	local node = minetest.get_node(pos)
	local basename = minetest.registered_nodes[node.name].pressureplate_basename
	local activated_by = minetest.registered_nodes[node.name].pressureplate_activated_by

	-- This is a workaround for a strange bug that occurs when the server is started
	-- For some reason the first time on_timer is called, the pos is wrong
	if not basename then return end

	if activated_by == nil then
		activated_by = { any = true }
	end

	local obj_does_activate = function(obj, activated_by)
		if activated_by.any then
			return true
		elseif activated_by.mob and obj:get_luaentity() and obj:get_luaentity()._cmi_is_mob == true then
			return true
		elseif activated_by.player and obj:is_player() then
			return true
		else
			return false
		end
	end

	local objs = minetest.get_objects_inside_radius(pos, 1)

	if node.name == basename .. "_on" then
		local disable
		if #objs == 0 then
			disable = true
		elseif not activated_by.any then
			disable = true
			for k, obj in pairs(objs) do
				if obj_does_activate(obj, activated_by) then
					disable = false
					break
				end
			end
		end
		if disable then
			minetest.set_node(pos, {name = basename .. "_off"})
			mesecon.receptor_off(pos, pplate_rules)
		end
	elseif node.name == basename .. "_off" then
		for k, obj in pairs(objs) do
			local objpos = obj:getpos()
			if obj_does_activate(obj, activated_by) then
				if objpos.y > pos.y-1 and objpos.y < pos.y then
					minetest.set_node(pos, {name = basename .. "_on"})
					mesecon.receptor_on(pos, pplate_rules)
					break
				end
			end
		end
	end
	return true
end

-- Register a Pressure Plate
-- basename:    base name of the pressure plate
-- description:	description displayed in the player's inventory
-- textures_off:textures of the pressure plate when inactive
-- textures_on:	textures of the pressure plate when active
-- image_w:	wield image of the pressure plate
-- image_i:	inventory image of the pressure plate
-- recipe:	crafting recipe of the pressure plate
-- sounds:	sound table (like in minetest.register_node)
-- plusgroups:	group memberships (attached_node=1 and not_in_creative_inventory=1 are already used)
-- activated_by: optinal table with elements denoting by which entities this pressure plate is triggered
--		Possible table fields:
--		* player=true: Player
--		* mob=true: Mob
--		By default, is triggered by all entities
-- longdesc:	Customized long description for the in-game help (if omitted, a dummy text is used)

function mesecon.register_pressure_plate(basename, description, textures_off, textures_on, image_w, image_i, recipe, sounds, plusgroups, activated_by, longdesc)
	local groups_off = table.copy(plusgroups)
	groups_off.attached_node = 1
	groups_off.dig_by_piston = 1
	local groups_on = table.copy(groups_off)
	groups_on.not_in_creative_inventory = 1
	if not longdesc then
		longdesc = "A pressure plate is a redstone component which supplies its surrounding blocks with redstone power while someone or something rests on top of it."
	end

	mesecon.register_node(basename, {
		drawtype = "nodebox",
		inventory_image = image_i,
		wield_image = image_w,
		paramtype = "light",
		walkable = false,
	    	description = description,
		on_timer = pp_on_timer,
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
		sounds = sounds,

		pressureplate_basename = basename,
		pressureplate_activated_by = activated_by,
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	},{
		node_box = pp_box_off,
		selection_box = pp_box_off,
		groups = groups_off,
		tiles = textures_off,

		mesecons = {receptor = { state = mesecon.state.off, rules = pplate_rules }},
		_doc_items_longdesc = longdesc,
	},{
		node_box = pp_box_on,
		selection_box = pp_box_on,
		groups = groups_on,
		tiles = textures_on,

		mesecons = {receptor = { state = mesecon.state.on, rules = pplate_rules }},
		_doc_items_create_entry = false,
	})

	minetest.register_craft({
		output = basename .. "_off",
		recipe = recipe,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", basename .. "_off", "nodes", basename .. "_on")
	end
end

mesecon.register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_wood",
	"Wooden Pressure Plate",
	{"default_wood.png"},
	{"default_wood.png"},
	"default_wood.png",
	nil,
	{{"group:wood", "group:wood"}},
	mcl_sounds.node_sound_wood_defaults(),
	{axey=1, material_wood=1},
	nil,
	"A wooden pressure plate is a redstone component which supplies its surrounding blocks with redstone power while any movable object (including dropped items, players and mobs) rests on top of it.")



mesecon.register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_stone",
	"Stone Pressure Plate",
	{"default_stone.png"},
	{"default_stone.png"},
	"default_stone.png",
	nil,
	{{"mcl_core:stone", "mcl_core:stone"}},
	mcl_sounds.node_sound_stone_defaults(),
	{pickaxey=1, material_stone=1},
	{ player = true, mob = true },
	"A stone pressure plate is a redstone component which supplies its surrounding blocks with redstone power while a player or mob stands on top of it. It is not triggered by anything else.")

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_pressureplates:pressure_plate_wood_off",
	burntime = 15
})


-- Liquids: Water and lava

local WATER_ALPHA = 179
local WATER_VISC = 1
local LAVA_VISC = 7

minetest.register_node("mcl_core:water_flowing", {
	description = "Flowing Water",
	_doc_items_create_entry = false,
	wield_image = "default_water_flowing_animated.png^[verticalframe:64:0",
	drawtype = "flowingliquid",
	tiles = {"default_water_flowing_animated.png^[verticalframe:64:0"},
	special_tiles = {
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
		{
			image="default_water_flowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
	},
	sounds = mcl_sounds.node_sound_water_defaults(table),
	alpha = WATER_ALPHA,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_core:water_flowing",
	liquid_alternative_source = "mcl_core:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	post_effect_color = {a=192, r=0x03, g=0x3C, b=0x5C},
	groups = { water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1, freezes=1, melt_around=1, dig_by_piston=1},
	_mcl_blast_resistance = 500,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

minetest.register_node("mcl_core:water_source", {
	description = "Still Water",
	_doc_items_entry_name = "Water",
	_doc_items_longdesc =
[[Water is abundant in oceans and also appears in a few springs in the ground. You can swim easily in water, but you need to catch your breath from time to time.
Water interacts with lava in various ways:
• When water is directly above or horizontally next to still lava, the lava turns into obsidian.
• When flowing water touches flowing lava either from above or horizontally, the lava turns into cobblestone.
• When water is directly below lava, the water turns into stone.]],
	_doc_items_hidden = false,
	drawtype = "liquid",
	tiles = {
		{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name="default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	sounds = mcl_sounds.node_sound_water_defaults(table),
	alpha = WATER_ALPHA,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:water_flowing",
	liquid_alternative_source = "mcl_core:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	post_effect_color = {a=192, r=0x03, g=0x3C, b=0x5C},
	stack_max = 64,
	groups = { water=3, liquid=3, puts_out_fire=1, freezes=1, not_in_creative_inventory=1, dig_by_piston=1},
	_mcl_blast_resistance = 500,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

minetest.register_node("mcl_core:lava_flowing", {
	description = "Flowing Lava",
	_doc_items_create_entry = false,
	wield_image = "default_lava_flowing_animated.png^[verticalframe:64:0",
	drawtype = "flowingliquid",
	tiles = {"default_lava_flowing_animated.png^[verticalframe:64:0"},
	special_tiles = {
		{
			image="default_lava_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=6.6}
		},
		{
			image="default_lava_flowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=6.6}
		},
	},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "flowingliquid",
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	--[[ Drowning in Minecraft deals 2 damage per second.
	In Minetest, drowning damage is dealt every 2 seconds so this
	translates to 4 drowning damage ]]
	drowning = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4*2,
	post_effect_color = {a=255, r=208, g=73, b=10},
	groups = { lava=3, liquid=2, destroys_items=1, not_in_creative_inventory=1, dig_by_piston=1},
	_mcl_blast_resistance = 500,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

minetest.register_node("mcl_core:lava_source", {
	description = "Still Lava",
	_doc_items_entry_name = "Lava",
	_doc_items_longdesc =
[[Lava is hot and rather dangerous. Don't touch it, it will hurt you a lot and it is hard to get out.
Still lava sets fire to a couple of air blocks above when they're next to a flammable block.
Lava interacts with water various ways:
• When still lava is directly below or horizontally next to water, the lava turns into obsidian.
• When flowing water touches flowing lava either from above or horizontally, the lava turns into cobblestone.
• When lava is directly above water, the water turns into stone.]],
	drawtype = "liquid",
	tiles = {
		{name="default_lava_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	special_tiles = {
		-- New-style lava source material (mostly unused)
		{
			name="default_lava_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0},
			backface_culling = false,
		}
	},
	paramtype = "light",
	sunlight_propagates = true,
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4*2,
	post_effect_color = {a=255, r=208, g=73, b=10},
	stack_max = 64,
	groups = { lava=3, liquid=2, destroys_items=1, not_in_creative_inventory=1, dig_by_piston=1},
	_mcl_blast_resistance = 500,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

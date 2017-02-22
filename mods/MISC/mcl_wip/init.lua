local wip_items = {
	"mcl_boats:boat_dark",
	"mcl_boats:boat_spruce",
	"mcl_boats:boat_acacia",
	"mcl_boats:boat_jungle",
	"mcl_boats:boat_birch",
	"mcl_boats:boat",
	"mcl_anvils:anvil",
	"mcl_anvils:anvil_damage_1",
	"mcl_anvils:anvil_damage_2",
	"mcl_core:junglesapling",
	"mcl_core:darksapling",
	"mcl_core:birchsapling",
	"mcl_core:sprucesapling",
	"mcl_core:acaciasapling",
	"mcl_core:apple_gold",
	"mcl_end:ender_eye",
	"mcl_end:chorus_fruit",
	"mcl_end:chorus_flower",
	"mcl_end:chorus_flower_dead",
	"mcl_flowers:peony",
	"mcl_fishing:fishing_rod",
	"mcl_fishing:pufferfish_raw",
	"mcl_maps:filled_map",
	"mcl_maps:empty_map",
	"mcl_mobitems:rotten_flesh",
	"mcl_minecarts:golden_rail",
	"mcl_sponges:sponge",
	"mcl_farming:mushroom_red",
	"mcl_farming:mushroom_brown",
	"gemalde:node_1",
	"mcl_observers:observer",
}

for i=1,#wip_items do
	local def = minetest.registered_items[wip_items[i]]
	if not def then
		minetest.log("error", "[mcl_wip] Unknown item: "..wip_items[i])
		break
	end
	local new_description = def.description
	new_description = new_description .. "\n"..core.colorize("#FF0000", "(WIP)")
	minetest.override_item(wip_items[i], { description = new_description })
end
mcl_loot = {}

--[[
Select a number of itemstacks out of a pool of treasure definitions randomly.

Parameters:
* loot_definitions: Probabilities and information about the loot to select. Syntax:

{
	stacks_min = 1,	-- Minimum number of item stacks to get. Default: 1
	stacks_max = 3, -- Maximum number of item stacks to get. Default: 1
	items = { -- Table of possible loot items. This function selects between stacks_min and stacks_max of these.
		{
		itemstring = "example:item1", -- Which item to select
		amount_min = 1,		-- Minimum size of itemstack. Must not be larger than 6553. Optional (default: 1)
		amount_max = 10,	-- Maximum size of item stack. Must not be larger than item definition's stack_max or 6553. Optional (default: 1)
		wear_min = 1,		-- Minimum wear value. Must be at least 1. Optional (default: no wear)
		wear_max = 1,		-- Maxiumum wear value. Must be at least 1. Optional (default: no wear)
		weight = 5,		-- Likelihood of this item being selected (see below). Optional (default: 1)
		},
		{ -- more tables like above, one table per item stack }
	}
}
* pr: PseudoRandom object used for the randomness

How weight works: The probability of a single item stack being selected is weight/total_weight, with
total_weight being the sum of all weight values in the items table. If you leave out the weight for
all items, the likelihood of each item being selected is equal.

Returns: Table of itemstrings
]]
function mcl_loot.get_loot(loot_definitions, pr)
	local items = {}

	local total_weight = 0
	for i=1, #loot_definitions.items do
		total_weight = total_weight + (loot_definitions.items[i].weight or 1)
	end

	local stacks_min = loot_definitions.stacks_min
	local stacks_max = loot_definitions.stacks_max
	if not stacks_min then stacks_min = 1 end
	if not stacks_max then stacks_max = 1 end
	local stacks = pr:next(loot_definitions.stacks_min, loot_definitions.stacks_max)
	for s=1, stacks do
		local r = pr:next(1, total_weight)

		local accumulated_weight = 0
		local item
		for i=1, #loot_definitions.items do
			accumulated_weight = accumulated_weight + (loot_definitions.items[i].weight or 1)
			if accumulated_weight >= r then
				item = loot_definitions.items[i]
				break
			end
		end
		if item then
			local itemstring = item.itemstring
			if item.amount_min and item.amount_max then
				itemstring = itemstring .. " " .. pr:next(item.amount_min, item.amount_max)
			end
			if item.wear_min and item.wear_max then
				-- Sadly, PseudoRandom only allows very narrow ranges, so we set wear in steps of 10
				local wear_min = math.floor(item.wear_min / 10)
				local wear_max = math.floor(item.wear_max / 10)
				local wear = pr:next(wear_min, wear_max) * 10

				if not item.amount_min and not item.amount_max then
					itemstring = itemstring .. " 1"
				end

				itemstring = itemstring .. " " .. tostring(wear)
			end
			table.insert(items, itemstring)
		else
			minetest.log("error", "[mcl_loot] INTERNAL ERROR! Failed to select random loot item!")
		end
	end

	return items
end

--[[
Repeat mcl_loot.get_loot multiple times for various loot_definitions.
Useful for filling chests.

* multi_loot_definitions: Table of loot_definitions (see mcl_loot.get_loot)
* pr: PseudoRandom object used for the randomness

Returns: Table of itemstrings ]]
function mcl_loot.get_multi_loot(multi_loot_definitions, pr)
	local items = {}
	for m=1, #multi_loot_definitions do
		local group = mcl_loot.get_loot(multi_loot_definitions[m], pr)
		for g=1, #group do
			table.insert(items, group[g])
		end
	end
	return items
end

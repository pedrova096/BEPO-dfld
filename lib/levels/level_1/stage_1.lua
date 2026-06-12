local Rewards = require("lib.rewards.reward_types")


--- @type BudgetWaveConfig
local wave_1 = {
	type = "budget",
	options = {
		id = 101,
		budget = 4,
		spawn_interval = 6,
		spawn_concurrent = 2,
		enemy_pool = {
			{ id = "enemy_01", cost = 1, chance = 0.85 },
			{ id = "enemy_02", cost = 2, chance = 0.15 },
		},
		overlap_time = 18.0,
	}
}

--- @type BudgetWaveConfig
local wave_2 = {
	type = "budget",
	options = {
		id = 102,
		budget = 4,
		spawn_interval = 2,
		spawn_concurrent = 3,
		enemy_pool = {
			{ id = "enemy_01", cost = 1, chance = 0.65 },
			{ id = "enemy_02", cost = 2, chance = 0.35 },
		},
		overlap_time = 25,
	}
}

return {
	waves = { wave_1, wave_2 },
	difficulty = 1,
	reward = Rewards.SpecialAction,
	tilemap_id = hash("tilemap_01")
}

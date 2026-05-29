local Rewards = require("lib.rewards.reward_types")

local pool = {
	{ id = "enemy_01", cost = 1, chance = 0.8 },
	{ id = "enemy_02", cost = 1, chance = 0.2 },
}

--- @type BudgetWaveConfig
local wave_1 = {
	type = "budget",
	options = {
		id = 101,
		budget = 2,
		spawn_interval = 6,
		spawn_concurrent = 3,
		enemy_pool = pool,
		overlap_time = 12.0,
	}
}

--- @type BudgetWaveConfig
local wave_2 = {
	type = "budget",
	options = {
		id = 102,
		budget = 2,
		spawn_interval = 2,
		spawn_concurrent = 3,
		enemy_pool = pool,
		overlap_time = 25,
	}
}

return {
	waves = { wave_1, wave_2 },
	difficulty = 1,
	reward = Rewards.EnhancementUpgrade,
	tilemap_id = hash("tilemap_01")
}

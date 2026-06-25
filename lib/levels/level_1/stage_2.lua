local pool = {
	{ id = "enemy_01", cost = 1, chance = 0.5 },
	{ id = "enemy_02", cost = 2, chance = 0.5 },
}

--- @type BudgetWaveConfig
local wave_1 = {
	type = "budget",
	options = {
		id = 101,
		budget = 10 / 3,
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
		budget = 16 / 3,
		spawn_interval = 2,
		spawn_concurrent = 3,
		enemy_pool = pool,
		overlap_time = 25,
	}
}

return {
	waves = { wave_1, wave_2 },
	difficulty = 1,
	tilemap_id = hash("tilemap_02")
}

local BudgetWave = require("utils.stager.budget_wave")
local TimedWave = require("utils.stager.timed_wave")

local pool = {
	{ id = "enemy_01", cost = 1, chance = 0.5 },
	{ id = "enemy_02", cost = 2, chance = 0.5 },
}

--- Wave 1 — small budget, slow trickle to ease the player in.
--- Overlaps into wave 2 after 20 seconds.
local wave_1 = BudgetWave:new({
	id = 101,
	budget = 10,
	spawn_interval = 6,
	spawn_concurrent = 3,
	enemy_pool = pool,
	overlap_time = 12.0,
})

--- Wave 2 — medium budget, faster spawns, starts while wave 1 may still be active.
--- Overlaps into wave 3 after 25 seconds.
local wave_2 = BudgetWave:new({
	id = 102,
	budget = 16,
	spawn_interval = 2,
	spawn_concurrent = 3,
	enemy_pool = pool,
	overlap_time = 25,
})

--- Wave 3 — exclusive timed pressure wave, waits for all previous waves to clear before starting.
-- local wave_3 = TimedWave:new({
-- 	max_time = 30,
-- 	spawn_interval = 1.5,
-- 	concurrent = 2,
-- 	enemy_pool = pool,
-- 	exclusive = true,
-- })

return { wave_1, wave_2 }

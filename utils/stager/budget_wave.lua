--- Budget-limited wave. Spawns enemies until the budget is exhausted.
--- @class BudgetWave : Wave
--- @field budget number total spawn budget
--- @field spent number budget consumed so far
--- @field _costliest_index number index of the costliest enemy
local Wave = require("utils.stager.wave")

local M = setmetatable({}, { __index = Wave })
M.__index = M

local function get_costliest_index(enemy_pool)
	local highest_cost_index = -1
	local highest_cost = -math.huge

	for index, enemy in ipairs(enemy_pool) do
		if enemy.cost > highest_cost then
			highest_cost = enemy.cost
			highest_cost_index = index
		end
	end

	return highest_cost_index
end

--- Create a new BudgetWave instance.
--- @class BudgetWaveOptions : WaveOptions
--- @field budget number? total spawn budget (default 10)

--- @class BudgetWaveConfig
--- @field type "budget"
--- @field options BudgetWaveOptions

--- @param options BudgetWaveOptions
--- @return BudgetWave
function M:new(options)
	--- @class BudgetWave
	local instance = Wave.new(self, options)

	instance.budget = options.budget or 10
	instance.spent = 0

	instance._costliest_index = get_costliest_index(instance.enemy_pool)
	return instance
end

--- @return boolean
function M:can_spawn()
	return (self.budget - self.spent) >= 0
end

--- @param enemy_def EnemyDef
--- @return boolean
function M:validate_spawn(enemy_def)
	return self.spent <= self.budget
end

function M:pick_enemy()
	local costliest_enemy = self.enemy_pool[self._costliest_index]

	local remain = self.budget - self.spent
	if remain < costliest_enemy.cost then
		return costliest_enemy
	end

	return Wave.pick_enemy(self)
end

--- @param enemy_def EnemyDef
function M:commit_spawn(enemy_def)
	self.spent = self.spent + enemy_def.cost
	Wave.commit_spawn(self, enemy_def)
end

--- @return boolean
function M:is_complete()
	return not self:can_spawn() and self.alive_count == 0
end

--- @return number
function M:get_progress()
	return math.min(self.spent / self.budget, 1)
end

return M

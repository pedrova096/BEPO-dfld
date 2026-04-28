local BudgetWave = require("utils.stager.budget_wave")
local TimedWave = require("utils.stager.timed_wave")

local WAVE_CONSTRUCTORS = {
	budget = BudgetWave,
	timed = TimedWave,
}

local M = {}

---Build wave instances from serialized stage config.
---@param wave_configs table[]?
---@return Wave[]
function M.from_config(wave_configs)
	local waves = {}

	for index, wave_config in ipairs(wave_configs or {}) do
		if wave_config.update then
			waves[index] = wave_config
		else
			local constructor = WAVE_CONSTRUCTORS[wave_config.type]
			if not constructor then
				error(("Unknown wave type %s"):format(tostring(wave_config.type)))
			end

			waves[index] = constructor:new(wave_config.options or {})
		end
	end

	return waves
end

return M

local BudgetWave = require("modules.level.wave.budget_wave")
local TimedWave = require("modules.level.wave.timed_wave")

local WAVE_CONSTRUCTORS = {
	budget = BudgetWave,
	timed = TimedWave,
}

local M = {}

---Build wave instances from serialized stage config.
---@param wave_configs table[]?
---@param options {debug: boolean?}?
---@return Wave[]
function M.from_config(wave_configs, options)
	local waves = {}
	options = options or {}

	for index, wave_config in ipairs(wave_configs or {}) do
		if wave_config.update then
			waves[index] = wave_config
		else
			local constructor = WAVE_CONSTRUCTORS[wave_config.type]
			if not constructor then
				error(("Unknown wave type %s"):format(tostring(wave_config.type)))
			end

			local wave_options = {}
			for key, value in pairs(wave_config.options or {}) do
				wave_options[key] = value
			end
			wave_options.debug = options.debug

			waves[index] = constructor:new(wave_options)
		end
	end

	return waves
end

return M

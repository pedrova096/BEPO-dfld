--- Time-limited wave. Spawns enemies until max_time is reached.
--- Complete when elapsed time exceeds max_time and all alive enemies are dead.
--- @class TimedWave : Wave
--- @field max_time number maximum duration in seconds
local Wave = require("utils.stager.wave")

local M = setmetatable({}, { __index = Wave })
M.__index = M

--- Create a new TimedWave instance.
--- @class TimedWaveOptions : WaveOptions
--- @field max_time number? maximum spawn duration in seconds (default 30)

--- @class TimedWaveConfig
--- @field type "time"
--- @field options TimedWaveOptions

--- @param options TimedWaveOptions
--- @return TimedWave
function M:new(options)
	--- @class TimedWave
	local instance = Wave.new(self, options)

	instance.max_time = options.max_time or 30

	return instance
end

--- @return boolean
function M:can_spawn()
	return self.elapsed < self.max_time
end

--- @return boolean
function M:is_complete()
	return self.elapsed >= self.max_time and self.alive_count == 0
end

--- @return number
function M:get_progress()
	return math.min(self.elapsed / self.max_time, 1)
end

return M

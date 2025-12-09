local WaveBudget = require("utils.stager.waves.wave_budget")
local WaveTime = require("utils.stager.waves.wave_time")

---@type table<string, WaveBase>
local Patterns = {
  budget = WaveBudget,
  time = WaveTime,
}

---Create a wave instance from config
---@param config WaveConfig
---@param deps table { spawner: Spawner, enemy_selector: EnemySelector }
---@return WaveBase|nil
local function create(config, deps)
  local pattern = config.pattern
  local WaveClass = Patterns[pattern]

  if not WaveClass then
    print("[Waves] Unknown pattern: " .. tostring(pattern))
    return nil
  end

  return WaveClass:new(config, deps)
end

---Register a new wave pattern
---@param pattern string
---@param wave_class WaveBase
local function register(pattern, wave_class)
  Patterns[pattern] = wave_class
end

return {
  create = create,
  register = register,
  Patterns = Patterns,
  -- Export classes for direct use
  Budget = WaveBudget,
  Time = WaveTime,
}

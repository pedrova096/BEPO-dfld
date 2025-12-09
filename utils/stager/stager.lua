local Waves = require("utils.stager.waves.index")
local Spawner = require("utils.stager.spawner")
local EnemySelector = require("utils.stager.enemy_selector")

---@class StagerOptions
---@field config StagesConfig
---@field bounds { min: vector3, max: vector3 }
---@field factories table<string, url>

---@class StagerDependencies
---@field spawner Spawner?
---@field enemy_selector EnemySelector?

---@class Stager
---@field config StagesConfig
---@field spawner Spawner
---@field enemy_selector EnemySelector
---@field current_wave WaveBase|nil
---@field current_wave_index number
---@field elapsed_time number
---@field stage_ended boolean
---@field inter_wave_timer number
---@field waiting_for_next_wave boolean
local M = {}
M.__index = M

---Create a new Stager instance
---@param options StagerOptions
---@param deps StagerDependencies?
---@return Stager
function M:new(options, deps)
  deps = deps or {}

  local instance = setmetatable({}, M)

  instance.config = options.config
  instance.spawner = deps.spawner or Spawner:new({
    bounds = options.bounds,
    factories = options.factories,
    debug = options.debug,
  })
  instance.enemy_selector = deps.enemy_selector or EnemySelector:new()

  instance.current_wave = nil
  instance.current_wave_index = 0
  instance.elapsed_time = 0
  instance.stage_ended = false
  instance.inter_wave_timer = 0
  instance.waiting_for_next_wave = false

  -- Start first wave
  instance:_start_next_wave()

  return instance
end

---Get wave dependencies
---@return table
function M:_get_wave_deps()
  return {
    spawner = self.spawner,
    enemy_selector = self.enemy_selector,
  }
end

---Start the next wave
function M:_start_next_wave()
  self.current_wave_index = self.current_wave_index + 1

  local wave_config = self.config.waves[self.current_wave_index]
  if not wave_config then
    -- No more waves
    self.current_wave = nil
    self:_end_stage()
    return
  end

  self.current_wave = Waves.create(wave_config, self:_get_wave_deps())
  self.waiting_for_next_wave = false
end

---Check if stage should end
function M:_check_stage_end()
  local total_waves = #self.config.waves
  if self.current_wave_index > total_waves then
    self:_end_stage()
  end
end

---End the stage
function M:_end_stage()
  if self.stage_ended then return end

  self.stage_ended = true
end

---Handle inter-wave delay
---@param dt number
function M:_inter_wave_delay_pipe(dt)
  if not self.waiting_for_next_wave then return end

  self.inter_wave_timer = self.inter_wave_timer - dt
  if self.inter_wave_timer > 0 then return end

  self:_start_next_wave()
end

---Update wave
---@param dt number
function M:_wave_pipe(dt)
  if not self.current_wave then return end

  self.current_wave:update(dt)

  if not self.current_wave:is_complete() then return end

  self.waiting_for_next_wave = true
  self.inter_wave_timer = self.config.inter_wave_delay or 0
end

---Update the stager
---@param dt number
function M:update(dt)
  if self.stage_ended then return end

  self.elapsed_time = self.elapsed_time + dt

  self:_wave_pipe(dt)
  self:_inter_wave_delay_pipe(dt)
  self:_check_stage_end()
end

---Handle enemy killed event
---@param enemy_id hash|url
function M:on_enemy_killed(enemy_id)
  if not self.current_wave then return end

  self.current_wave:on_enemy_killed(enemy_id)
end

return M

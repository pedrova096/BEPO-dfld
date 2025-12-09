local WaveBase = require("utils.stager.waves.wave_base")

---@class WaveTime : WaveBase
---@field time_limit number
---@field elapsed_time number
local M = setmetatable({}, { __index = WaveBase })
M.__index = M

---@param config WaveByTimeConfig
---@param deps table { spawner: Spawner, enemy_selector: EnemySelector }
---@return WaveTime
function M:new(config, deps)
  local instance = WaveBase.new(self, config, deps)
  return instance
end

function M:_init()
  self.time_limit = self.config.time_limit or 0
  self.spawn_interval = self.config.spawn_interval or 1
  self.elapsed_time = 0
  self.spawn_timer = 0
end

function M:_check_completion_pipe()
  -- Check completion: time's up and all enemies dead
  if not self:has_finished_spawning() then return false end
  if self:get_active_enemies() > 0 then return false end

  self.completed = true

  return true
end

-- Spawn enemies: try to spawn if we can
function M:_spawn_enemies_pipe()
  if not self:is_spawn_timer_done() then return end

  for i = 1, self.spawn_concurrent do
    if #self.active_enemies >= self.spawn_concurrent then break end

    local enemy = self:select_enemy()
    if enemy then
      self:spawn(enemy)
    end
  end
end

---@param dt number
function M:update(dt)
  if self.completed then return false end

  self.elapsed_time = self.elapsed_time + dt
  self.spawn_timer = self.spawn_timer + dt

  if self:_check_completion_pipe() then return end

  self:_spawn_enemies_pipe()
end

---@return boolean
function M:has_finished_spawning()
  return self.elapsed_time >= self.time_limit
end

---Get remaining time
---@return number
function M:get_remaining()
  return math.max(0, self.time_limit - self.elapsed_time)
end

---Get progress (0-1)
---@return number
function M:get_progress()
  if self.time_limit <= 0 then return 1 end
  return math.min(1, self.elapsed_time / self.time_limit)
end

return M

local WaveBase = require("utils.stager.waves.wave_base")

---@class WaveBudget : WaveBase
---@field budget number
---@field spent number
local M = setmetatable({}, { __index = WaveBase })
M.__index = M

---@param config WaveByBudgetConfig
---@param deps table { spawner: Spawner, enemy_selector: EnemySelector }
---@return WaveBudget
function M:new(config, deps)
  local instance = WaveBase.new(self, config, deps)
  return instance
end

function M:_init()
  WaveBase._init(self)
  self.budget = self.config.budget or 0
  self.spent = 0
end

-- Check completion: budget exhausted and all enemies dead
function M:_check_completion_pipe()
  if not self:has_finished_spawning() then return false end
  if self:get_active_enemies_count() > 0 then return false end

  self.completed = true

  return true
end

-- Spawn enemies: try to spawn if we can
function M:_spawn_enemies_pipe()
  if not self:is_spawn_timer_done() then return end
  if self:get_remaining() <= 0 then return end

  local spawn_count = self.spawn_concurrent + math.random(-1, 1)

  for i = 1, spawn_count do
    local remaining = self.budget - self.spent

    local enemy = self.enemy_selector:select_affordable(self.config.enemies, remaining)

    if not enemy then
      enemy = self.enemy_selector:select_most_expensive(self.config.enemies)
    end

    if not enemy then
      self.spent = self.budget
      break
    end

    self:spawn(enemy)
    self.spent = self.spent + enemy.threat
  end
end

---@param dt number
function M:update(dt)
  self.spawn_timer = self.spawn_timer + dt

  if self:_check_completion_pipe() then return end

  self:_spawn_enemies_pipe()
end

---@return boolean
function M:has_finished_spawning()
  return self.spent >= self.budget
end

---Get remaining budget
---@return number
function M:get_remaining()
  return self.budget - self.spent
end

---Get progress (0-1)
---@return number
function M:get_progress()
  if self.budget <= 0 then return 1 end
  return self.spent / self.budget
end

return M

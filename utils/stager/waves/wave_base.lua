---@class WaveBase
---@field config WaveConfig|WaveByBudgetConfig|WaveByTimeConfig
---@field spawner Spawner
---@field enemy_selector EnemySelector
---@field active_enemies table
---@field completed boolean
---@field spawn_interval number
---@field spawn_concurrent number
---@field spawn_timer number
local M = {}
M.__index = M

---Create a new wave instance
---@param config WaveConfig
---@param deps table { spawner: Spawner, enemy_selector: EnemySelector }
---@return WaveBase
function M:new(config, deps)
  local instance = setmetatable({}, self)

  instance.config = config
  instance.spawner = deps.spawner
  instance.enemy_selector = deps.enemy_selector
  instance.active_enemies = {} -- TODO: This should a pool of enemies
  instance.completed = false
  instance.spawn_timer = 0

  instance:_init()

  return instance
end

---Initialize wave (override in subclass)
function M:_init()
  self.spawn_interval = self.config.spawn_interval or 1
  self.spawn_concurrent = self.config.spawn_concurrent or 1
end

---Update the wave (override in subclass)
---@param dt number
function M:update(dt)
  if self.completed then return end

  self.spawn_timer = self.spawn_timer + dt
end

---Check if the spawn timer is done
---@return boolean
function M:is_spawn_timer_done()
  return self.spawn_timer >= self.spawn_interval
end

---Select an enemy using the selector
---@return EnemyConfig|nil
function M:select_enemy()
  return self.enemy_selector:select(self.config.enemies)
end

---Spawn an enemy
---@param enemy_config EnemyConfig
---@return hash|nil enemy_id
function M:spawn(enemy_config)
  if not self.spawner then return nil end

  local enemy_id = self.spawner:spawn(enemy_config)

  if enemy_id then
    table.insert(self.active_enemies, {
      id = enemy_id,
      config = enemy_config,
    })
    self.spawn_timer = 0
  end

  return enemy_id
end

---Handle enemy killed
---@param enemy_id hash|url
---@return EnemyConfig|nil killed_config
function M:on_enemy_killed(enemy_id)
  for i, enemy in ipairs(self.active_enemies) do
    if enemy.id == enemy_id then
      local config = enemy.config
      table.remove(self.active_enemies, i)
      return config
    end
  end
  return nil
end

---Check if this is a boss wave
---@return boolean
function M:is_boss_wave()
  return self.config.type == "boss"
end

---Get the active enemies count
---@return number
function M:get_active_enemies()
  return #self.active_enemies
end

---Check if the wave is complete. Override in subclass if needed.
---@return boolean
function M:is_complete()
  return self.completed
end

return M

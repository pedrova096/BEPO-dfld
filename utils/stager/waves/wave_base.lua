local Pooler = require("utils.pooler")

---@class WaveBase
---@field config WaveConfig|WaveByBudgetConfig|WaveByTimeConfig
---@field enemy_selector EnemySelector
---@field completed boolean
---@field spawn_interval number
---@field spawn_concurrent number
---@field spawn_timer number
---@field spawner Spawner
---@field debug boolean
---@field pool_enemies Pooler
local M = {}
M.__index = M

---Spawn an enemy
---@param spawner Spawner
---@param index number
---@param options table
---@return function
local function _spawn_enemy(spawner)
  return function(_, options)
    local enemy_id = spawner:spawn(options)

    return {
      id = enemy_id,
      config = options,
    }
  end
end

---Create a new wave instance
---@param config WaveConfig
---@param deps table { spawner: Spawner, enemy_selector: EnemySelector }
---@return WaveBase
function M:new(config, deps)
  local instance = setmetatable({}, self)

  instance.config = config
  instance.enemy_selector = deps.enemy_selector
  instance.spawner = deps.spawner
  instance.debug = deps.debug or false
  instance.pool_enemies = Pooler.new({
    pool_size = 0,
    spawner = _spawn_enemy(deps.spawner),
  })
  instance.completed = false

  instance:_init()

  return instance
end

---Initialize wave (override in subclass)
function M:_init()
  self.spawn_interval = self.config.spawn_interval or 1
  self.spawn_concurrent = self.config.spawn_concurrent or 1
  self.spawn_timer = 0
end

---Update the wave (override in subclass)
---@param dt number
function M:update(dt)
  if self.completed then return end

  self.spawn_timer = self.spawn_timer - dt
end

---Check if the spawn timer is done
---@return boolean
function M:is_spawn_timer_done()
  return self.spawn_timer <= 0
end

---Select an enemy using the selector
---@return EnemyConfig|nil
function M:select_enemy()
  return self.enemy_selector:select(self.config.enemies)
end

---Find an enemy by its config
---@param enemy_config EnemyConfig
---@return function
local function find_enemy_by_config(enemy_config)
  return function(enemy)
    -- TODO: killed_at its a workaround to avoid spawning the same enemy immediately
    return enemy.config == enemy_config and (os.time() - enemy.killed_at) > 1
  end
end

---Spawn an enemy
---@param enemy_config EnemyConfig
---@return hash|nil enemy_id
function M:spawn(enemy_config)
  ---@type { id: hash|url, config: EnemyConfig }|nil
  local enemy = self.pool_enemies:predicate_pull(
    find_enemy_by_config(enemy_config)
  )

  if enemy then
    if self.debug then
      pprint("SPAWN_EXISTING_ENEMY", enemy.id)
    end
    self.spawner:spawn_existing_enemy(enemy.id)
  else
    ---@type { id: hash|url, config: EnemyConfig }
    enemy = self.pool_enemies:extend(enemy_config)
    if self.debug then
      pprint("EXTEND_ENEMY", enemy)
    end
  end

  self.spawn_timer = self.spawn_interval

  return enemy.id
end

---Find an enemy by its id
---@param enemy_id hash|url
---@return function
local function find_enemy_by_id(enemy_id)
  return function(enemy)
    return enemy.id == enemy_id
  end
end

---Handle enemy killed
---@param enemy_id hash|url
---@return EnemyConfig|nil killed_config
function M:on_enemy_killed(enemy_id)
  ---@type { config: EnemyConfig }|nil
  local enemy = self.pool_enemies:predicate_push(
    find_enemy_by_id(enemy_id)
  )
  if self.debug then
    pprint("PUSH_ENEMY", enemy)
  end
  enemy.killed_at = os.time()

  if not enemy then return nil end

  return enemy.config
end

---Check if this is a boss wave
---@return boolean
function M:is_boss_wave()
  return self.config.type == "boss"
end

---Get the active enemies count
---@return number
function M:get_active_enemies_count()
  return #self:get_active_enemies()
end

---Get the active enemies
---@return table
function M:get_active_enemies()
  return self.pool_enemies.in_use
end

---Check if the wave is complete. Override in subclass if needed.
---@return boolean
function M:is_complete()
  return self.completed
end

function M:destroy()
  self.pool_enemies:reset()
  for _, enemy in ipairs(self.pool_enemies.available) do
    go.delete(enemy.id)
  end
end

return M

local Msg = require("lib.msg")
local Pooler = require("utils.pooler.pooler")
local VMathUtils = require("utils.vmath")
local RandomPositionGenerator = require("utils.position_generator.random_position_generator")

---@class EnemyItem
---@field id userdata ID of the enemy object
---@field type string enemy type

---@class CreateEnemyOptions
---@field type string enemy type
---@field wave_id number ID of the wave this enemy belongs to, if any

---@class EnemyPoolOptions
---@field factory_map table<string, string> Map of enemy type to factory URL
---@field position_generator { next: fun(self: any): vector3 }? Provides the next spawn position
---@field reset (fun(enemy: EnemyItem))? Called when an enemy is returned to the pool

---@class EnemyPool
---@field factory_map table<string, string> Map of enemy type to factory URL
---@field position_generator { next: fun(self: any): vector3 }
---@field pool Pool
---@field pending EnemyItem[] Enemies waiting for despawn confirmation before reuse
local M = {}
M.__index = M

local function create_enemy(self)
  ---@param options CreateEnemyOptions
  return function(options)
    local factory_url = self.factory_map[options.type]
    if not factory_url then
      error("No factory found for enemy type: " .. options.type)
    end

    local position = self.position_generator:next()
    position.z = 1

    local ids = collectionfactory.create(factory_url, position)
    local enemy = {
      id = ids["/root"],
      type = options.type,
    }
    msg.post(enemy.id, Msg.Enemy.ACTIVATE_ENEMY, {
      wave_id = options.wave_id,
    })
    return enemy
  end
end

---@param options EnemyPoolOptions
---@return EnemyPool
function M.new(options)
  local instance = setmetatable({}, M)
  instance.factory_map = options.factory_map
  instance.position_generator = options.position_generator or RandomPositionGenerator:new(200, -200)
  instance.pending = {}
  instance.pool = Pooler.new({
    size = 0,
    create = create_enemy(instance),
    reset = options.reset,
  })

  return instance
end

local function find_free_index_by_type(self, type_name)
  local free_enemies = self.pool.state.free

  for i, enemy in ipairs(free_enemies) do
    if enemy.type == type_name then
      return i
    end
  end

  return nil
end

local function find_active_index_by_id(self, id)
  local active_enemies = self.pool.state.active

  for i, enemy in ipairs(active_enemies) do
    if enemy.id == id then
      return i
    end
  end

  return nil
end

local function find_pending_index_by_id(self, id)
  for i, enemy in ipairs(self.pending) do
    if enemy.id == id then
      return i
    end
  end

  return nil
end

local function on_post_acquire(self, enemy, options)
  local position = self.position_generator:next()
  position.z = 1
  go.set(enemy.id, "position", position)
  --go.set(msg.url(nil, enemy.id, "controller"), "wave_id", options.wave_id)
  msg.post(enemy.id, Msg.Enemy.ACTIVATE_ENEMY, {
    wave_id = options.wave_id,
  })
end

---Acquire a recycled enemy of the given type. Extends the pool if none are available.
---@param options CreateEnemyOptions
---@return EnemyItem
function M:acquire_or_extend(options)
  local index = find_free_index_by_type(self, options.type)
  if not index then
    return self.pool:extend_active(options)
  end
  local enemy = self.pool:acquire_by_index(index)
  on_post_acquire(self, enemy, options)
  return enemy
end

---Return an enemy to the pool.
---@param enemy_id userdata
function M:release(enemy_id)
  local index = find_active_index_by_id(self, enemy_id)
  if not index then return end
  self.pool:release_by_index(index)
end

---Mark an enemy as waiting for despawn confirmation before returning it to the free list.
---@param enemy_id userdata
function M:request_release(enemy_id)
  local index = find_active_index_by_id(self, enemy_id)
  if not index then return end

  local enemy = table.remove(self.pool.state.active, index)
  table.insert(self.pending, enemy)
end

---Confirm a pending enemy by index and return it to the free list.
---@param index number
---@return EnemyItem?
function M:confirm_release_by_index(index)
  if index < 1 or index > #self.pending then return nil end

  local enemy = table.remove(self.pending, index)

  if self.pool.config.reset then
    self.pool.config.reset(enemy)
  end

  table.insert(self.pool.state.free, enemy)
  return enemy
end

---Confirm an enemy has fully despawned and can be reused.
---@param enemy_id userdata
function M:confirm_release(enemy_id)
  local index = find_pending_index_by_id(self, enemy_id)
  if not index then return end
  return self:confirm_release_by_index(index)
end

---Reset the pool and destroy all enemies
function M:reset()
  -- Confirm all pending
  for index = #self.pending, 1, -1 do
    self:confirm_release_by_index(index)
  end

  ---@type EnemyItem[]
  local to_destroy = self.pool:clean()

  for _, enemy in ipairs(to_destroy) do
    go.delete(enemy.id, true)
  end
end

---Return the currently active enemies.
---@return EnemyItem[]
function M:get_actives()
  return self.pool.state.active
end

---@param generator { next: fun(self: any): vector3 }
function M:set_position_generator(generator)
  self.position_generator = generator
end

return M

local Msg = require("lib.msg")

---@class SpawnerOptions
---@field bounds { min: vector3, max: vector3 }
---@field factories table<string, url>
---@field debug boolean
---@class Spawner : SpawnerOptions
local M = {}
M.__index = M

---Create a new spawner
---@param options? SpawnerOptions
---@return Spawner
function M:new(options)
  options = options or {}
  local instance = setmetatable({}, M)
  instance.bounds = options.bounds
  instance.factories = options.factories
  instance.debug = options.debugs

  return instance
end

---Get a random spawn position in the area
---@return vector3
function M:get_spawn_position_by_bounds()
  local min = self.bounds.min
  local max = self.bounds.max

  local x = math.random(min.x, max.x)
  local y = math.random(min.y, max.y)

  return vmath.vector3(x, y, 1)
end

---Spawn an enemy
---@param enemy_config EnemyConfig
---@return hash|nil root_id
function M:spawn(enemy_config)
  local factory_url = enemy_config.factory_url or self.factories[enemy_config.id]

  if not factory_url then
    print("[Spawner] No factory URL configured")
    return nil
  end

  local position = self:get_spawn_position_by_bounds()

  local ids = collectionfactory.create(factory_url, position)
  local enemy_id = ids["/root"]
  if self.debug then
    pprint("Spawner: spawned enemy => " .. enemy_id, "position => " .. position)
  end

  msg.post(enemy_id, Msg.Enemy.SPAWNED)
  return enemy_id
end

return M

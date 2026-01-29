local Msg = require("lib.msg")
local Table = require("utils.table")

---@class SpawnerOptions
---@field bounds { min: vector3, max: vector3 }
---@field factories table<string, url>
---@field debug boolean
---@field spawn_positions table<vector3>
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
  instance.debug = options.debug
  instance.spawn_positions = options.spawn_positions
  return instance
end

---Get a random spawn position in the area
---@return vector3
function M:get_spawn_position_by_bounds()
  return Table.random(self.spawn_positions)
end

function M:spawn_existing_enemy(enemy_id, position)
  if not position then
    position = self:get_spawn_position_by_bounds()
  end

  if self.debug then
    pprint("Spawner: spawned enemy => " .. enemy_id, "position => " .. position)
  end

  msg.post(enemy_id, Msg.Enemy.SPAWNED, {
    position = position,
  })

  return enemy_id
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
  return self:spawn_existing_enemy(enemy_id, position)
end

return M

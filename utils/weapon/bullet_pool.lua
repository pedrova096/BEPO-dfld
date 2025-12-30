local Pooler = require("utils.pooler")
local Bullet = require("utils.weapon.bullet")

local DEFAULT_POOL_SIZE = 10

---@class BulletPool
---@field pool Pooler
---@field pool_size number
local M = {}
M.__index = M

---@class BulletPoolOptions
---@field pool_size number
---@field target userdata
---@field factory_url string
---@field bullet_props table?

---Create a pool of bullet instances.
---@param opts BulletPoolOptions
---@return BulletPool
function M:new(opts)
  local instance = setmetatable({}, M)

  instance.pool_size = opts.pool_size or DEFAULT_POOL_SIZE
  instance.pool = Pooler.new({
    pool_size = instance.pool_size,
    spawner = function(index)
      return Bullet:new({
        index = index,
        target = opts.target,
        factory_url = opts.factory_url,
        properties = opts.bullet_props,
      })
    end
  }):spawn()

  return instance
end

---Acquire a bullet from the pool and refresh its config.
---@return Bullet|nil
function M:acquire()
  ---@type Bullet|nil
  local bullet = self.pool:pull()
  if not bullet then return nil end

  bullet:reset()
  return bullet
end

---Release a bullet back to the pool.
---@param bullet Bullet
function M:release(bullet)
  if not bullet then return end
  bullet:finish()
  self.pool:push_item(bullet)
end

---Reset all in‑use bullets and make them available again.
function M:reset()
  for _, bullet in ipairs(self.pool.in_use) do
    bullet:finish()
  end
  self.pool:reset()
end

function M:available()
  return self.pool:available_size()
end

function M:active()
  return self.pool:active_size()
end

function M:set_pool_size(pool_size)
  self.pool_size = pool_size
  self.pool:set_size(pool_size)
end

function M:get_bullet_by_id(id)
  for _, bullet in ipairs(self.pool.in_use) do
    if bullet.id == id then
      return bullet
    end
  end

  return nil
end

return M

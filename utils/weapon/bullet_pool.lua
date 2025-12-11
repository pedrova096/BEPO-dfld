local Pooler = require("utils.pooler")
local Bullet = require("utils.weapon.bullet")

local DEFAULT_POOL_SIZE = 10

---@class BulletPool
---@field pool table
---@field pool_size number
---@field bullet_config BulletConfig
---@field target userdata
---@field factory_url string
local M = {}
M.__index = M

---@class BulletPoolOptions
---@field pool_size number
---@field bullet_config BulletConfig
---@field target userdata
---@field factory_url string

---Create a pool of bullet instances.
---@param opts BulletPoolOptions
---@return BulletPool
function M:new(opts)
  local instance = setmetatable({}, self)

  instance.pool_size = opts.pool_size or DEFAULT_POOL_SIZE
  instance.bullet_config = opts.bullet_config or {}
  instance.target = opts.target
  instance.factory_url = opts.factory_url
  instance.pool = Pooler.new({
    pool_size = instance.pool_size,
    factory = function(i)
      return Bullet:new({
        index = i,
        config = instance.bullet_config,
        target = instance.target,
        factory_url = instance.factory_url,
      })
    end
  }):spawn()

  return instance
end

---Acquire a bullet from the pool and refresh its config.
---@param override_config? BulletConfig
---@return Bullet|nil
function M:acquire(override_config)
  local bullet = self.pool:pull()
  if not bullet then return nil end

  bullet:reset(override_config or self.bullet_config)
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

local Pooler = require("utils.pooler.pooler")
local Bullet = require("utils.weapon.bullet")

local DEFAULT_POOL_SIZE = 10

---@class BulletPool
---@field pool Pool
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
  local next_index = 0
  instance.pool = Pooler.new({
    size = instance.pool_size,
    create = function()
      next_index = next_index + 1
      return Bullet:new({
        index = next_index,
        target = opts.target,
        factory_url = opts.factory_url,
        properties = opts.bullet_props,
      })
    end,
    reset = function(bullet)
      bullet:finish()
    end,
  })

  return instance
end

---Acquire a bullet from the pool and refresh its config.
---@return Bullet|nil
function M:acquire()
  ---@type Bullet|nil
  local bullet = self.pool:acquire()
  if not bullet then return nil end

  bullet:reset()
  return bullet
end

---Acquire a bullet, growing the pool by one if needed.
---@return Bullet
function M:acquire_or_extend()
  local bullet = self.pool:acquire()
  if not bullet then
    self.pool:extend()
    bullet = self.pool:acquire()
  end

  bullet:reset()
  return bullet
end

---Release a bullet back to the pool.
---@param bullet Bullet
function M:release(bullet)
  if not bullet then return end
  self.pool:release(bullet)
end

---Reset all in‑use bullets and make them available again.
function M:reset()
  self.pool:release_all()
end

function M:available()
  return self.pool:count_free()
end

function M:active()
  return self.pool:count_active()
end

function M:_trim_free()
  local state = self.pool.state

  while state.size > self.pool_size and #state.free > 0 do
    local bullet = table.remove(state.free)
    bullet:final()
    state.size = state.size - 1
  end
end

function M:set_pool_size(pool_size)
  self.pool_size = pool_size

  while self.pool.state.size < pool_size do
    self.pool:extend()
  end

  self:_trim_free()
end

function M:get_bullet_by_id(id)
  for _, bullet in ipairs(self.pool.state.active) do
    if bullet.id == id then
      return bullet
    end
  end

  return nil
end

---Delete all pooled bullet objects and clear pool bookkeeping.
function M:final()
  local bullets = self.pool:clean()
  for _, bullet in ipairs(bullets) do
    bullet:final()
  end
end

return M

local Msg = require("lib.msg")

---@class Bullet
---@field id number
---@field object_id userdata
---@field config BulletConfig
---@field active boolean
---@field direction number
---@field position vector3|nil
---@field payload table|nil
local M = {}
M.__index = M

---@class BulletOptions
---@field index number
---@field config BulletConfig
---@field target userdata
---@field factory_url string

---Create a bullet instance.
---@param opts BulletOptions
---@return Bullet
function M:new(opts)
  local instance = setmetatable({}, self)

  instance.id = opts.index
  instance.config = opts.config

  instance.object_id = factory.create(opts.factory_url, vmath.vector3(0, 0, 1), nil, {
    id = instance.id,
    target = opts.target,
    owner_id = go.get_id() -- TODO: from opts
  })

  instance:reset(instance.config)
  return instance
end

---Reset bullet to its initial state.
---@param config? BulletConfig
function M:reset(config)
  self.config = config or self.config or {}
  self.active = false
  self.direction = nil
  self.position = nil
  self.payload = nil
  self.travelled = 0
end

---Mark the bullet as active and attach the firing payload.
---@param payload table
function M:activate(payload)
  self.active = true
  self.payload = payload
  self.direction = payload.direction or self.direction
  self.position = payload.position or self.position

  msg.post(self.object_id, Msg.Bullet.BULLET_FIRED, {
    direction = self.direction,
    position = self.position,
    config = self.config,
  })
end

---Mark the bullet as finished (returned to pool).
function M:finish()
  self.active = false
end

return M

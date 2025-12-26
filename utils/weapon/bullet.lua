local Msg = require("lib.msg")

---@class Bullet
---@field id number
---@field active boolean
---@field object_id string|userdata
local M = {}
M.__index = M

---@class BulletOptions
---@field index number
---@field target userdata
---@field factory_url string
---@field properties table?

---Create a bullet instance.
---@param opts BulletOptions
---@return Bullet
function M:new(opts)
  local instance = setmetatable({}, M)

  instance.id = opts.index
  instance.object_id = factory.create(opts.factory_url, vmath.vector3(0, 0, 1), nil, {
    id = instance.id,
    target = opts.target,
    theme = opts.properties and opts.properties.theme or 1,
    owner_id = go.get_id() -- TODO: from opts
  })
  instance:reset()
  return instance
end

---Reset bullet to its initial state.
function M:reset()
  self.active = false
end

---Mark the bullet as active and attach the firing payload.
---@param payload WeaponFirePayload
function M:activate(payload)
  self.active = true
  msg.post(self.object_id, Msg.Bullet.BULLET_FIRED, payload)
end

---Mark the bullet as finished (returned to pool).
function M:finish()
  self.active = false
end

return M

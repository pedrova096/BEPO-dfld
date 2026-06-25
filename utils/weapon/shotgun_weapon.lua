local Msg = require("lib.msg")
local Weapon = require("utils.weapon.weapon")
local VMath = require("utils.vmath")
local Table = require("utils.table")

---@class ShotgunWeapon : Weapon
---@field config ShotgunWeaponConfig
local M = setmetatable({}, { __index = Weapon })
M.__index = M

---Create a new shotgun weapon instance.
---@param opts WeaponOptions
---@return ShotgunWeapon
function M:new(opts)
  return Weapon.new(self, opts)
end

---@param payload WeaponFirePayload|nil
---@return WeaponFirePayload[]
function M:_build_pellet_payloads(payload)
  local pellets = math.min(self.state.ammo, self.config.pellets or 1)
  local spread = math.rad(self.config.spread or 0)
  local pellet_spawn_width = self.config.pellet_spawn_width or 0

  local base_direction = VMath.normalize_or_zero(payload and payload.direction or vmath.vector3(0))

  local step = pellets > 1 and spread / (pellets - 1) or 0
  local start_angle = -spread * 0.5

  local origin_step = pellets > 1 and pellet_spawn_width / (pellets - 1) or 0
  local origin_start_offset = -pellet_spawn_width * 0.5
  local origin_axis = vmath.vector3(-base_direction.y, base_direction.x, 0)

  local payloads = {}

  for i = 1, pellets do
    ---@type WeaponFirePayload
    local pellet_payload = Table.copy(payload or {})
    local angle = start_angle + step * (i - 1)
    pellet_payload.direction = VMath.rotate_direction(base_direction, angle)

    local origin_offset = origin_start_offset + origin_step * (i - 1)
    pellet_payload.position = pellet_payload.position + origin_axis * origin_offset

    table.insert(payloads, self:_build_fire_payload(pellet_payload))
  end

  return payloads
end

---Shotgun timing is based on shells fired, not pellets spawned per shell.
---@return number
function M:get_attack_duration()
  local pellets = self.config.pellets or 1

  return self.config.fire_interval * math.ceil(self.config.ammo_capacity / pellets)
end

---Attempt to fire the shotgun. One ammo unit launches multiple pellets.
---@param payload WeaponFirePayload|nil Additional data (direction/position/etc).
---@return Bullet[]|nil
function M:fire(payload)
  if not self:can_fire() then
    return nil
  end

  local fired_bullets = {}
  local firing_payloads = self:_build_pellet_payloads(payload)

  for _, firing_payload in ipairs(firing_payloads) do
    local bullet = self.bullet_pool:acquire()
    if bullet then
      bullet:activate(firing_payload)
      table.insert(fired_bullets, bullet)
    end
  end

  if #fired_bullets == 0 then
    return nil
  end

  self.state.cooldown = self.config.fire_interval
  self.state.ammo = math.max(0, self.state.ammo - #fired_bullets)
  msg.post(".", Msg.Weapon.FIRED, {
    ammo = self.state.ammo,
    ammo_capacity = self.config.ammo_capacity,
    direction = payload and payload.direction,
  })

  if self.state.ammo <= 0 then
    self:start_reload(true)
  end

  return fired_bullets
end

return M

local Msg = require("lib.msg")
local BulletPool = require("utils.weapon.bullet_pool")
local VMath = require("utils.vmath")
local Table = require("utils.table")

local DEFAULT_INACCURACY_DEGREES = 4

local DEFAULT_BULLET_CONFIG = {
  speed = 400,
  force = 1,
  ricochets = 0,
  ricochet_ray_count = 16,
  ricochet_ray_range = 140,
  ricochet_ray_start_offset = 8,
  ricochet_check_obstacles = false,
}

---@class Weapon
---@field id string
---@field config WeaponConfig
---@field target userdata
---@field state WeaponState
---@field bullet_config BulletConfig
---@field bullet_pool BulletPool
local M = {}
M.__index = M

---@class WeaponBulletOptions
---@field config BulletConfig
---@field factory_url string

---@class WeaponOptions
---@field id string
---@field config WeaponConfig
---@field target userdata
---@field auto_reload boolean?
---@field bullet WeaponBulletOptions
---@field bullet_props table?
---@field pool_size number?       -- max bullets kept in pool (defaults provided)

---Create a new weapon instance.
---@param opts WeaponOptions
---@return Weapon
function M:new(opts)
  local instance = setmetatable({}, self)

  instance.id = opts.id or "weapon"
  instance.config = Table.copy(opts.config)
  instance.bullet_config = Table.merge_right(DEFAULT_BULLET_CONFIG, opts.bullet.config or {})
  instance.target = opts.target

  instance.state = {
    ammo = opts.config.ammo_capacity or 0,
    reloading = false,
    reload_timer = 0,
    cooldown = 0,
  }

  instance.bullet_pool = BulletPool:new({
    target = instance.target,
    factory_url = opts.bullet.factory_url,
    pool_size = opts.pool_size,
    bullet_props = opts.bullet_props,
  })
  return instance
end

---@param dt number
function M:_fire_cooldown_pipe(dt)
  if self.state.cooldown <= 0 then return end
  self.state.cooldown = math.max(0, self.state.cooldown - dt)
end

---@param payload WeaponFirePayload
function M:_apply_accuracy(payload)
  local accuracy = self.config.accuracy or 1
  if accuracy >= 1 then
    return payload
  end

  -- Base weapons use a small default cone; specialized weapons can override with their own spread logic.
  local max_offset_deg = DEFAULT_INACCURACY_DEGREES * (1 - accuracy)
  if max_offset_deg <= 0 then
    return payload
  end

  local direction = payload.direction or vmath.vector3(0)
  local offset_rad = math.rad((math.random() * 2 - 1) * max_offset_deg)

  local adjusted_payload = payload
  adjusted_payload.direction = VMath.rotate_direction(direction, offset_rad)
  return adjusted_payload
end

---@param payload WeaponFirePayload|nil
---@return WeaponFirePayload
function M:_build_fire_payload(payload)
  ---@type WeaponFirePayload
  local firing_payload = Table.copy(payload or {})

  firing_payload.force = self.bullet_config.force
  firing_payload.speed = self.bullet_config.speed
  firing_payload.ricochets = self.bullet_config.ricochets or 0
  firing_payload.ricochet_ray_count = self.bullet_config.ricochet_ray_count
  firing_payload.ricochet_ray_range = self.bullet_config.ricochet_ray_range
  firing_payload.ricochet_ray_start_offset = self.bullet_config.ricochet_ray_start_offset
  firing_payload.ricochet_check_obstacles = self.bullet_config.ricochet_check_obstacles

  return self:_apply_accuracy(firing_payload)
end

---@param dt number
function M:_reload_timer_pipe(dt)
  if not self.state.reloading then return end

  self.state.reload_timer = self.state.reload_timer + dt
  if self.state.reload_timer < self.config.reload_time then return end

  self:_complete_reload()
end

---Update timers (cooldown/reload).
---@param dt number
function M:update(dt)
  self:_fire_cooldown_pipe(dt)
  self:_reload_timer_pipe(dt)
end

---Check if the weapon can fire right now.
---@return boolean
function M:can_fire()
  local is_not_reloading = not self.state.reloading
  local has_ammo = self.state.ammo > 0
  local is_not_on_cooldown = self.state.cooldown <= 0
  return is_not_reloading and has_ammo and is_not_on_cooldown
end

---Attempt to fire a bullet. Returns the activated bullet or nil if blocked.
---@param payload WeaponFirePayload|nil Additional data (direction/position/etc).
---@return Bullet|nil
function M:fire(payload)
  if not self:can_fire() then
    return nil
  end

  local bullet = self.bullet_pool:acquire()
  if not bullet then
    return nil
  end

  local firing_payload = self:_build_fire_payload(payload)
  bullet:activate(firing_payload)

  self.state.cooldown = self.config.fire_interval
  self.state.ammo = math.max(0, self.state.ammo - 1)
  msg.post(".", Msg.Weapon.FIRED, {
    ammo = self.state.ammo,
    ammo_capacity = self.config.ammo_capacity,
    direction = firing_payload.direction
  })

  if self.state.ammo <= 0 then
    self:start_reload(true)
  end

  return bullet
end

---Begin reload, returns true if reload started.
---@param force? boolean
---@return boolean
function M:start_reload(force)
  if self.state.reloading then return false end
  if not force and self.state.ammo >= (self.config.ammo_capacity or 0) then return false end

  self.state.reloading = true
  self.state.reload_timer = 0
  msg.post(".", Msg.Weapon.RELOAD_STARTED)
  return true
end

function M:_complete_reload()
  self.state.reloading = false
  self.state.reload_timer = 0
  self.state.cooldown = 0
  self.state.ammo = self.config.ammo_capacity
  msg.post(".", Msg.Weapon.RELOAD_COMPLETED, {
    ammo = self.state.ammo,
    ammo_capacity = self.config.ammo_capacity,
  })
end

---Handle bullet completion (hit, timeout, etc).
---@param bullet Bullet
function M:on_bullet_hit(bullet)
  self.bullet_pool:release(bullet)
end

---Expose fraction (0..1) of the current cooldown.
---@return number
function M:get_cooldown_ratio()
  local interval = (self.config and self.config.fire_interval) or 0
  if interval <= 0 then return 0 end
  return self.state.cooldown / interval
end

---Expose fraction (0..1) of the current reload time.
---@return number|nil
function M:get_reload_ratio()
  if self.config.reload_time <= 0 then return nil end
  return self.state.reload_timer / self.config.reload_time
end

---Return how long this weapon should stay in its firing attack phase.
---@return number
function M:get_attack_duration()
  return self.config.fire_interval * self.config.ammo_capacity
end

---Check if the weapon is reloading.
---@return boolean
function M:is_reloading()
  return self.state.reloading
end

---Set the properties of the weapon.
---@param properties WeaponProperties
function M:set_properties(properties)
  self.config.fire_interval = properties.fire_interval or self.config.fire_interval
  self.config.reload_time = properties.reload_time or self.config.reload_time
  self.config.accuracy = properties.accuracy or self.config.accuracy
  self.config.bullet_damage = properties.bullet_damage or self.config.bullet_damage
  if properties.ammo_capacity then
    self.config.ammo_capacity = properties.ammo_capacity
    self.state.ammo = properties.ammo_capacity
  end
  if properties.pool_size then
    self.bullet_pool:set_pool_size(properties.pool_size)
  end

  if properties.bullet_config then
    for key, value in pairs(properties.bullet_config) do
      self.bullet_config[key] = value
    end
  end
end

---Handle bullet completion (hit, timeout, etc).
---@param bullet_id number
function M:on_bullet_finished(bullet_id)
  local bullet = self.bullet_pool:get_bullet_by_id(bullet_id)
  if not bullet then return end
  self.bullet_pool:release(bullet)
end

---Dispose pooled bullets and stop this weapon from doing further work.
function M:final()
  self.state.reloading = false
  self.state.reload_timer = 0
  self.state.cooldown = 0

  if self.bullet_pool then
    self.bullet_pool:final()
    self.bullet_pool = nil
  end
end

return M

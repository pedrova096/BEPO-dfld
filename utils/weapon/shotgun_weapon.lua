---@diagnostic disable: undefined-field
local Weapon = require("utils.weapon.weapon")

local DEFAULT_POOL_MULTIPLIER = 4

---@class ShotgunWeapon: Weapon
---@field config ShotgunWeaponConfig
local ShotgunWeapon = setmetatable({}, { __index = Weapon })
ShotgunWeapon.__index = ShotgunWeapon

---Rotate a direction vector around Z by the given radians.
---@param direction vector3
---@param radians number
---@return vector3
local function rotate_direction(direction, radians)
  local dir = vmath.normalize(direction or vmath.vector3(1, 0, 0))
  local cos_r = math.cos(radians)
  local sin_r = math.sin(radians)

  return vmath.normalize(vmath.vector3(
    dir.x * cos_r - dir.y * sin_r,
    dir.x * sin_r + dir.y * cos_r,
    dir.z
  ))
end

---@param spread_deg number
---@return number
local function random_spread_radians(spread_deg)
  if not spread_deg or spread_deg <= 0 then
    return 0
  end

  local half = spread_deg * 0.5
  local offset_deg = (math.random() * 2 - 1) * half
  return math.rad(offset_deg)
end

---Create a shotgun weapon instance.
---@param self ShotgunWeapon
---@param opts { id?: string, config: ShotgunWeaponConfig, target: WeaponTarget, bullet_config?: BulletConfig, pool_size?: number }
---@return ShotgunWeapon
function ShotgunWeapon:new(opts)
  local pool_size = opts.pool_size or ((opts.config and opts.config.pellets or 1) * DEFAULT_POOL_MULTIPLIER)
  local derived_opts = {
    id = opts.id or "shotgun",
    config = opts.config,
    target = opts.target,
    pool_size = pool_size,
    bullet_config = opts.bullet_config or (opts.config and opts.config.bullet_config),
  }

  local instance = Weapon.new(self, derived_opts)
  ---@cast instance ShotgunWeapon
  return instance
end

---Fire a shotgun blast (multiple pellets).
---@param self ShotgunWeapon
---@param payload WeaponFirePayload|nil
---@return Bullet[]|nil
function ShotgunWeapon:fire(payload)
  if not self:can_fire() then
    return nil
  end

  local pellets = self.config.pellets or 1
  local spread = (payload and payload.spread) or self.config.spread or 0
  local base_direction = vmath.normalize((payload and payload.direction) or vmath.vector3(1, 0, 0))

  local bullets = {}
  for i = 1, pellets do
    local bullet = self.bullet_pool:acquire(payload and payload.bullet_config)
    if not bullet then break end

    local angle = random_spread_radians(spread)
    local pellet_payload = {
      direction = rotate_direction(base_direction, angle),
      position = payload and payload.position or nil,
      bullet_config = payload and payload.bullet_config or nil,
    }

    local final_payload = self:_apply_accuracy(pellet_payload)
    bullet:activate(final_payload)
    bullets[#bullets + 1] = bullet
  end

  if #bullets == 0 then
    return nil
  end

  self.state.cooldown = self.config.fire_interval
  self.state.ammo = math.max(0, self.state.ammo - 1)

  if self.state.ammo <= 0 then
    self:start_reload(true)
  end

  return bullets
end

return ShotgunWeapon









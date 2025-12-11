---@diagnostic disable: duplicate-doc-field
-- ============================================================
-- Type Definitions for Weapon System (editor/LSP assistance only)
-- This file is not required at runtime.
-- ============================================================

---@class WeaponConfig
---@field fire_interval number    -- seconds between shots
---@field ammo_capacity number    -- magazine size
---@field reload_time number      -- seconds to fully reload
---@field accuracy number         -- 0..1 scalar that tightens base cone
---@field bullet_config BulletConfig
---@class WeaponFirePayload
---@field direction vector3?
---@field position vector3?
---@field bullet_config BulletConfig?
---@field spread number?

---@class ShotgunWeaponConfig : WeaponConfig
---@field pellets number          -- pellets per trigger pull
---@field spread number           -- spread angle in degrees

---@class WeaponOptions
---@field id string
---@field config WeaponConfig
---@field target userdata
---@field bullet WeaponBulletOptions
---@field pool_size number?       -- max bullets kept in pool (defaults provided)

---@class WeaponBulletOptions
---@field config BulletConfig
---@field factory_url string

---@class WeaponState
---@field ammo number
---@field reloading boolean
---@field reload_timer number
---@field cooldown number

---@class BulletConfig
---@field speed number
---@field force number

---@class SniperBulletConfig : BulletConfig
---@field penetrate number

---@class RocketLauncherBulletConfig : BulletConfig
---@field explode number
---@field explode_radius number

---@class LaserRifleBulletConfig : BulletConfig
---@field beam number
---@field beam_length number

---@class PlasmaRifleBulletConfig : BulletConfig
---@field energy number
---@field energy_consumption number

---@class Bullet
---@field id number
---@field config BulletConfig
---@field active boolean
---@field direction number
---@field position vector3|nil

return {}

---@diagnostic disable: duplicate-doc-field
-- ============================================================
-- Type Definitions for Weapon System (editor/LSP assistance only)
-- This file is not required at runtime.
-- ============================================================

---@class WeaponConfig
---@field fire_interval number    -- seconds between shots
---@field ammo_capacity number?    -- magazine size
---@field reload_time number      -- seconds to fully reload
---@field range number            -- effective weapon range
---@field accuracy number         -- 0..1 scalar that tightens base cone
---@field bullet_damage number    -- damage dealt by each fired bullet or pellet
---@field bullet_config BulletConfig

---@class WeaponFirePayload
---@field direction vector3
---@field position vector3
---@field damage number
---@field force number
---@field speed number
---@field spread number?
---@field ricochets number?                    -- remaining enemy-chain bounces for this fired bullet
---@field ricochet_ray_count number?           -- number of radial rays used to find the next ricochet target
---@field ricochet_ray_range number?           -- length of each ricochet target ray
---@field ricochet_ray_start_offset number?    -- distance from the bullet before each ricochet ray starts
---@field ricochet_check_obstacles boolean?    -- whether ricochet target rays are blocked by obstacle groups

---@class WeaponState
---@field ammo number
---@field reloading boolean
---@field reload_timer number
---@field cooldown number

---@class BulletConfig
---@field speed number
---@field force number
---@field ricochets number?                    -- enemy-chain bounces granted to each fired bullet
---@field ricochet_ray_count number?           -- number of radial rays used to find the next ricochet target
---@field ricochet_ray_range number?           -- length of each ricochet target ray
---@field ricochet_ray_start_offset number?    -- distance from the bullet before each ricochet ray starts
---@field ricochet_check_obstacles boolean?    -- whether ricochet target rays are blocked by obstacle groups

---@class WeaponProperties
---@field auto_reload boolean?
---@field reload_time number?
---@field ammo_capacity number?
---@field fire_interval number?
---@field accuracy number?
---@field bullet_damage number?
---@field pool_size number?
---@field bullet_config BulletConfig?

---@class RicochetRay
---@field angle number
---@field direction vector3

---@class RicochetState
---@field remaining number
---@field hit_targets table<userdata, boolean>
---@field rays RicochetRay[]

---@class RicochetConfig
---@field ray_count number?
---@field ray_range number?
---@field ray_start_offset number?
---@field check_obstacles boolean?
---@field obstacle_groups hash[]?

---@class RicochetOptions
---@field config RicochetConfig?

---@class RicochetResetOptions
---@field remaining number?
---@field config RicochetConfig?

---@class RicochetPayload
---@field position vector3
---@field target_group hash
---@field hit_id userdata

--#region WIP of extensible types

---@class ShotgunWeaponConfig : WeaponConfig
---@field pellets number          -- pellets per trigger pull
---@field spread number           -- spread angle in degrees
---@field pellet_spawn_width number -- width of the pellet spawn line

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

--#endregion

return {}

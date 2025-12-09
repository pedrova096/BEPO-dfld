-- ============================================================
-- Type Definitions for Stager System
-- This file is for LSP/IDE support only, not required at runtime
-- ============================================================

---@class StagesConfig
---@field waves table<number, WaveConfig>
---@field time_limit number? For "time_limit" end condition
---@field inter_wave_delay number? Seconds between waves (default 0)

---@class WaveConfig
---@field pattern "budget" | "time" Determines which wave handler is used
---@field enemies table<string, EnemyConfig>
---@field type "enemies" | "boss"? For boss_killed end condition
---@field spawn_interval number? Time interval between enemies spawns
---@field spawn_concurrent number? Max concurrent enemies to spawn

---@class WaveByBudgetConfig : WaveConfig
---@field budget number Threat points to spend

---@class WaveByTimeConfig : WaveConfig
---@field time_limit number Duration in seconds

---@class EnemyConfig
---@field id string
---@field factory_url string? Collection factory URL (optional if set on spawner)
---@field probability number Spawn weight
---@field threat number Cost/value

---@class Spawner
---@field factory_url string|url?
---@field spawn_points table<vector3>

---@class EnemySelector

---@class WaveBase
---@field config WaveConfig
---@field spawner Spawner
---@field enemy_selector EnemySelector
---@field active_enemies table
---@field completed boolean
---@field spawn_interval number
---@field spawn_concurrent number
---@field spawn_timer number

---@class EndConditionBase
---@field stager Stager

return {}

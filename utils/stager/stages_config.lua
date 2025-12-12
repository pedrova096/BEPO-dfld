-- ============================================================
-- Type Definitions (for reference)
-- ============================================================
--
-- StagesConfig:
--   waves: table<number, WaveConfig>
--   time_limit?: number (for "time_limit" end condition)
--   inter_wave_delay?: number (seconds between waves)
--
-- WaveConfig:
--   pattern: "budget" | "time" (determines which wave handler is used)
--   enemies: table<string, EnemyConfig>
--   spawn_concurrent?: number (max concurrent enemies)
--   spawn_interval?: number (seconds between enemies spawns)
--   type?: "enemies" | "boss" (for boss_killed end condition)
--
-- WaveByBudgetConfig (pattern = "budget"):
--   budget: number (threat points to spend)
--
-- WaveByTimeConfig (pattern = "time"):
--   time_limit: number (seconds)
--   spawn_interval: number (enemies per second)
--
-- EnemyConfig:
--   factory_url?: string (collection factory URL, optional if set on spawner)
--   probability: number (spawn weight)
--   threat: number (cost/value)
-- ============================================================

-- Example Stage Configuration
local Stages = {}

---@type StagesConfig
Stages[hash("Stage01")] = {
  inter_wave_delay = 2.0,
  waves = {
    -- Wave 1: Budget-based wave with basic enemies
    {
      pattern = "budget",
      type = "enemies",
      budget = 10,
      spawn_interval = 5.0,
      spawn_concurrent = 3,
      enemies = {
        enemy_01 = {
          id = "enemy_01",
          factory_url = "#cfactory_enemy_01",
          probability = 0.8,
          threat = 1,
        },
        enemy_02 = {
          id = "enemy_02",
          factory_url = "#cfactory_enemy_02",
          probability = 0.2,
          threat = 2,
        },
      },
    },
    -- Wave 2: Time-based wave
    {
      pattern = "time",
      time_limit = 15,
      spawn_interval = 0.5, -- 1 enemy every 2 seconds
      spawn_concurrent = 4,
      enemies = {
        enemy_01 = {
          id = "enemy_01",
          factory_url = "#cfactory_enemy_01",
          probability = 0.5,
          threat = 1,
        },
        enemy_02 = {
          id = "enemy_02",
          factory_url = "#cfactory_enemy_02",
          probability = 0.3,
          threat = 2,
        },
        enemy_03 = {
          id = "enemy_03",
          factory_url = "#cfactory_enemy_03",
          probability = 0.2,
          threat = 3,
        },
      },
    },
    -- Wave 3: Boss wave
    {
      pattern = "budget",
      type = "boss",
      budget = 5,
      spawn_interval = 1.0,
      spawn_concurrent = 1,
      enemies = {
        enemy_04 = {
          id = "enemy_04",
          factory_url = "#cfactory_enemy_04",
          probability = 1.0,
          threat = 5,
        },
      },
    },
  },
}

---@type StagesConfig
Stages[hash("Stage02_TimeLimited")] = {
  time_limit = 60, -- 60 seconds survival
  waves = {
    {
      pattern = "time",
      time_limit = 60,
      spawn_interval = 1.0, -- 1 enemy per second
      spawn_concurrent = 2,
      enemies = {
        enemy_01 = {
          id = "enemy_01",
          factory_url = "#cfactory_enemy_01",
          probability = 0.6,
          threat = 1,
        },
        enemy_02 = {
          id = "enemy_02",
          factory_url = "#cfactory_enemy_02",
          probability = 0.4,
          threat = 2,
        },
      },
    },
  },
}

---@type StagesConfig
Stages[hash("Stage03_BossKill")] = {
  inter_wave_delay = 3.0,
  waves = {
    -- Pre-boss wave
    {
      pattern = "budget",
      type = "enemies",
      budget = 8,
      spawn_interval = 1.0,
      spawn_concurrent = 4,
      enemies = {
        enemy_01 = {
          id = "enemy_01",
          factory_url = "#cfactory_enemy_01",
          probability = 1.0,
          threat = 2,
        },
      },
    },
    -- Boss wave
    {
      pattern = "budget",
      type = "boss",
      budget = 10,
      spawn_interval = 1.0,
      spawn_concurrent = 3,
      enemies = {
        enemy_04 = {
          id = "enemy_04",
          factory_url = "#cfactory_enemy_04",
          probability = 0.3,
          threat = 10,
        },
        enemy_01 = {
          id = "enemy_01",
          factory_url = "#cfactory_enemy_01",
          probability = 0.7,
          threat = 1,
        },
      },
    },
  },
}

return Stages

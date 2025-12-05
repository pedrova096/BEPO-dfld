# Stager Module

## Requirements

This module is responsible for managing the enemies cycle on the stage. This would go from spawning enemies to the ending of the stage. Here's some key points to consider:

- **Enemies Ranking**: We will qualify each enemy with threat/level value.
- **Wave Pattern**: Mainly we will have the next patterns to spawn enemies:
  - **By Budget**: We will have a `budget` that we will be spend to spawn enemies. This would be the main pattern.
  - **By Time**: We will have a `time_limit` and `spawn_rate` to spawn multiple enemies over time in certain amount of time. Would end once the time limit is reached.
  > **Note**: each wave would have to define the % probability of each enemy to spawn.
- **End Stage**: We will have a **end_condition** that will be used to determine if the stage has ended.
  - `clean_up`: The player would have to clear all the waves.
  - `time_limit`: The stage would end once the time limit is reached.
  - `boss_killed`: Kill the boss to end the stage.

## Implementation

```lua
function init(self)
  self.stager = Stager:new(Stages.Stage01)
end
```

### Update
```lua
function update(dt)
  self.stager:update(dt)
end
```

### Messages
```lua
local function on_enemy_killed(self, enemy)
  self.stager:on_enemy_killed(enemy)
end

local function on_stage_ended(self)
  -- We will active the doors
  for _, door in ipairs(self.doors) do
    msg.post(door, Msg.Game.OPEN_DOOR)
  end

  -- We will disable the traps
  for _, trap in ipairs(self.traps) do
    msg.post(trap, Msg.Game.DISABLE_SPAWNER)
  end
end

function on_message(self, message_id, message, sender)
  if message_id == Msg.Game.ENEMY_KILLED then
    on_enemy_killed(self, message.enemy)
  elseif message_id == Msg.Game.STAGE_ENDED then
    on_stage_ended(message)
  end
end
```

### Stages Config
```lua
---@class StagesConfig
---@field end_condition "clean_up" | "time_limit"
---@field waves table<number, WaveConfig>
---@field time_limit number? - "time_limit" end condition will use this value to end the stage.
---@field inter_wave_delay number? - Seconds between waves. By default is 0.

---@class WaveConfig
---@field enemies table<string, EnemyConfig>
---@field pattern "budget" | "time" -- Added: Explicit discriminator
---@field max_active number?        -- Added: Throttle concurrency

---@class WaveByBudgetConfig : WaveConfig
---@field type? "enemies" | "boss" - The type of the wave. By default is "enemies".
---@field budget number - The budget to spend to spawn enemies.
---@field spent number - The spent budget.

---@class WaveByTimeConfig : WaveConfig
---@field time_limit number - The time limit to spawn enemies.
---@field elapsed_time number - The elapsed time to spawn enemies.
---@field spawn_rate number - The spawn rate to spawn enemies.

---@class EnemyConfig
---@field id string - The enemy id.
---@field probability number - The probability to spawn the enemy.
---@field threat number - The threat value of the enemy.
```
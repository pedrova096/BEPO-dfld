local States = require("lib.stater.states.index")
local Stater = require("lib.stater.stater")

local M = setmetatable({}, { __index = Stater })
M.__index = M

local StatesEnum = {
  Attack = hash("attack"),
  Dead = hash("dead"),
  Hurt = hash("hurt"),
  Idle = hash("idle"),
  Move = hash("move"),
  Spawn = hash("spawn"),
  Despawn = hash("despawn"),
}

local LifeCycle = {
  [StatesEnum.Attack] = States.Enemy.Attack,
  [StatesEnum.Dead] = States.Enemy.Dead,
  [StatesEnum.Hurt] = States.Enemy.Hurt,
  [StatesEnum.Idle] = States.Enemy.Idle,
  [StatesEnum.Move] = States.Enemy.Move,
  [StatesEnum.Spawn] = States.Enemy.Spawn,
  [StatesEnum.Despawn] = States.Enemy.Despawn,
}

local Transitions = {
  [StatesEnum.Spawn] = { StatesEnum.Idle, StatesEnum.Move },
  [StatesEnum.Idle] = { StatesEnum.Move, StatesEnum.Hurt, StatesEnum.Attack, StatesEnum.Dead },
  [StatesEnum.Move] = { StatesEnum.Idle, StatesEnum.Hurt, StatesEnum.Attack, StatesEnum.Dead },
  [StatesEnum.Attack] = { StatesEnum.Move },
  [StatesEnum.Hurt] = { StatesEnum.Move, StatesEnum.Dead },
  [StatesEnum.Dead] = { StatesEnum.Despawn },
  [StatesEnum.Despawn] = { StatesEnum.Spawn },
}

M.StatesEnum = StatesEnum
M.LifeCycle = LifeCycle
M.Transitions = Transitions

function M:new(config)
  config.initial_state = StatesEnum.Despawn
  config.urls = config.urls or {
    VisualSprite = "visual#sprite",
    Visual = "visual",
    Body = "#body",
    ShadowSprite = "shadow#sprite",
    DebugIdLabel = "root#debug_id",
  }
  local instance = Stater.new(self, config)
  instance.target = config.target or nil
  return instance
end

return M

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
}

local LifeCycle = {
  [StatesEnum.Attack] = States.Enemy.Attack,
  [StatesEnum.Dead] = States.Enemy.Dead,
  [StatesEnum.Hurt] = States.Enemy.Hurt,
  [StatesEnum.Idle] = States.Enemy.Idle,
  [StatesEnum.Move] = States.Enemy.Move,
  [StatesEnum.Spawn] = States.Enemy.Spawn,
}

local Transitions = {
  [StatesEnum.Attack] = { StatesEnum.Move },
  [StatesEnum.Dead] = { StatesEnum.Spawn },
  [StatesEnum.Hurt] = { StatesEnum.Move },
  [StatesEnum.Idle] = { StatesEnum.Move, StatesEnum.Hurt, StatesEnum.Attack, StatesEnum.Dead, StatesEnum.Spawn },
  [StatesEnum.Move] = { StatesEnum.Idle, StatesEnum.Hurt, StatesEnum.Attack, StatesEnum.Dead },
  [StatesEnum.Spawn] = { StatesEnum.Move, StatesEnum.Idle, StatesEnum.Dead },
}

M.StatesEnum = StatesEnum
M.LifeCycle = LifeCycle
M.Transitions = Transitions

function M:new(config)
  local instance = Stater.new(self, config)
  instance.target = config.target or nil
  return instance
end

return M

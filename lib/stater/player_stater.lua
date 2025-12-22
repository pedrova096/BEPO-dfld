local States = require("lib.stater.states.index")
local Stater = require("lib.stater.stater")

local M = setmetatable({}, { __index = Stater })
M.__index = M

local StatesEnum = {
  Move = hash("move"),
  Hurt = hash("hurt"),
  Idle = hash("idle"),
}

local LifeCycle = {
  [StatesEnum.Move] = States.Player.Move,
  [StatesEnum.Hurt] = States.Default.Hurt,
  [StatesEnum.Idle] = States.Default.Idle,
}

local Transitions = {
  [StatesEnum.Idle] = { StatesEnum.Move, StatesEnum.Hurt },
  [StatesEnum.Move] = { StatesEnum.Idle, StatesEnum.Hurt },
  [StatesEnum.Hurt] = { StatesEnum.Idle, StatesEnum.Move },
}

M.StatesEnum = StatesEnum
M.LifeCycle = LifeCycle
M.Transitions = Transitions

function M:new(config)
  config.urls = config.urls or {
    Visual = "visual",
    VisualSprite = "visual#sprite",
    Body = "#body",
    Smoke = "smoke",
    SmokeParticle = "smoke#particle",
  }
  local instance = Stater.new(self, config)
  return instance
end

return M

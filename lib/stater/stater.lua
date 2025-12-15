local States = require("lib.stater.states.index")
local Msg = require("lib.msg")
local Table = require("utils.table")

local M = {}
M.__index = M

local StatesEnum = {
  Move = hash("move"),
  Hurt = hash("hurt"),
  Idle = hash("idle"),
}

local LifeCycle = {
  [StatesEnum.Move] = States.Default.Move,
  [StatesEnum.Hurt] = States.Default.Hurt,
  [StatesEnum.Idle] = States.Default.Idle,
}

local Transitions = {
  [StatesEnum.Idle] = { StatesEnum.Move, StatesEnum.Hurt },
  [StatesEnum.Move] = { StatesEnum.Idle, StatesEnum.Hurt },
  [StatesEnum.Hurt] = { StatesEnum.Idle },
}

local DefaultUrls = {
  Visual = "visual",
  VisualSprite = "visual#sprite",
  Body = "#body",
}

function M:new(config)
  local instance = setmetatable({}, self)
  instance.stats = config.stats or {}
  instance.direction = config.direction or vmath.vector3(0)
  instance.urls = config.urls or DefaultUrls
  instance.facing = config.facing or 1
  instance.movement_active = false
  instance:_set_state(config.initial_state or StatesEnum.Idle)
  return instance
end

function M:_set_state(state, payload)
  self.state = state
  self.payload = payload

  local life_cycle = self.LifeCycle[state]
  life_cycle.enter(self, self.payload)
end

function M:set_facing(direction_x)
  self.facing = direction_x > 0 and 1 or -1
  sprite.set_hflip(self.urls.VisualSprite, self.facing == -1)
end

function M:set_direction(direction)
  self.direction = direction
  if self.direction.x ~= 0 then
    self:set_facing(self.direction.x)
  end
end

function M:is(state)
  return self.state == state
end

function M:apply_transition(next_state, data)
  local current_state = self.state
  local transitions = self.Transitions[current_state]

  if not transitions or not Table.contains(transitions, next_state) then
    print("Invalid transition from " .. current_state .. " to " .. next_state)
    return
  end

  local current_lifecycle = self.LifeCycle[current_state]
  current_lifecycle.exit(self, self.payload)

  self:_set_state(next_state, data)

  msg.post(".", Msg.STATE_TRANSITION, {
    previous_state = current_state,
    next_state = next_state,
  })
end

---@param options.delay number - delay in seconds
---@param options.state userdata - state to transition to
---@param options.payload table - payload to transition to
function M:state_timer(options)
  if self.current_timer then
    timer.cancel(self.current_timer)
  end

  self.current_timer = timer.delay(options.delay, false, function()
    self.current_timer = nil
    self:apply_transition(options.state, options.payload)
  end)
end

function M:update(dt)
  local current_lifecycle = self.LifeCycle[self.state]
  if current_lifecycle.update then
    current_lifecycle.update(self, dt)
  end
end

M.StatesEnum = StatesEnum
M.LifeCycle = LifeCycle
M.Transitions = Transitions

return M

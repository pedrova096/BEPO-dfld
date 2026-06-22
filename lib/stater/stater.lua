local States = require("lib.stater.states.index")
local Msg = require("lib.msg")
local Table = require("utils.table")
local ManualTimer = require("utils.manual_timer")

---@class StateMachine
---@field store table Entity-owned data shared with states.
---@field direction vector3 Last movement direction applied to the entity.
---@field urls table<string, string> Defold object/component urls used by lifecycle states.
---@field facing number Horizontal facing direction, either 1 or -1.
---@field behaviors StateMachineBehavior[]
---@field behavior_enabled boolean
---@field state userdata Current state id.
---@field payload table|nil Current state payload.
---@field current_timer ManualTimer|nil
---@field current_timer_payload StateMachineTimerPayload|nil
---@field StatesEnum table<string, userdata>
---@field LifeCycle table<userdata, StateMachineState>
---@field Transitions table<userdata, userdata[]>
local M = {}
M.__index = M

---@class StateMachineState
---@field can_enter (fun(machine: StateMachine, payload: table): boolean|nil)|nil Optional transition guard. Return false to cancel entering.
---@field enter fun(machine: StateMachine, payload: table|nil)
---@field update (fun(machine: StateMachine, dt: number))|nil
---@field exit fun(machine: StateMachine, payload: table|nil, next_state: userdata)

---@class StateMachineConfig
---@field store table|nil Entity-owned data shared with states.
---@field direction vector3|nil Initial movement direction.
---@field urls table<string, string>|nil Defold object/component urls used by lifecycle states.
---@field facing number|nil Initial facing direction.
---@field behavior_enabled boolean|nil Whether behavior checks run.
---@field initial_state userdata|nil Initial state id.

---@class StateMachineBehavior
---@field state userdata State to transition into when condition passes.
---@field previous_state userdata|nil Required current state. Defaults to current state at evaluation time.
---@field condition fun(machine: StateMachine): boolean
---@field get_payload fun(): table|nil

---@class StateMachineTimerOptions
---@field delay number Delay in seconds.
---@field state userdata State to transition to after the delay.
---@field payload table|nil Payload sent to the target state.

---@class StateMachineTimerPayload
---@field state userdata
---@field payload table|nil

local StatesEnum = {
  Move = hash("move"),
  Hurt = hash("hurt"),
  Idle = hash("idle"),
}

---@type table<userdata, StateMachineState>
local LifeCycle = {
  [StatesEnum.Move] = States.Default.Move,
  [StatesEnum.Hurt] = States.Default.Hurt,
  [StatesEnum.Idle] = States.Default.Idle,
}

---@type table<userdata, userdata[]>
local Transitions = {
  [StatesEnum.Idle] = { StatesEnum.Move, StatesEnum.Hurt },
  [StatesEnum.Move] = { StatesEnum.Idle, StatesEnum.Hurt },
  [StatesEnum.Hurt] = { StatesEnum.Idle, StatesEnum.Move },
}

---@type table<string, string>
local DefaultUrls = {
  Visual = "visual",
  VisualSprite = "visual#sprite",
  Body = "#body",
}

---@param config StateMachineConfig
---@return StateMachine
function M:new(config)
  local instance = setmetatable({}, self)
  instance.store = config.store or {}
  instance.direction = config.direction or vmath.vector3(0)
  instance.urls = config.urls or DefaultUrls
  instance.facing = config.facing or 1
  instance.behaviors = {}
  instance.behavior_enabled = config.behavior_enabled ~= false
  instance:_set_state(config.initial_state or StatesEnum.Idle)
  return instance
end

---@param state userdata
---@param payload table|nil
function M:_set_state(state, payload)
  self.state = state
  self.payload = payload

  local life_cycle = self.LifeCycle[state]
  life_cycle.enter(self, self.payload)
end

---@param behaviors StateMachineBehavior[]
function M:add_behaviors(behaviors)
  self.behaviors = behaviors
end

---@param flag boolean
function M:set_behavior_flag(flag)
  self.behavior_enabled = flag
end

---@param direction_x number
function M:set_facing(direction_x)
  self.facing = direction_x > 0 and 1 or -1
  sprite.set_hflip(self.urls.VisualSprite, self.facing == -1)
end

---@param direction vector3
function M:set_direction(direction)
  self.direction = direction
  if self.direction.x ~= 0 then
    self:set_facing(self.direction.x)
  end
end

---@param state userdata
---@return boolean
function M:is(state)
  return self.state == state
end

---@param states userdata[]
---@return boolean
function M:is_in(states)
  return Table.contains(states, self.state)
end

---@param next_state userdata
---@return boolean
function M:can_transition(next_state)
  local current_state = self.state
  local transitions = self.Transitions[current_state]
  return Table.contains(transitions, next_state)
end

---@param next_state userdata
---@param data table|nil
function M:apply_transition(next_state, data)
  local current_state = self.state
  local transitions = self.Transitions[current_state]
  local payload = data or {}

  if not transitions or not Table.contains(transitions, next_state) then
    print("Invalid transition from " .. current_state .. " to " .. next_state)
    return
  end

  local next_lifecycle = self.LifeCycle[next_state]
  if next_lifecycle.can_enter and next_lifecycle.can_enter(self, payload) == false then
    return
  end

  local current_lifecycle = self.LifeCycle[current_state]
  current_lifecycle.exit(self, self.payload, next_state)

  self:_set_state(next_state, payload)

  msg.post(".", Msg.STATE_CHANGED, {
    previous_state = current_state,
    next_state = next_state,
  })
end

---@param options StateMachineTimerOptions
function M:state_timer(options)
  if self.current_timer then
    self.current_timer:stop()
  end

  self.current_timer = ManualTimer:new({
    interval = options.delay,
  })
  self.current_timer_payload = {
    state = options.state,
    payload = options.payload,
  }
  self.current_timer:start()
end

---@param dt number
function M:state_timer_pipe(dt)
  if not self.current_timer then
    return
  end

  local done = self.current_timer:update(dt)

  if not done then return end

  local timer_payload = self.current_timer_payload

  self.current_timer = nil
  self.current_timer_payload = nil

  ---@diagnostic disable-next-line: need-check-nil
  self:apply_transition(timer_payload.state, timer_payload.payload)
end

---@param behavior StateMachineBehavior
function M:apply_behavior(behavior)
  local next_state = behavior.state
  local previous_state = behavior.previous_state or self.state

  if previous_state ~= self.state or self.state == next_state then
    return
  end

  if not behavior.condition(self) then
    return
  end

  local payload = behavior.get_payload and behavior.get_payload() or {}
  self:apply_transition(next_state, payload)
end

---@param dt number
function M:behavior_pipe(dt)
  if not self.behavior_enabled then
    return
  end

  if self.current_timer then
    return
  end

  for _, behavior in pairs(self.behaviors) do
    self:apply_behavior(behavior)
  end
end

---@param dt number
function M:update(dt)
  local current_lifecycle = self.LifeCycle[self.state]
  if current_lifecycle.update then
    current_lifecycle.update(self, dt)
  end

  self:state_timer_pipe(dt)
  self:behavior_pipe(dt)
end

M.StatesEnum = StatesEnum
M.LifeCycle = LifeCycle
M.Transitions = Transitions

return M

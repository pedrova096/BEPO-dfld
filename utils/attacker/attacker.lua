---@class TimeConfig
---@field prepare number
---@field attack number
---@field recover number?
---@field cooldown number

---@class AttackerState
---@field state userdata
---@field timer number
---@field combo_number number

---@class Attacker
---@field time_config TimeConfig
---@field combo_count number
---@field state AttackerState
---@field checker Checker
---@field attack_url string
local M = {}
M.__index = M

local StatesEnum = {
  Idle = hash("idle"),
  Prepare = hash("prepare"),
  Attack = hash("attack"),
  Recover = hash("recover"),
  Cooldown = hash("cooldown"),
}

---@class AttackerOptions
---@field time_config TimeConfig
---@field combo_count number?
---@field checker Checker
---@field attack_url string?

---@param options AttackerOptions
---@return Attacker
function M:new(options)
  local instance = setmetatable({}, M)
  instance.time_config = options.time_config
  instance.combo_count = options.combo_count or 1
  instance.checker = options.checker
  instance.attack_url = options.attack_url or "."
  instance:_init()
  return instance
end

function M:_init()
  self.state = {
    state = StatesEnum.Idle,
    timer = 0,
    combo_number = 1,
  }
  self.event_configs = {
    [StatesEnum.Prepare] = {
      time = self.time_config.prepare,
      on_enter = self.on_prepare,
      on_update = self.on_prepare_update,
    },
    [StatesEnum.Attack] = {
      time = self.time_config.attack,
      on_enter = self.on_attack,
      on_update = self.on_attack_update,
    },
    [StatesEnum.Recover] = {
      time = self.time_config.recover,
      on_enter = self.on_recover,
      on_update = self.on_recover_update,
    },
    [StatesEnum.Cooldown] = {
      time = self.time_config.cooldown,
      on_enter = self.on_cooldown,
      on_update = self.on_cooldown_update,
    },
  }
end

function M:get_total_time()
  local total = 0
  for _, config in pairs(self.event_configs) do
    total = total + (config.time or 0)
  end
  return total
end

function M:_get_current_event_config()
  return self.event_configs[self.state.state]
end

function M:_is_timer_done()
  return self.state.timer <= 0 and self.state.state ~= StatesEnum.Idle
end

function M:transition(next_state)
  self.state.state = next_state
  local event_config = self:_get_current_event_config()
  if not event_config then return end

  if event_config.on_enter then
    event_config.on_enter(self)
  end
  self.state.timer = event_config.time
end

function M:_idle_pipe()
  if self.state.state ~= StatesEnum.Idle then return end
  if not self.checker:check() then return end

  self:transition(StatesEnum.Prepare)
end

function M:_prepare_pipe()
  if self.state.state ~= StatesEnum.Prepare then return end
  if not self:_is_timer_done() then return end

  self:transition(StatesEnum.Attack)
end

function M:_attack_pipe()
  if self.state.state ~= StatesEnum.Attack then return end
  if not self:_is_timer_done() then return end

  self.state.combo_number = self.state.combo_number + 1

  if self.state.combo_number >= self.combo_count then
    self:transition(StatesEnum.Cooldown)
  else
    self:transition(StatesEnum.Recover)
  end
end

function M:_recover_pipe()
  if self.state.state ~= StatesEnum.Recover then return end
  if not self:_is_timer_done() then return end

  self:transition(StatesEnum.Cooldown)
end

function M:_cooldown_pipe()
  if self.state.state ~= StatesEnum.Cooldown then return end
  if not self:_is_timer_done() then return end

  self.state.combo_number = 1
  self:transition(StatesEnum.Idle)
end

function M:_update_state(dt)
  local event_config = self:_get_current_event_config()
  if not event_config then return end
  if event_config.on_update then
    event_config.on_update(self, dt)
  end
  self.state.timer = math.max(0, self.state.timer - dt)
end

function M:update(dt)
  self:_idle_pipe()
  self:_prepare_pipe()
  self:_attack_pipe()
  self:_recover_pipe()
  self:_cooldown_pipe()
  self:_update_state(dt)
end

return M

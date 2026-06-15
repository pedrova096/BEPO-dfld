-- manual_tweener.lua
-- Manual tweener for animating values with common easing functions

local Math = require("utils.math")
local Easings = require("utils.easings")

---@class ManualTweenerParams
---@field playback number|nil Playback mode. Defaults to PLAYBACK_ONCE_FORWARD.
---@field from number|nil Start value. Defaults to 0.
---@field to number|nil Target value. Defaults to `from`.
---@field easing string|function|nil Easing name from utils.easings or a custom easing function. Defaults to linear.
---@field duration number|nil Tween duration in seconds. Defaults to 0.
---@field delay number|nil Delay before tweening in seconds. Defaults to 0.
---@field complete_function function|nil Called once when a one-shot tween completes.
---@field dt number|nil Optional initial tick applied immediately after creation.

---@class ManualTweener
---@field from number
---@field to number
---@field current number
---@field duration number
---@field delay number
---@field elapsed number
---@field delay_elapsed number
---@field playback number
---@field easing function
---@field complete_function function|nil
---@field active boolean
---@field finished boolean
local M = {}
M.__index = M

-- Playback constants (matching Defold's go.PLAYBACK_*)
M.PLAYBACK_ONCE_FORWARD = 0
M.PLAYBACK_ONCE_BACKWARD = 1
M.PLAYBACK_ONCE_PINGPONG = 2
M.PLAYBACK_LOOP_FORWARD = 3
M.PLAYBACK_LOOP_BACKWARD = 4
M.PLAYBACK_LOOP_PINGPONG = 5

M.EASING_LINEAR = "linear"
M.EASING_IN_QUAD = "in_quad"
M.EASING_OUT_QUAD = "out_quad"
M.EASING_INOUT_QUAD = "inout_quad"
M.EASING_IN_CUBIC = "in_cubic"
M.EASING_OUT_CUBIC = "out_cubic"
M.EASING_INOUT_CUBIC = "inout_cubic"
M.EASING_IN_QUART = "in_quart"
M.EASING_OUT_QUART = "out_quart"
M.EASING_INOUT_QUART = "inout_quart"
M.EASING_IN_QUINT = "in_quint"
M.EASING_OUT_QUINT = "out_quint"
M.EASING_INOUT_QUINT = "inout_quint"
M.EASING_IN_SINE = "in_sine"
M.EASING_OUT_SINE = "out_sine"
M.EASING_INOUT_SINE = "inout_sine"
M.EASING_IN_EXPO = "in_expo"
M.EASING_OUT_EXPO = "out_expo"
M.EASING_INOUT_EXPO = "inout_expo"
M.EASING_IN_CIRC = "in_circ"
M.EASING_OUT_CIRC = "out_circ"
M.EASING_INOUT_CIRC = "inout_circ"
M.EASING_IN_BACK = "in_back"
M.EASING_OUT_BACK = "out_back"
M.EASING_INOUT_BACK = "inout_back"
M.EASING_IN_ELASTIC = "in_elastic"
M.EASING_OUT_ELASTIC = "out_elastic"
M.EASING_INOUT_ELASTIC = "inout_elastic"
M.EASING_IN_BOUNCE = "in_bounce"
M.EASING_OUT_BOUNCE = "out_bounce"
M.EASING_INOUT_BOUNCE = "inout_bounce"

-- Resolve easing function from string or function
local function resolve_easing(easing)
  if type(easing) == "function" then
    return easing
  elseif type(easing) == "string" then
    return Easings[easing] or Easings.linear
  else
    -- Try to match Defold easing constants (fallback to linear)
    return Easings.linear
  end
end

local function clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

-- Private helper to calculate current value and finished state from elapsed time
local function calculate_current_and_finished(self)
  local progress = 0
  local finished = false
  local duration = math.max(self.duration, 0)

  if duration == 0 then
    if self.playback == M.PLAYBACK_ONCE_BACKWARD or self.playback == M.PLAYBACK_LOOP_BACKWARD then
      progress = 0
      return Math.lerp(self.from, self.to, self.easing(progress)), true
    end

    progress = 1
    return Math.lerp(self.from, self.to, self.easing(progress)), true
  end

  if self.playback == M.PLAYBACK_ONCE_FORWARD then
    progress = math.min(self.elapsed / duration, 1)
    finished = progress >= 1
  elseif self.playback == M.PLAYBACK_ONCE_BACKWARD then
    progress = math.min(self.elapsed / duration, 1)
    finished = progress >= 1
    progress = 1 - progress
  elseif self.playback == M.PLAYBACK_ONCE_PINGPONG then
    local cycle = self.elapsed / duration
    if cycle >= 1 then
      finished = true
      progress = 1
    elseif cycle < 0.5 then
      progress = cycle * 2
    else
      progress = 2 - cycle * 2
    end
  elseif self.playback == M.PLAYBACK_LOOP_FORWARD then
    progress = (self.elapsed % duration) / duration
  elseif self.playback == M.PLAYBACK_LOOP_BACKWARD then
    progress = 1 - ((self.elapsed % duration) / duration)
  elseif self.playback == M.PLAYBACK_LOOP_PINGPONG then
    local cycle = (self.elapsed % (duration * 2)) / duration
    if cycle < 1 then
      progress = cycle
    else
      progress = 2 - cycle
    end
  end

  local eased = self.easing(progress)
  local current = Math.lerp(self.from, self.to, eased)

  return current, finished
end

---Create a new tweener
---@param params ManualTweenerParams|nil
---@return ManualTweener
function M.create(params)
  params = params or {}
  local self = setmetatable({}, M)

  self.from = params.from or 0
  self.to = params.to or self.from
  self.current = self.from
  self.duration = math.max(params.duration or 0, 0)
  self.delay = math.max(params.delay or 0, 0)
  self.elapsed = 0
  self.delay_elapsed = 0
  self.playback = params.playback or M.PLAYBACK_ONCE_FORWARD
  self.easing = resolve_easing(params.easing)
  self.complete_function = params.complete_function
  self.active = true
  self.finished = false

  -- If dt is provided, do initial tick
  if params.dt then
    self:tick(params.dt)
  end

  return self
end

---@param params ManualTweenerParams|nil
---@return ManualTweener
function M:new(params)
  return M.create(params or {})
end

---Tick the tweener by delta time
---@param dt number -- Delta time in seconds
---@return number -- Current tweened value
function M:tick(dt)
  if not self.active or self.finished then
    return self.current
  end

  dt = math.max(dt or 0, 0)

  -- Handle delay
  if self.delay_elapsed < self.delay then
    self.delay_elapsed = self.delay_elapsed + dt
    if self.delay_elapsed < self.delay then
      return self.current
    end
    -- Delay finished, continue with tween
    dt = self.delay_elapsed - self.delay
  end

  -- Update elapsed time
  self.elapsed = self.elapsed + dt

  -- Calculate current value and finished state
  local current, finished = calculate_current_and_finished(self)
  self.current = current

  -- Handle completion
  if finished then
    self.finished = true
    self.active = false
    if self.complete_function then
      self.complete_function()
    end
  end

  return self.current
end

---Reset the tweener to start
function M:reset()
  self.elapsed = 0
  self.delay_elapsed = 0
  self.current = self.from
  self.finished = false
  self.active = true
end

---pause the tweener
function M:pause()
  self.active = false
end

---Check if tweener is active
---@return boolean
function M:is_active()
  return self.active and not self.finished
end

---Check if tweener is finished
---@return boolean
function M:is_finished()
  return self.finished
end

---Get current value
---@return number
function M:get()
  return self.current
end

---Get progress (0 to 1)
---@return number
function M:get_progress()
  if self.duration == 0 then return 1 end
  return math.min(self.elapsed / self.duration, 1)
end

---Set the target value (restarts from current)
function M:set_target(to)
  self:restart({
    from = self.current,
    to = to,
  })
end

---Set the duration
---@param duration number
function M:set_duration(duration)
  self.duration = math.max(duration or 0, 0)
end

---Set progress (0 to 1)
---@param progress number
function M:set_progress(progress)
  progress = clamp(progress, 0, 1)
  self.elapsed = progress * self.duration
  self.delay_elapsed = self.delay -- Skip past delay
  self.current = select(1, calculate_current_and_finished(self))
end

---Restart the tweener with new values.
---@param params ManualTweenerParams|nil
function M:restart(params)
  params = params or {}
  self.from = params.from ~= nil and params.from or self.current
  self.to = params.to ~= nil and params.to or self.to
  self.current = self.from
  self.duration = math.max(params.duration ~= nil and params.duration or self.duration, 0)
  self.delay = math.max(params.delay ~= nil and params.delay or self.delay, 0)
  self.elapsed = 0
  self.delay_elapsed = 0
  self.playback = params.playback or self.playback
  if params.easing ~= nil then
    self.easing = resolve_easing(params.easing)
  end
  self.complete_function = params.complete_function ~= nil and params.complete_function or self.complete_function
  self.finished = false
  self.active = true
end

-- Export easing functions for external use
---@type table<string, fun(t: number): number>
M.easing = Easings

return M

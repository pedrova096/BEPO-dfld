---@class ManualTimer
---@field interval number Seconds between ticks
---@field elapsed number Accumulated time since last tick
---@field active boolean Whether the timer is running
local M = {}
M.__index = M

---@class ManualTimerConfig
---@field interval number? Seconds between ticks (default 1)

---Create a new ManualTimer instance.
---@param config ManualTimerConfig
---@return ManualTimer
function M:new(config)
  local instance    = setmetatable({}, M)
  instance.interval = config.interval or 1
  instance.elapsed  = 0
  instance.active   = false
  return instance
end

---Start the timer, resetting elapsed time.
function M:start()
  self.active  = true
  self.elapsed = 0
end

---Stop the timer and reset elapsed time.
function M:stop()
  self.active  = false
  self.elapsed = 0
end

---Set a new tick interval.
---@param interval number Seconds between ticks
function M:set_interval(interval)
  self.interval = interval
end

---Returns true if the interval has been reached (non-consuming check).
---@return boolean
function M:is_done()
  return self.elapsed >= self.interval
end

---Get elapsed progress toward the interval, clamped from 0 to 1.
---@return number progress
function M:get_progress()
  if self.interval <= 0 then return 1 end
  return math.min(self.elapsed / self.interval, 1)
end

---Advance the timer. Returns true once per interval tick.
---Call every update or fixed_update.
---@param dt number Delta time in seconds
---@return boolean ticked True if the interval elapsed this frame
function M:update(dt)
  if not self.active then return false end
  self.elapsed = self.elapsed + dt
  if self.elapsed >= self.interval then
    self.elapsed = self.interval
    return true
  end
  return false
end

return M

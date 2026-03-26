local M = {}

function M:new(config)
  self = setmetatable({}, { __index = M })
  self.interval = config.interval or 1
  self.elapsed  = 0
  self.active   = false
  return self
end

function M:start()
  self.active  = true
  self.elapsed = 0
end

function M:stop()
  self.active  = false
  self.elapsed = 0
end

function M:set_interval(interval)
  self.interval = interval
end

-- Returns true once per interval tick. Call every update/fixed_update.
function M:update(dt)
  if not self.active then return false end
  self.elapsed = self.elapsed + dt
  if self.elapsed >= self.interval then
    self.elapsed = self.elapsed - self.interval
    return true
  end
  return false
end

return M

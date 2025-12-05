local M = {}

function M:new(config)
  self = setmetatable({}, { __index = M })
  self.duration = config.duration or 0
  self.elapsed = 0
  return self
end

function M:update(dt)
  self.elapsed = self.elapsed + dt
end

function M:is_expired()
  return self.elapsed >= self.duration
end

return M
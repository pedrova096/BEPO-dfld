local M = {}
M.__index = M

function M:new(positions)
  local instance = setmetatable({}, self)
  instance.positions = positions or {}
  instance.index = 1
  return instance
end

function M:next()
  if #self.positions == 0 then
    return vmath.vector3(0, 0, 1)
  end

  local position = self.positions[self.index]
  self.index = (self.index % #self.positions) + 1
  return position
end

return M

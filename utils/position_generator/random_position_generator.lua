local VMathUtils = require("utils.vmath")

local M = {}
M.__index = M

function M:new(max_value, min_value)
  local instance = setmetatable({}, self)
  instance.max_value = max_value or 200
  instance.min_value = min_value or -200
  return instance
end

function M:next()
  local position = VMathUtils.random_vector3(self.min_value, self.max_value)
  position.z = 1
  return position
end

return M

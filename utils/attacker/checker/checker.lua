---@class Checker
local M = {}
M.__index = M

function M:new()
  local instance = setmetatable({}, self)
  return instance
end

function M:check()
  return true
end

return M

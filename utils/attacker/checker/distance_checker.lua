local CheckerBase = require("utils.attacker.checker.checker")

---@class DistanceChecker : Checker
---@field self_id string
---@field target_id string
---@field min_distance number
local M = setmetatable({}, { __index = CheckerBase })
M.__index = M

---@class DistanceCheckerOptions
---@field self_id string?
---@field target_id string
---@field min_distance number?
---@param options DistanceCheckerOptions
---@return DistanceChecker
function M:new(options)
  ---@type DistanceChecker
  local instance = CheckerBase.new(self)
  instance.self_id = options.self_id or "."
  instance.target_id = options.target_id
  instance.min_distance = options.min_distance or 30
  return instance
end

function M:check()
  local self_position = go.get_position(self.self_id)
  local target_position = go.get_position(self.target_id)
  local distance = vmath.length(target_position - self_position)
  return distance <= self.min_distance
end

return M

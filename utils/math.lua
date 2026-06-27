local M = {}

function M.lerp(a, b, t)
  return a + (b - a) * t
end

---@param value number
---@param min number
---@param max number
---@return number
function M.clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

---Get the heading angle from a vector.
---@param vector vector3
---@return number
function M.heading_angle(vector)
  return math.atan2(vector.y, vector.x)
end

return M

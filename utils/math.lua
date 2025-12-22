local M = {}

function M.lerp(a, b, t)
  return a + (b - a) * t
end

---Get the heading angle from a vector.
---@param vector vector3
---@return number
function M.heading_angle(vector)
  return math.atan2(vector.y, vector.x)
end

return M

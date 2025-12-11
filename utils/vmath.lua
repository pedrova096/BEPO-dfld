local M = {}

function M.z_one(vector)
  return vmath.vector3(vector.x, vector.y, 1)
end

---Return a random vector3 between the given min and max values.
---@param min number
---@param max number
---@return vector3
function M.random_vector3(min, max)
  return vmath.vector3(math.random(min, max), math.random(min, max), 0)
end

---Rotate a direction vector around Z by the given angle.
---@param direction vector3
---@param angle number
---@return vector3
function M.rotate_direction(direction, angle)
  local cos_angle = math.cos(angle)
  local sin_angle = math.sin(angle)
  local x = direction.x * cos_angle - direction.y * sin_angle
  local y = direction.x * sin_angle + direction.y * cos_angle
  return vmath.vector3(x, y, 0)
end

return M

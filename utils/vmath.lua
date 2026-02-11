local M = {}

function M.z_extends(vector, z)
  return vmath.vector3(vector.x, vector.y, z)
end

function M.z_one(vector)
  return M.z_extends(vector, 1)
end

function M.z_zero(vector)
  return M.z_extends(vector, 0)
end

---Return a random vector3 between the given min and max values.
---@param min number
---@param max number
---@return vector3
function M.random_vector3(min, max)
  return vmath.vector3(math.random(min, max), math.random(min, max), 0)
end

---Returns a random direction vector3
---@return vector3
function M.random_direction()
  local angle = math.random(0, 360)
  return vmath.vector3(math.cos(angle), math.sin(angle), 0)
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

---Check if a vector is near zero.
---@param vector vector3
---@param epsilon number?
---@return boolean
function M.is_near_zero(vector, epsilon)
  epsilon = epsilon or 0.0001
  return vmath.length(vector) < epsilon
end

---Normalize a vector or return zero if it's near zero.
---@param vector vector3
---@return vector3
function M.normalize_or_zero(vector)
  if M.is_near_zero(vector) then
    return vmath.vector3(0, 0, 0)
  end
  return vmath.normalize(vector)
end

---Clamps the length of a vector to a maximum value
---@param source vector3
---@param max_length number
---@return vector3
function M.clamp_length(source, max_length)
  local length = vmath.length(source)
  if length > max_length then
    return vmath.normalize(source) * max_length
  end

  return source
end

---Checks if a vector is near a value
---@param source vector3
---@param target vector3
---@param epsilon? number
---@return boolean
function M.is_near_close_to(source, target, epsilon)
  epsilon = epsilon or 1.0
  local delta = target - source
  return vmath.length(delta) < epsilon
end

return M

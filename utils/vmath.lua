local M = {}

function M.z_one(vector)
  return vmath.vector3(vector.x, vector.y, 1)
end

function M.random_vector3(min, max)
  return vmath.vector3(math.random(min, max), math.random(min, max), 0)
end

return M
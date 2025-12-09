---@class EnemySelector
---Strategy for selecting which enemy to spawn from a pool
local M = {}
M.__index = M

---Create a new enemy selector
---@return EnemySelector
function M:new()
  return setmetatable({}, self)
end

---Select an enemy based on probability weights
---@param enemies table<string, EnemyConfig>
---@return EnemyConfig|nil
function M:select(enemies)
  if not enemies then return nil end

  local total_probability = 0
  for _, enemy in pairs(enemies) do
    total_probability = total_probability + (enemy.probability or 0)
  end

  if total_probability <= 0 then return nil end

  local roll = math.random() * total_probability
  local cumulative = 0

  for _, enemy in pairs(enemies) do
    cumulative = cumulative + (enemy.probability or 0)
    if roll <= cumulative then
      return enemy
    end
  end

  -- Fallback: return first enemy
  for _, enemy in pairs(enemies) do
    return enemy
  end

  return nil
end

---Select an enemy with max threat constraint
---@param enemies table<string, EnemyConfig>
---@param max_threat number
---@return EnemyConfig|nil
function M:select_affordable(enemies, max_threat)
  if not enemies then return nil end

  -- Filter to affordable enemies
  local affordable = {}
  for key, enemy in pairs(enemies) do
    if (enemy.threat or 0) <= max_threat then
      affordable[key] = enemy
    end
  end

  return self:select(affordable)
end

---Return the most expensive enemy
---@param enemies table<string, EnemyConfig>
---@return EnemyConfig|nil
function M:select_most_expensive(enemies)
  if not enemies then return nil end

  local most_expensive = nil
  for _, enemy in pairs(enemies) do
    if not most_expensive or enemy.threat > most_expensive.threat then
      most_expensive = enemy
    end
  end

  return most_expensive
end

return M

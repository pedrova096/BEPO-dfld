local M = {}

---Creates a shallow copy of a table.
---@generic K, V
---@param source table<K, V>
---@return table<K, V>
function M.copy(table)
  local result = {}
  for k, v in pairs(table) do
    result[k] = v
  end
  return result
end

---Merges two tables, prioritizing values from the right table.
---@generic K, V
---@param table1 table<K, V>
---@param table2 table<K, V>
---@return table<K, V>
function M.merge_right(table1, table2)
  local result = M.copy(table1)
  for k, v in pairs(table2) do
    result[k] = v
  end
  return result
end

---Removes the first matching value from a list.
---@generic T
---@param list T[]
---@param value T
---@return boolean removed
function M.remove_value(list, value)
  for i, v in ipairs(list) do
    if v == value then
      table.remove(list, i)
      return true
    end
  end
  return false
end

---Checks whether a list contains a value.
---@generic T
---@param list T[]
---@param value T
---@return boolean
function M.contains(list, value)
  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end

  return false
end

---Returns one random item from a list.
---@generic T
---@param list T[]
---@return T
function M.random(list)
  return list[math.random(1, #list)]
end

---Returns up to `n` unique random items from a list.
---@generic T
---@param list T[]
---@param n integer
---@return T[]
function M.pick_random(list, n)
  local pool = M.copy(list)
  local result = {}
  local total = math.min(n, #pool)

  for _ = 1, total do
    local index = math.random(1, #pool)
    table.insert(result, table.remove(pool, index))
  end

  return result
end

return M

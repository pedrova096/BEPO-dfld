local M = {}

function M.copy(table)
  local result = {}
  for k, v in pairs(table) do
    result[k] = v
  end
  return result
end

function M.merge_right(table1, table2)
  local result = M.copy(table1)
  for k, v in pairs(table2) do
    result[k] = v
  end
  return result
end

function M.remove_value(list, value)
  for i, v in ipairs(list) do
    if v == value then
      table.remove(list, i)
      return true
    end
  end
  return false
end

function M.contains(list, value)
  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end

  return false
end

function M.random(list)
  return list[math.random(1, #list)]
end

return M

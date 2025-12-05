local M = {}

function M.remove_value(table, value)
  for i, v in ipairs(table) do
    if v == value then
      table.remove(table, i)
      return true
    end
  end
  return false
end

function M.contains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end

  return false
end

return M
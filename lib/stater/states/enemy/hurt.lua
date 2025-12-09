local M = {}

function M:enter(_payload)
  print("Enemy state: hurt enter")
end

function M:update(_dt)
end

function M:exit()
  print("Enemy state: hurt exit")
end

return M


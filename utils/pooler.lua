local Table = require("utils.table")

---@class Pooler
---@field pool_size number
---@field available table
---@field in_use table
---@field spawner fun(i: number): any Function that creates a pooled item.
local M = {}
M.__index = M

---@class PoolerOptions
---@field pool_size number
---@field spawner fun(i: number): any Function that creates a pooled item.

---@param opts PoolerOptions
---@return table pool A new pool instance.
function M.new(opts)
  local instance = setmetatable({}, M)

  instance.pool_size = opts.pool_size
  instance.spawner = opts.spawner
  ---Items that are currently not in use and can be acquired.
  instance.available = {}
  ---Items that are currently checked‑out by the caller.
  instance.in_use = {}

  return instance
end

---Pre‑populate the pool with items created by the given factory.
---This is typically called once at startup to "warm" the pool.
---@return table self Returns the pool instance for chaining.
function M:spawn()
  for i = 1, self.pool_size do
    local item = self.spawner(i)
    table.insert(self.available, item)
  end

  return self
end

---Acquire an item from the pool.
---Moves the item from `available` to `in_use`.
---@return T|nil item The acquired item, or nil if the pool is empty.
---@return number? in_use_count The new number of in‑use items, or nil.
function M:pull()
  local item = table.remove(self.available, 1)

  if not item then
    return nil
  end

  table.insert(self.in_use, item)
  return item, #self.in_use
end

---Release the oldest in‑use item back to the pool.
---Moves the item from `in_use` to `available`.
---@return T|nil item The released item, or nil if none are in use.
---@return number? in_use_count The new number of in‑use items, or nil.
function M:push()
  local item = table.remove(self.in_use, 1)

  if not item then
    return nil, nil
  end

  table.insert(self.available, item)
  return item, #self.in_use
end

---Release a specific item back to the pool.
---If the item is not currently in use, this is a no‑op.
---@param item T The specific item to release.
function M:push_item(item)
  local removed = Table.remove_value(self.in_use, item)

  if not removed then
    return
  end

  table.insert(self.available, item)
end

---Release the item at a specific index in the in‑use collection.
---@param index number Index of the in‑use item to release.
---@return T item The released item.
function M:push_index(index)
  local item = table.remove(self.in_use, index)
  table.insert(self.available, item)
  return item
end

---Acquire a specific item from the available collection.
---If the item is not currently available, this is a no‑op.
---@param item T The item to acquire from the pool.
function M:pull_item(item)
  local _, removed = Table.remove_value(self.available, item)

  if not removed then
    return
  end

  table.insert(self.in_use, item)
end

---Get the number of available (free) items in the pool.
---@return number count Number of items in the `available` collection.
function M:available_size()
  return #self.available
end

---Get the number of in‑use (acquired) items in the pool.
---@return number count Number of items in the `in_use` collection.
function M:active_size()
  return #self.in_use
end

---Return all in‑use items back to the pool as available.
function M:reset()
  for _, item in ipairs(self.in_use) do
    table.insert(self.available, item)
  end

  self.in_use = {}
end

---Find the index of an in‑use item that matches a predicate.
---@param callback fun(item: T): boolean Predicate that returns true for the desired item.
---@return number? index Index within `in_use` if found, otherwise nil.
function M:find_index(callback)
  for i, item in ipairs(self.in_use) do
    if callback(item) then
      return i
    end
  end
end

function M:set_size(size)
  local old_size = self.pool_size
  self.pool_size = size

  if old_size < size then
    for i = old_size + 1, size do
      local item = self.spawner(i)
      table.insert(self.available, item)
    end
  else
    -- TODO: Find a way to remove items from the pool.
  end
end

-- Optional semantic aliases (non‑breaking):
-- Acquire/release naming that maps to the existing API.
M.acquire = M.pull
M.release = M.push

return M

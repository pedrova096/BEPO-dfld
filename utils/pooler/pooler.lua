---@class PoolConfig
---@field create fun(options?: any): any Factory function to create a new item
---@field reset (fun(item: any))? Called on an item before it returns to the free list

---@class PoolState
---@field free any[] items available for reuse
---@field active any[] items currently in use
---@field size number Total number of items allocated

---@class Pool
---@field config PoolConfig
---@field state PoolState
local M = {}
M.__index = M

---@class PoolOptions
---@field create_options any? Optional argument passed to the create function during pool initialization
---@field create fun(options?: any): any Factory function called once per slot at construction
---@field reset (fun(item: any))? Optional reset callback called on release
---@field size number Number of items to pre-allocate

---Create and pre-allocate a new Pool.
---@param options PoolOptions
---@return Pool
function M.new(options)
  local instance = setmetatable({}, M)

  instance.config = {
    create = options.create,
    reset  = options.reset,
  }

  local free = {}
  for i = 1, options.size do
    free[i] = options.create(options.create_options)
  end

  instance.state = {
    free   = free,
    active = {},
    size   = options.size,
  }

  return instance
end

---Acquire a free item. Returns nil when the pool is exhausted.
---@return any?
function M:acquire()
  local state = self.state
  local item = table.remove(state.free)
  if not item then return nil end

  table.insert(state.active, item)
  return item
end

---Acquire a free item by index. Returns nil if the index is out of bounds or the slot is not free.
---@param index number
---@return any?
function M:acquire_by_index(index)
  if index < 1 or index > self.state.size then return nil end

  local state = self.state
  local item = state.free[index]

  table.remove(state.free, index)
  table.insert(state.active, item)
  return item
end

---Create one new item and add it to the free list, growing the pool by one.
---@param options? any Optional argument passed to the create function, if it accepts one
function M:extend(options)
  local state = self.state
  local new_item = self.config.create(options)
  table.insert(state.free, new_item)
  state.size = state.size + 1
  return new_item
end

---Create one new item, add it directly to active, and return it.
---@param options? any Optional argument passed to the create function
---@return any
function M:extend_active(options)
  local state = self.state
  local item = self.config.create(options)
  table.insert(state.active, item)
  state.size = state.size + 1
  return item
end

---Return an item to the free list.
---@param item any
function M:release(item)
  local active = self.state.active
  for i = 1, #active do
    if active[i] == item then
      table.remove(active, i)
      break
    end
  end

  if self.config.reset then
    self.config.reset(item)
  end

  table.insert(self.state.free, item)
end

---Return an item to the free list by index.
---@param index number
function M:release_by_index(index)
  local active = self.state.active
  if index < 1 or index > #active then return end

  local item = table.remove(active, index)

  if self.config.reset then
    self.config.reset(item)
  end

  table.insert(self.state.free, item)
end

---Return all active objects to the pool at once.
function M:release_all()
  local state = self.state
  for i = #state.active, 1, -1 do
    self:release_by_index(i)
  end
end

---Number of items currently available.
---@return number
function M:count_free()
  return #self.state.free
end

---Number of items currently in use.
---@return number
function M:count_active()
  return #self.state.active
end

return M

local VMath = require("utils.vmath")
local DebugDraw = require("utils.debug_draw")

local DEFAULT_OBSTACLE_GROUPS = { hash("wall"), hash("obstacle") }

local DEFAULT_CONFIG = {
  ray_count = 24,
  ray_range = 140,
  ray_start_offset = 8,
  check_obstacles = false,
  obstacle_groups = DEFAULT_OBSTACLE_GROUPS,

  -- Debug only
  debug = false,
}

---@class Ricochet
---@field config RicochetConfig
---@field state RicochetState
local M = {}
M.__index = M

M.DefaultConfig = DEFAULT_CONFIG

local DEBUG_RAY_DURATION = 1
local DEBUG_RAY_COLOR = vmath.vector4(1, 1, 1, 0.5)
local DEBUG_HIT_COLOR = vmath.vector4(1, 0, 0, 1)

local function build_rays(ray_count)
  local rays = {}
  local angle_step = 360 / ray_count

  for i = 0, ray_count - 1 do
    local angle = angle_step * i

    table.insert(rays, {
      angle = angle,
      direction = VMath.rotate_direction(vmath.vector3(0, 1, 0), math.rad(angle)),
    })
  end

  return rays
end

local function apply_default_config(options)
  local config = options and options.config or {}

  local ray_count = math.max(1, math.floor(config.ray_count or DEFAULT_CONFIG.ray_count))

  local check_obstacles = config.check_obstacles
  if check_obstacles == nil then
    check_obstacles = DEFAULT_CONFIG.check_obstacles
  end

  local debug = config.debug
  if debug == nil then
    debug = DEFAULT_CONFIG.debug
  end

  return {
    ray_count = ray_count,
    ray_range = config.ray_range or DEFAULT_CONFIG.ray_range,
    ray_start_offset = config.ray_start_offset or DEFAULT_CONFIG.ray_start_offset,
    check_obstacles = check_obstacles,
    obstacle_groups = config.obstacle_groups or DEFAULT_CONFIG.obstacle_groups,
    debug = debug,
  }
end

---Create a new ricochet helper.
---@param options RicochetOptions?
---@return Ricochet
function M:new(options)
  local instance = setmetatable({}, self)

  instance.config = apply_default_config(options)

  instance.state = {
    remaining = 0,
    hit_targets = {},
    rays = build_rays(instance.config.ray_count),

    -- Debug only
    debug_lines = {},
  }

  return instance
end

---Reset per-bullet state and optionally refresh config.
---@param options RicochetResetOptions?
function M:reset(options)
  options = options or {}

  if options.config then
    self.config = apply_default_config(options)
    self.state.rays = build_rays(self.config.ray_count)
  end

  self.state.remaining = options.remaining or 0
  self.state.hit_targets = {}

  if self.config.debug then
    self.state.debug_lines = {}
  end
end

---Update debug drawing.
---Call this from the game object's update(self, dt).
---@param dt number
function M:update(dt)
  if not self.config.debug then
    return
  end

  local debug_lines = self.state.debug_lines
  if #debug_lines == 0 then
    return
  end

  for i = #debug_lines, 1, -1 do
    local line = debug_lines[i]

    DebugDraw.draw_line(
      line.start_point,
      line.end_point,
      line.color
    )

    line.time_left = line.time_left - dt

    if line.time_left <= 0 then
      table.remove(debug_lines, i)
    end
  end
end

function M:_debug_add_ray(start_point, end_point, color)
  if not self.config.debug then
    return
  end

  local lifted_start = VMath.z_extends(start_point, start_point.z + 1)
  local lifted_end = VMath.z_extends(end_point, end_point.z + 1)

  table.insert(self.state.debug_lines, {
    start_point = lifted_start,
    end_point = lifted_end,
    color = color or DEBUG_RAY_COLOR,
    time_left = DEBUG_RAY_DURATION,
  })
end

function M:_is_blocked(start_point, hit_position, hit_distance)
  if not self.config.check_obstacles then
    return false
  end

  local blocker = physics.raycast(start_point, hit_position, self.config.obstacle_groups)

  return blocker and blocker.fraction * hit_distance < hit_distance
end

function M:_find_next_hit(position, target_group, exclude_id)
  if self.config.ray_range <= 0 then
    return nil
  end

  local target_groups = { target_group }
  local next_hit = nil
  local next_distance = nil

  for _, ray in ipairs(self.state.rays) do
    local start_point = position + ray.direction * self.config.ray_start_offset
    local end_point = start_point + ray.direction * self.config.ray_range

    local result = physics.raycast(start_point, end_point, target_groups)

    local is_valid_hit =
        result
        and result.id ~= exclude_id
        and not self.state.hit_targets[result.id]

    if result and is_valid_hit then
      local distance = vmath.length(result.position - start_point)
      local is_blocked = self:_is_blocked(start_point, result.position, distance)

      if is_blocked then
        self:_debug_add_ray(start_point, end_point, DEBUG_RAY_COLOR)
      else
        -- Paint red only until the valid intersection.
        self:_debug_add_ray(start_point, result.position, DEBUG_HIT_COLOR)

        if not next_distance or distance < next_distance then
          next_hit = result
          next_distance = distance
        end
      end
    else
      self:_debug_add_ray(start_point, end_point, DEBUG_RAY_COLOR)
    end
  end

  return next_hit
end

---Try to consume one ricochet and return the next travel direction.
---@param payload RicochetPayload
---@return vector3|nil
function M:try_ricochet(payload)
  if self.state.remaining <= 0 then
    return nil
  end

  self.state.hit_targets[payload.hit_id] = true

  local position = VMath.z_one(payload.position)
  local next_hit = self:_find_next_hit(position, payload.target_group, payload.hit_id)

  if not next_hit then
    return nil
  end

  local direction = VMath.normalize_or_zero(next_hit.position - position)

  if VMath.is_near_zero(direction) then
    return nil
  end

  self.state.remaining = self.state.remaining - 1

  return direction
end

return M

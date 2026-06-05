local DebugDraw = require("utils.debug_draw")
local VMath = require("utils.vmath")

---@class SteerRay
---@field angle number
---@field direction vector3
---@field weight { obstacle: number; target: number }

---@class SteerState
---@field rays SteerRay[]
---@field smoothed_steer_direction vector3
---@field mode string
---@field wall_follow_side number
---@field has_line_of_sight boolean

---@class SteerConfig
---@field ray_range number
---@field start_offset number
---@field smoothing_speed number
---@field obstacle_groups hash[]
---@field velocity number

---@class Steer
---@field config SteerConfig
---@field state SteerState
local M = {}
M.__index = M

local DEFAULT_OBSTACLE_GROUPS = { hash("wall"), hash("obstacle") }
local DEFAULT_CONFIG = {
  ray_count = 18,
  start_offset = 10,
  ray_range = 20,
  smoothing_speed = 6,
  obstacle_groups = DEFAULT_OBSTACLE_GROUPS,
}

local function build_rays(ray_count)
  local rays = {}
  local angle_step = 360 / ray_count

  for i = 0, ray_count - 1 do
    local angle = angle_step * i
    table.insert(rays, {
      angle = angle,
      weight = { obstacle = 0, target = 0 },
      direction = VMath.rotate_direction(vmath.vector3(0, 1, 0), math.rad(angle)),
    })
  end

  return rays
end

local function apply_default_config(options)
  local config = options.config or {}
  return {
    ray_count = config.ray_count or DEFAULT_CONFIG.ray_count,
    start_offset = config.start_offset or DEFAULT_CONFIG.start_offset,
    ray_range = config.ray_range or DEFAULT_CONFIG.ray_range,
    smoothing_speed = config.smoothing_speed or DEFAULT_CONFIG.smoothing_speed,
    obstacle_groups = config.obstacle_groups or DEFAULT_CONFIG.obstacle_groups,
    velocity = config.velocity or DEFAULT_CONFIG.velocity,
  }
end

local ModesEnum = {
  Seek = "seek",
  WallFollow = "wall_follow",
  -- TODO:
  Flee = "flee",
  Strafe = "Strafe",
}

---@class SteerPayload
---@field position vector3
---@field target_position vector3
---@field debug boolean?

---@class SteerOptions : SteerConfig
---@field ray_count number

---Create a new steer instance.
---@param options SteerOptions
---@return Steer
function M:new(options)
  local instance = setmetatable({}, self)
  instance.config = apply_default_config(options)
  instance.state = {
    rays = build_rays(options.ray_count or DEFAULT_CONFIG.ray_count),
    mode = ModesEnum.Seek,
    wall_follow_side = 1,
    has_line_of_sight = false,
    smoothed_steer_direction = vmath.vector3(0, -1, 0),
  }
  return instance
end

function M:_compute_obstacle_weight(start_point, end_point)
  local obstacle_raycast = physics.raycast(start_point, end_point, self.config.obstacle_groups)
  if obstacle_raycast then
    return 1 - obstacle_raycast.fraction
  end

  return 0
end

function M:_compute_target_weight(direction, target_position, position)
  local to_target = target_position - position
  if VMath.is_near_zero(to_target) then
    return 0
  end

  local dot = vmath.dot(direction, vmath.normalize(to_target))
  if dot < 0.55 then
    return 0
  end

  -- round to 4 decimal places
  return math.floor(dot * 10000) / 10000
end

function M:_draw_weight_debug(start_point, direction, weight, color)
  if weight <= 0 then return end
  local lifted_start = VMath.z_extends(start_point, start_point.z + 1)
  local hit_point = lifted_start + direction * self.config.ray_range * math.abs(weight)
  DebugDraw.draw_line(lifted_start, hit_point, color)
end

function M:_compute_rays(position, target_position, debug)
  for _, ray in ipairs(self.state.rays) do
    local direction = ray.direction
    local start_point = position + direction * self.config.start_offset
    local end_point = start_point + direction * self.config.ray_range

    ray.weight.obstacle = self:_compute_obstacle_weight(start_point, end_point)
    ray.weight.target = self:_compute_target_weight(direction, target_position, position)

    if debug then
      DebugDraw.draw_line(start_point, end_point, vmath.vector4(0, 0, 0, 0.6))

      self:_draw_weight_debug(start_point, direction, ray.weight.target, vmath.vector4(0, 0, 1, 1))
      self:_draw_weight_debug(start_point, direction, ray.weight.obstacle, vmath.vector4(1, 0, 0, 1))
    end
  end
end

function M:_compute_avg_directions()
  local target_direction = vmath.vector3(0, 0, 0)
  local obstacle_direction = vmath.vector3(0, 0, 0)
  for _, ray in ipairs(self.state.rays) do
    target_direction = target_direction + ray.direction * ray.weight.target
    obstacle_direction = obstacle_direction + ray.direction * ray.weight.obstacle
  end

  target_direction = VMath.normalize_or_zero(target_direction / #self.state.rays)
  obstacle_direction = vmath.length(obstacle_direction) > 0.5 and
      vmath.normalize(obstacle_direction / #self.state.rays) or
      vmath.vector3()
  return target_direction, obstacle_direction
end

function M:_compute_avg_obstacle_weight()
  local weight_sum = 0
  local hit_count = 0

  for _, ray in ipairs(self.state.rays) do
    if ray.weight.obstacle > 0 then
      weight_sum = weight_sum + ray.weight.obstacle
      hit_count = hit_count + 1
    end
  end

  if hit_count == 0 then
    return 0
  end

  return weight_sum / hit_count
end

local MIN_OBSTACLE_WEIGHT_THRESHOLD = 0.15
local MIN_DIRECTION_OVERLAP_THRESHOLD = 0.5
function M:_resolve_steer_mode(target_direction, obstacle_direction)
  local avg_obstacle_weight = self:_compute_avg_obstacle_weight()
  local direction_dot = vmath.dot(target_direction, obstacle_direction)
  local has_line_of_sight = self.state.has_line_of_sight
  if has_line_of_sight or
      avg_obstacle_weight <= MIN_OBSTACLE_WEIGHT_THRESHOLD or
      direction_dot <= MIN_DIRECTION_OVERLAP_THRESHOLD then
    return ModesEnum.Seek
  end

  return ModesEnum.WallFollow
end

function M:_compute_steer_direction(dt, new_direction)
  local alpha = 1 - math.exp(-dt * self.config.smoothing_speed)

  self.state.smoothed_steer_direction = vmath.lerp(alpha, self.state.smoothed_steer_direction, new_direction)

  if VMath.is_near_zero(self.state.smoothed_steer_direction) then
    return vmath.vector3(0)
  end

  return vmath.normalize(self.state.smoothed_steer_direction)
end

function M:_update_wall_follow(dt, options)
  local position = options.position
  local obstacle_direction = options.obstacle_direction
  local debug = options.debug

  local direction = VMath.rotate_direction(obstacle_direction, math.rad(90 * self.state.wall_follow_side))
  local steer_direction = self:_compute_steer_direction(dt, direction)

  if debug then
    local point = position + steer_direction * self.config.start_offset * 2
    DebugDraw.draw_circle(point, 4, vmath.vector4(0, 1, 1, 1))
  end

  return steer_direction
end

function M:_update_seek(dt, options)
  local target_direction = options.target_direction
  local obstacle_direction = options.obstacle_direction
  local position = options.position
  local debug = options.debug

  local direction = VMath.normalize_or_zero(target_direction - obstacle_direction)


  local steer_direction = self:_compute_steer_direction(dt, direction)

  if debug then
    local steer_point = position + direction * self.config.start_offset * 2
    DebugDraw.draw_circle(steer_point, 4, vmath.vector4(0, 1, 0, 1))
  end

  return steer_direction
end

---Update the steer instance.
---@param dt number
---@param payload SteerPayload
function M:update(dt, payload)
  local position = payload.position
  local target_position = payload.target_position
  local debug = payload.debug or false

  self:_compute_rays(position, target_position, debug)

  local avg_target_direction, avg_obstacle_direction = self:_compute_avg_directions()

  local current_mode = self.state.mode
  self.state.has_line_of_sight = physics.raycast(position, target_position, self.config.obstacle_groups) == nil
  self.state.mode = self:_resolve_steer_mode(avg_target_direction, avg_obstacle_direction)
  if debug then
    local steer_point = position + avg_target_direction * self.config.start_offset * 2
    DebugDraw.draw_circle(steer_point, 4, vmath.vector4(0, 1, 0, 1))

    local obstacle_point = position + avg_obstacle_direction * self.config.start_offset * 2
    DebugDraw.draw_circle(obstacle_point, 4, vmath.vector4(1, 0, 0, 1))
  end

  if self.state.mode == ModesEnum.WallFollow then
    if current_mode ~= self.state.mode then
      local left = VMath.rotate_direction(avg_obstacle_direction, math.rad(90))
      local right = VMath.rotate_direction(avg_obstacle_direction, math.rad(-90))
      self.state.wall_follow_side =
          vmath.dot(left, avg_target_direction) >= vmath.dot(right, avg_target_direction)
          and 1 or -1
    end

    return self:_update_wall_follow(dt, {
      position = position,
      obstacle_direction = avg_obstacle_direction,
      debug = debug,
    })
  end

  return self:_update_seek(dt, {
    position = position,
    target_direction = avg_target_direction,
    obstacle_direction = avg_obstacle_direction,
    debug = debug
  })
end

function M:get_is_target_on_sight()
  return self.state.has_line_of_sight
end

return M

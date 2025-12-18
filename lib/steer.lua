local DebugDraw = require("utils.debug_draw")
local VMath = require("utils.vmath")

---@class SteerRay
---@field angle number
---@field direction vector3
---@field weight { obstacle: number; target: number }

---@class SteerState
---@field rays SteerRay[]
---@field target_on_sight boolean
---@field smoothed_steer_direction vector3
---@field steer_bias number
---@field safe_distance_direction number
---@field safe_change_direction_frame_count integer

---@class SteerConfig
---@field ray_range number
---@field start_offset number
---@field smoothing_speed number
---@field safe_distance number
---@field obstacle_groups hash[]
---@field velocity number

---@class Steer
---@field config SteerConfig
---@field state SteerState
local M = {}
M.__index = M

local DEFAULT_OBSTACLE_GROUPS = { hash("wall"), hash("obstacle") }
local DEFAULT_CONFIG = {
  ray_count = 12,
  start_offset = 10,
  ray_range = 20,
  smoothing_speed = 6,
  safe_distance = 60,
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
    safe_distance = config.safe_distance or DEFAULT_CONFIG.safe_distance,
    obstacle_groups = config.obstacle_groups or DEFAULT_CONFIG.obstacle_groups,
    velocity = config.velocity or DEFAULT_CONFIG.velocity,
  }
end

---@class SteerPayload
---@field position vector3
---@field target_position vector3
---@field debug boolean?
---@field enable_safe_distance boolean?

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
    target_on_sight = false,
    smoothed_steer_direction = vmath.vector3(0, -1, 0),
    steer_bias = 1, -- math.random() * 2 - 1,
    -- TODO: Review this
    safe_distance_direction = 1,
    safe_change_direction_frame_count = 0,
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

  target_direction = vmath.normalize(target_direction / #self.state.rays)
  obstacle_direction = vmath.length(obstacle_direction) > 0.5 and
      vmath.normalize(obstacle_direction / #self.state.rays) or
      vmath.vector3()
  return target_direction, obstacle_direction
end

local MIN_VECTOR_DISTANCE_THRESHOLD = 0.5
function M:_get_target_on_sight(avg_target_direction, avg_obstacle_direction)
  local dot = vmath.dot(avg_target_direction, avg_obstacle_direction)
  return dot < MIN_VECTOR_DISTANCE_THRESHOLD
end

local BIAS_ANGLE = 45
function M:_apply_target_bias(avg_target_direction)
  return VMath.rotate_direction(avg_target_direction, math.rad(BIAS_ANGLE) * self.state.steer_bias)
end

-- TODO: Refactor
function M:_apply_safe_distance(direction, obstacle_direction, position, target_position)
  local distance = vmath.length(position - target_position)

  if distance < self.config.safe_distance then
    if vmath.length(obstacle_direction) > 0.95 and self.state.safe_change_direction_frame_count == 0 then
      self.safe_distance_direction = -self.safe_distance_direction
      self.safe_change_direction_frame_count = 20
    end

    self.safe_change_direction_frame_count = math.max(0, self.safe_change_direction_frame_count - 1)

    direction = VMath.rotate_direction(direction, math.rad(90) * self.state.safe_distance_direction)
  end

  return direction
end

function M:_compute_steer_direction(dt, new_direction)
  local alpha = 1 - math.exp(-dt * self.config.smoothing_speed)

  self.state.smoothed_steer_direction = vmath.lerp(alpha, self.state.smoothed_steer_direction, new_direction)

  if VMath.is_near_zero(self.state.smoothed_steer_direction) then
    return vmath.vector3(0)
  end

  return vmath.normalize(self.state.smoothed_steer_direction)
end

---Update the steer instance.
---@param dt number
---@param payload SteerPayload
function M:update(dt, payload)
  local position = payload.position
  local target_position = payload.target_position
  local debug = payload.debug or false
  local enable_safe_distance = payload.enable_safe_distance or false

  self:_compute_rays(position, target_position, debug)

  local avg_target_direction, avg_obstacle_direction = self:_compute_avg_directions()
  self.state.target_on_sight = self:_get_target_on_sight(avg_target_direction, avg_obstacle_direction)

  if debug and self.state.target_on_sight then
    local target_average_point = position + avg_target_direction * self.config.start_offset * 2
    DebugDraw.draw_circle(target_average_point, 4, vmath.vector4(0, 0, 1, 1))
  end


  if not self.state.target_on_sight then
    avg_target_direction = self:_apply_target_bias(avg_target_direction)

    if debug then
      local target_bias_point = position + avg_target_direction * self.config.start_offset * 2
      DebugDraw.draw_circle(target_bias_point, 4, vmath.vector4(0, 1, 1, 1))
    end
  end

  local direction = vmath.normalize(avg_target_direction - avg_obstacle_direction)

  if enable_safe_distance then
    direction = self:_apply_safe_distance(direction, avg_obstacle_direction, position, target_position)
  end

  local steer_direction = self:_compute_steer_direction(dt, direction)

  if debug then
    local steer_point = position + steer_direction * self.config.start_offset * 2
    DebugDraw.draw_circle(steer_point, 4, vmath.vector4(0, 1, 0, 1))

    local obstacle_average_point = position - avg_obstacle_direction * self.config.start_offset * 2
    DebugDraw.draw_circle(obstacle_average_point, 4, vmath.vector4(1, 0, 0, 1))
  end

  return steer_direction
end

return M

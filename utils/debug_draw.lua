local M = {}

function M.draw_line(start_point, end_point, color)
  msg.post("@render:", "draw_line", {
    start_point = start_point,
    end_point = end_point,
    color = color,
  })
end

local CIRCLE_SEGMENTS = 12
function M.draw_circle(position, radius, color)
  local base_angle = math.pi * 2 / CIRCLE_SEGMENTS
  local start = position + vmath.vector3(radius, 0, 0)
  local previous_point = start
  for i = 0, CIRCLE_SEGMENTS do
    local angle = i * base_angle
    local x = position.x + radius * math.cos(angle)
    local y = position.y + radius * math.sin(angle)
    local end_point = vmath.vector3(x, y, 0)
    M.draw_line(previous_point, end_point, color)
    previous_point = end_point
  end

  M.draw_line(position + vmath.vector3(-radius, 0, 0), position + vmath.vector3(radius, 0, 0), color)
  M.draw_line(position + vmath.vector3(0, -radius, 0), position + vmath.vector3(0, radius, 0), color)
end

return M

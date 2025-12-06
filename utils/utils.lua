local M = {}

function M.get_display_size()
  local display_width = sys.get_config_int("display.width")
  local display_height = sys.get_config_int("display.height")

  return display_width, display_height
end

function M.get_zoom_level()
  local display_width, display_height = M.get_display_size()
  local windows_width, windows_height = window.get_size()

  local zoom_level = math.min(windows_width / display_width, windows_height / display_height)

  return zoom_level
end

function M.camera_to_world_coordinates(point, display, camera_url)
  local projection = go.get(camera_url, "projection")
  local view = go.get(camera_url, "view")
  local w, h = window.get_size()
  -- The window.get_size() function will return the scaled window size,
  -- ie taking into account display scaling (Retina screens on macOS for
  -- instance). We need to adjust for display scaling in our calculation.
  w = w / (w / display.width)
  h = h / (h / display.height)

  -- https://defold.com/manuals/camera/#converting-mouse-to-world-coordinates
  local inv = vmath.inv(projection * view)
  local x = (2 * point.x / w) - 1
  local y = (2 * point.y / h) - 1
  local z = (2 * point.z) - 1
  local x1 = x * inv.m00 + y * inv.m01 + z * inv.m02 + inv.m03
  local y1 = x * inv.m10 + y * inv.m11 + z * inv.m12 + inv.m13
  local z1 = x * inv.m20 + y * inv.m21 + z * inv.m22 + inv.m23
  return vmath.vector3(x1, y1, z1)
end

return M
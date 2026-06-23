local Msg = require("lib.msg")

local M = {}

local DEFAULT_DT_FACTOR = 1

local dt_factor = DEFAULT_DT_FACTOR
local registered_urls = {}

local function notify_change(prev_factor, new_factor)
  for _, url in pairs(registered_urls) do
    msg.post(url, Msg.Game.GAME_TIME_CHANGED, {
      prev_factor = prev_factor,
      new_factor = new_factor,
    })
  end
end

function M.set_dt_factor(factor)
  local prev_factor = dt_factor
  dt_factor = math.max(0, factor or DEFAULT_DT_FACTOR)

  if prev_factor ~= dt_factor then
    notify_change(prev_factor, dt_factor)
  end
end

function M.get_dt_factor()
  return dt_factor
end

function M.register_id(url)
  url = url or go.get_id()
  registered_urls[url] = url
end

function M.unregister_id(url)
  url = url or go.get_id()
  registered_urls[url] = nil
end

function M.scale(dt)
  return dt * dt_factor
end

function M.apply_sprite_playback_rate(sprite_url)
  go.set(sprite_url, "playback_rate", dt_factor)
end

function M.apply_linear_velocity(body_url, value)
  go.set(body_url, "linear_velocity", value * dt_factor)
end

function M.on_change(message, url_sprite, url_body)
  local new_factor = message.new_factor or dt_factor
  local prev_factor = message.prev_factor or DEFAULT_DT_FACTOR

  if url_sprite then
    go.set(url_sprite, "playback_rate", new_factor)
  end

  if not url_body or prev_factor <= 0 then return end

  ---@type vector3
  local linear_velocity = go.get(url_body, "linear_velocity")

  if vmath.length(linear_velocity) > 0 then
    go.set(url_body, "linear_velocity", linear_velocity * new_factor / prev_factor)
  end
end

function M.reset()
  dt_factor = DEFAULT_DT_FACTOR
  registered_urls = {}
end

return M

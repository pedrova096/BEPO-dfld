local LimitStateTimer = require("lib.stater.limit_state_timer")
local Entity = require("utils.entity")

local M = {}

function M:enter()
  Entity.show_sprite(self.urls.VisualSprite)
  Entity.show_sprite(self.urls.ShadowSprite)
  local duration = self.payload.duration or 0.4

  sprite.play_flipbook(self.urls.VisualSprite, "spawn")

  self.payload.limit_timer = LimitStateTimer:new({
    duration = duration,
  })
  go.animate(
    self.urls.Visual, "scale", go.PLAYBACK_LOOP_PINGPONG, vmath.vector3(0.75, 0.75, 1), go.EASING_INOUTCUBIC, 0.2
  )

  if self.urls.DebugIdLabel then
    label.set_text(self.urls.DebugIdLabel, "" .. go.get_id())
  end
end

function M:update(dt)
  self.payload.limit_timer:update(dt)

  if self.payload.limit_timer:is_expired() then
    Entity.enable_body(self.urls.Body)
    self:apply_transition(self.StatesEnum.Move, {})
  end
end

function M:exit()
  go.cancel_animations(self.urls.Visual, "scale")
  go.set(self.urls.Visual, "scale", vmath.vector3(1, 1, 1))
end

return M

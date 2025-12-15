local LimitStateTimer = require("lib.stater.limit_state_timer")

local M = {}

function M:enter(_payload)
  sprite.play_flipbook(self.urls.VisualSprite, "dead")

  local duration = self.payload.duration or 0.25
  self.payload.limit_timer = LimitStateTimer:new({
    duration = duration,
  })
end

function M:update(dt)
  self.payload.limit_timer:update(dt)

  if self.payload.limit_timer:is_expired() then
    self:apply_transition(self.StatesEnum.Despawn, {})
  end
end

function M:exit()
  print("Enemy state: dead exit")
end

return M

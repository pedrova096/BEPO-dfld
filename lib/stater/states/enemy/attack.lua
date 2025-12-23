local LimitStateTimer = require("lib.stater.limit_state_timer")

local M = {}

function M:enter(payload)
  sprite.play_flipbook(self.urls.VisualSprite, "attack")
  local attacker = payload.attacker

  local duration = attacker:get_total_time()
  self.payload.limit_timer = LimitStateTimer:new({
    duration = duration,
  })
end

function M:update(dt)
  self.payload.limit_timer:update(dt)

  if self.payload.limit_timer:is_expired() then
    local next_state = self.StatesEnum.Move
    self:apply_transition(next_state, {})
  end
end

function M:exit()
  self.payload.attacker:reset()
end

return M

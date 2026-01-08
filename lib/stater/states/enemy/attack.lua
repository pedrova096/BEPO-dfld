local LimitStateTimer = require("lib.stater.limit_state_timer")

local M = {}

function M:enter(payload)
  sprite.play_flipbook(self.urls.VisualSprite, "attack")
  local attacker = payload.attacker

  attacker:execute()
  local duration = attacker:get_total_time_without_cooldown()
  self.payload.limit_timer = LimitStateTimer:new({
    duration = duration,
  })
end

function M:update(dt)
  self.payload.limit_timer:update(dt)

  if self.payload.limit_timer:is_expired() then
    local next_state = self.stats.health > 0 and self.StatesEnum.Move or self.StatesEnum.Dead
    self:apply_transition(next_state, {})
  end
end

function M:exit(payload, next_state)
  if next_state == self.StatesEnum.Dead then
    self.payload.attacker:reset()
  end
end

return M

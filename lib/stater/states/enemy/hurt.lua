local LimitStateTimer = require("lib.stater.limit_state_timer")
local VMath = require("utils.vmath")
local M = {}

function M:enter(payload)
  local direction = payload.direction
  local hit_force = payload.force
  local damage = payload.damage
  local duration = payload.duration or 0.35

  self.stats.health = math.max(0, self.stats.health - damage)
  self.payload.limit_timer = LimitStateTimer:new({
    duration = duration,
  })
  go.set(self.urls.Body, "linear_velocity", VMath.z_one(direction * hit_force))
  sprite.play_flipbook(self.urls.VisualSprite, "hurt")
end

function M:update(dt)
  self.payload.limit_timer:update(dt)

  if self.payload.limit_timer:is_expired() then
    local next_state = self.stats.health > 0 and self.StatesEnum.Move or self.StatesEnum.Dead
    self:apply_transition(next_state, {})
  end
end

function M:exit()
  go.set(self.urls.Body, "linear_velocity", vmath.vector3(0))
end

return M

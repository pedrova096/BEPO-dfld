local LimitStateTimer = require("lib.stater.limit_state_timer")
local VMath = require("utils.vmath")
local GameTime = require("modules.game_time")
local M = {}

function M:enter(payload)
  local direction = payload.direction
  local hit_force = payload.force
  local duration = payload.duration or 0.35

  self.payload.limit_timer = LimitStateTimer:new({
    duration = duration,
  })
  local velocity = VMath.z_one(direction * hit_force)

  GameTime.apply_linear_velocity(self.urls.Body, velocity)
  sprite.play_flipbook(self.urls.VisualSprite, "hurt")
  -- if self.urls.ParticleHit1 then
  --   particlefx.play(self.urls.ParticleHit1)
  -- end
end

function M:update(dt)
  self.payload.limit_timer:update(dt)

  if self.payload.limit_timer:is_expired() then
    local next_state = self.store.health > 0 and self.StatesEnum.Move or self.StatesEnum.Dead
    self:apply_transition(next_state, {})
  end
end

function M:exit()
  go.set(self.urls.Body, "linear_velocity", vmath.vector3(0))
end

return M

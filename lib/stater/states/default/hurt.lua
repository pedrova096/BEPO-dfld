local VMath = require("utils.vmath")

local M = {}

function M:enter()
  sprite.play_flipbook(self.urls.VisualSprite, "hurt")

  local duration = self.payload.duration or 0.35
  local direction = self.payload.direction
  local hit_force = self.payload.force

  self.payload.limit_timer = LimitStateTimer:new({
    duration = duration,
  })

  if direction and hit_force then
    go.set(self.urls.Body, "linear_velocity", VMath.z_one(direction * hit_force))
  end
end

function M:update(dt)
  self.payload.limit_timer:update(dt)
  
  if self.payload.limit_timer:is_expired() then
    local next_state = self.movement_active and StatesEnum.Move or StatesEnum.Idle
    self:apply_transition(next_state, {})
  end

end

function M:exit()
  go.set(self.urls.Body, "linear_velocity", vmath.vector3(0))
end

return M
local VMath = require("utils.vmath")

local M = {}

function M:enter()
  sprite.play_flipbook(self.urls.VisualSprite, "move")
  particlefx.play(self.urls.SmokeParticle)
  self.payload.last_smoke_facing = 1 -- 1 to the right, -1 to the left
end

local SMOKE_ROTATION_VALUE = 76
local function update_smoke_facing(self)
  if self.payload.smoke_facing == self.facing then return end

  self.payload.smoke_facing = self.facing
  go.set(self.urls.Smoke, "euler.z", SMOKE_ROTATION_VALUE * self.payload.smoke_facing)
end

function M:update(dt)
  local direction = self.direction
  local velocity = direction * self.stats.velocity

  update_smoke_facing(self)

  go.set(self.urls.Body, "linear_velocity", VMath.z_one(velocity))
end

function M:exit()
  go.set(self.urls.Body, "linear_velocity", vmath.vector3(0))
  sprite.play_flipbook(self.urls.VisualSprite, "idle")
  particlefx.stop(self.urls.SmokeParticle)
  go.set(self.urls.Smoke, "euler.z", 0)
end

return M

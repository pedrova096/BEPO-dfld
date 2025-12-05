local VMath = require("utils.vmath")

local M = {}

function M:enter()
  sprite.play_flipbook(self.urls.VisualSprite, "move")
end

function M:update(dt)
  local direction = self.direction
  local velocity = direction * self.stats.velocity
  
  go.set(self.urls.Body, "linear_velocity", VMath.z_one(velocity))
end

function M:exit()
  go.set(self.urls.Body, "linear_velocity", vmath.vector3(0))
  sprite.play_flipbook(self.urls.VisualSprite, "idle")
end

return M
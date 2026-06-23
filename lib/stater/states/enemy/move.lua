local VMath = require("utils.vmath")
local GameTime = require("modules.game_time")

local M = {}

function M:enter()
  sprite.play_flipbook(self.urls.VisualSprite, "move")
end

function M:update(dt)
  local direction = self.direction
  local velocity = VMath.z_one(direction * self.store.velocity)


  GameTime.apply_linear_velocity(self.urls.Body, velocity)
end

function M:exit()
  go.set(self.urls.Body, "linear_velocity", vmath.vector3(0))
  sprite.play_flipbook(self.urls.VisualSprite, "idle")
end

return M

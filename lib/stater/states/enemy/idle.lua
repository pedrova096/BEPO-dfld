local M = {}

function M:enter(_payload)
  sprite.play_flipbook(self.urls.VisualSprite, "idle")
end

function M:update(_dt)
end

function M:exit()
  print("Enemy state: idle exit")
end

return M

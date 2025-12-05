local M = {}

function M:enter()
  sprite.play_flipbook(self.urls.VisualSprite, "idle")
end

function M:exit()
end

return M
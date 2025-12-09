local M = {}

function M:enter(_payload)
  sprite.play_flipbook(self.urls.VisualSprite, "attack")
end

function M:update(_dt)
end

function M:exit()
  print("Enemy state: attack exit")
end

return M

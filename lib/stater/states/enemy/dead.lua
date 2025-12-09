local M = {}

function M:enter(_payload)
  sprite.play_flipbook(self.urls.VisualSprite, "dead")
end

function M:update(_dt)
end

function M:exit()
  print("Enemy state: dead exit")
end

return M

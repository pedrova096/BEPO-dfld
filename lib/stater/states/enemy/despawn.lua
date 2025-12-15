local Entity = require("utils.entity")
local M = {}

function M:enter()
  Entity.hide_entity()
  Entity.hide_sprite(self.urls.ShadowSprite)
  if self.urls.DebugIdLabel then
    label.set_text(self.urls.DebugIdLabel, "")
  end
end

function M:exit()
end

return M

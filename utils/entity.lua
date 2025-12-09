local M = {}

local DefaultUrls = {
  sprite = "visual#sprite",
  body = "#body",
}

--- Hide the sprite by setting its alpha to 0.
---@param url? string The URL of the sprite component (optional, defaults to DefaultUrls.sprite if used via hide_entity)
function M.hide_sprite(url)
  url = url or DefaultUrls.sprite
  go.set(url, "tint.w", 0)
end

--- Show the sprite by setting its alpha to 1.
---@param url? string The URL of the sprite component (optional, defaults to DefaultUrls.sprite if used via show_entity)
function M.show_sprite(url)
  url = url or DefaultUrls.sprite
  go.set(url, "tint.w", 1)
end

--- Disable the physics body.
---@param url? string The URL of the body component (optional, defaults to DefaultUrls.body if used via hide_entity)
function M.disable_body(url)
  url = url or DefaultUrls.body
  msg.post(url, "disabled")
end

--- Enable the physics body.
---@param url? string The URL of the body component (optional, defaults to DefaultUrls.body if used via show_entity)
function M.enable_body(url)
  url = url or DefaultUrls.body
  msg.post(url, "enabled")
end

--- Hide both the sprite and the body of an entity.
---@param urls? table<{sprite:string, body:string}> Table of component URLs to use. All fields optional and will use DefaultUrls defaults if not provided.
function M.hide_entity(urls)
  urls = urls or DefaultUrls
  M.hide_sprite(urls.sprite)
  M.disable_body(urls.body)
end

--- Show both the sprite and the body of an entity.
---@param urls? table<{sprite:string, body:string}> Table of component URLs to use. All fields optional and will use DefaultUrls defaults if not provided.
function M.show_entity(urls)
  urls = urls or DefaultUrls
  M.show_sprite(urls.sprite)
  M.enable_body(urls.body)
end

return M

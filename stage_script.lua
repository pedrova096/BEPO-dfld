-- Require LuaFileSystem
local lfs = require("lfs")

local directory = "./main/game/stages/stage_01/"
local stage_pattern = "^tiles_lg.tilemap$"
local obstacle_pattern = "^tiles_sm.tilemap$"

local function get_files()
  local stage_file = ""
  local obstacle_file = ""

  for file in lfs.dir(directory) do
    if file ~= "." and file ~= ".." then
      local full_path = directory .. file

      local attr = lfs.attributes(full_path)
      if attr and attr.mode == "file" then
        if file:match(stage_pattern) then
          stage_file = full_path
        end

        if file:match(obstacle_pattern) then
          obstacle_file = full_path
        end
      end
    end
  end

  return stage_file, obstacle_file
end


local stage_file, obstacle_file = get_files()
print("Stage Tilemap file: " .. stage_file, "\nObstacle Tilemap file: " .. obstacle_file)

local OBJECT_TEMPLATE = [[
components {
  id: "tileset"
  component: "$STAGE_PATH"
}
embedded_components {
  id: "static"
  type: "collisionobject"
  data: "collision_shape: \"$STAGE_PATH\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"$GROUP\"\n"
  "mask: \"player\"\n"
  "mask: \"bullet\"\n"
  "mask: \"enemy\"\n"
  ""
}
]]

local OBJECT_TEMPLATE_WITHOUT_STATIC = [[
components {
  id: "tileset"
  component: "$STAGE_PATH"
}
]]

local function create_go_file(path, group, with_static)
  local renamed = path:gsub(".tilemap$", ".go")
  local template = with_static and OBJECT_TEMPLATE or OBJECT_TEMPLATE_WITHOUT_STATIC
  local content = template:gsub("$STAGE_PATH", path:sub(2)):gsub("$GROUP", group)
  print("Creating go file: " .. renamed)
  local file = io.open(renamed, "w")
  file:write(content)
  file:close()
end

create_go_file(stage_file, "wall", true)
create_go_file(obstacle_file, "obstacle", true)

local top_tilemap_template = [[
tile_set: "/assets/sprites/tiles/tiles_sm.tilesource"
layers {
  id: "layer"
  z: 0.0
$CELLS
}
material: "/builtins/materials/tile_map.material"
]]

local function create_top_obstacle()
  local file = io.open(obstacle_file, "r")
  local content = file:read("*all")
  file:close()
  local lines = {}
  for line in content:gmatch("[^\r\n]+") do
    table.insert(lines, line .. "\n")
  end

  local cells = ""
  for i = 1, #lines do
    local line = lines[i]
    -- if line contains "cell {"
    if line:match("cell {") then
      if lines[i + 3]:match("tile: 1") then
        local result = lines[i] .. lines[i + 1] .. lines[i + 2] .. lines[i + 3] .. lines[i + 4]
        cells = cells .. result
      end
      i = i + 3
    end
  end

  cells = cells:sub(1, #cells - 1)
  local top_obstacle_file = obstacle_file:gsub("tiles_sm", "top_tiles_sm")
  print("Creating top obstacle file: " .. top_obstacle_file)
  local file = io.open(top_obstacle_file, "w")
  local content = top_tilemap_template:gsub("$CELLS", cells)
  file:write(content)
  file:close()

  create_go_file(top_obstacle_file, "obstacle", false)
end

create_top_obstacle()

--- Utility helpers for reading stage landmark data from tilemaps.
--- @class TilesInfo
local M = {}
M.__index = M

--- Large tile size in pixels.
--- @type number
M.TILE_LG_SIZE = 48

--- Small tile size in pixels.
--- @type number
M.TILE_SM_SIZE = 24

--- Landmark ids used in the `landmarks` tile layer.
--- @class LandmarksEnum
--- @field Door integer
--- @field Spawn integer
--- @field Upgrader integer
M.LandmarksEnum = {
  Door = 5,
  Spawn = 6,
  Upgrader = 7,
}

--- Bounds data returned from a tilemap query.
--- @class TileBounds
--- @field left integer
--- @field bottom integer
--- @field columns_count integer
--- @field rows_count integer

--- Door location extracted from the landmarks layer.
--- @class DoorPosition
--- @field position vector3
--- @field column_index integer
--- @field row_index integer

--- Parsed landmark info for a stage.
--- @class LandmarkInfo
--- @field spawn_positions vector3[]
--- @field doors_positions DoorPosition[]
--- @field upgrader_position vector3|nil

--- Options for `get_landmark_info`.
--- @class LandmarkInfoOptions
--- @field offset vector3 World offset applied to all tile positions.
--- @field landmarks_tiles table 2D tile array returned by `tilemap.get_tiles`.
--- @field bounds TileBounds Tilemap bounds for the landmarks layer.

--- Options for `get_doors_positions`.
--- @class DoorsPositionsOptions
--- @field offset vector3 World offset applied to all tile positions.
--- @field bounds TileBounds Tilemap bounds for the landmarks layer.
--- @field doors_amount number Tile count for doors

--- Compute the expected door column indices for a tilemap width.
--- @param doors_amount number
--- @param bounds TileBounds
--- @return integer[]
function M._get_doors_index(doors_amount, bounds)
  local half_width = math.ceil(bounds.columns_count / 2)

  if doors_amount == 2 then
    return { half_width - 1, half_width + 1 }
  elseif doors_amount == 1 then
    return { half_width }
  else
    error(("Unsupported doors amount %s"):format(tostring(doors_amount)))
  end
end

--- Collect all door positions from the landmarks tile layer.
--- @param options DoorsPositionsOptions
--- @return DoorPosition[]
function M.get_doors_positions(options)
  local TOP_ROW = 0
  local doors_positions = {}
  local offset = options.offset
  local doors_amount = options.doors_amount
  local bounds = options.bounds

  local doors_indexes = M._get_doors_index(doors_amount, bounds)
  local half_tile = M.TILE_LG_SIZE / 2

  for _, door_index in ipairs(doors_indexes) do
    local column_index = door_index - bounds.left + 1
    local x = column_index * M.TILE_LG_SIZE - half_tile
    local position = vmath.vector3(x, 0, 1) + offset

    table.insert(doors_positions, {
      position = position,
      column_index = column_index,
      row_index = TOP_ROW,
    })
  end

  return doors_positions
end

--- Parse the landmarks tile layer into spawn, door, and upgrader positions.
--- @param options LandmarkInfoOptions
--- @return LandmarkInfo
function M.get_landmark_info(options)
  local spawn_positions = {}
  local upgrader_position = nil

  local offset = options.offset
  local landmarks = options.landmarks_tiles
  local bounds = options.bounds
  local tile_center = vmath.vector3(M.TILE_SM_SIZE / 2, M.TILE_SM_SIZE / 2, 0)
  for row_index = bounds.bottom, bounds.bottom + bounds.rows_count - 1 do
    for column_index = bounds.left, bounds.left + bounds.columns_count - 1 do
      local tile = landmarks[row_index][column_index]

      local x = column_index * M.TILE_SM_SIZE
      local y = row_index * M.TILE_SM_SIZE

      local position = vmath.vector3(x, y, 1) + offset
      local center_position = position - tile_center

      if tile == M.LandmarksEnum.Spawn then
        table.insert(spawn_positions, center_position)
      elseif tile == M.LandmarksEnum.Upgrader then
        upgrader_position = center_position
      end
    end
  end

  return {
    spawn_positions = spawn_positions,
    upgrader_position = upgrader_position,
  }
end

--- Fetch tilemap bounds and return them in a reusable table.
--- @param tile_name hash|string|url Tilemap component id.
--- @return TileBounds
function M.get_bounds(tile_name)
  local left, bottom, columns_count, rows_count = tilemap.get_bounds(tile_name)

  return {
    left = left,
    bottom = bottom,
    columns_count = columns_count,
    rows_count = rows_count
  }
end

return M

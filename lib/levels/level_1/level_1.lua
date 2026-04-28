local Stage1 = require("lib.levels.level_1.stage_1")
local Stage2 = require("lib.levels.level_1.stage_2")

return {
  id = "level_1",
  start = hash("stage_1"),
  stages = {
    [hash("stage_1")] = {
      data = Stage1,
      doors = { hash("stage_2"), hash("stage_2") }
    },
    [hash("stage_2")] = {
      data = Stage2,
      doors = nil
    }
  }
}

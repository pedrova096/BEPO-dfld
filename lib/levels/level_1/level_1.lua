local Stage1 = require("lib.levels.level_1.stage_1")
local Stage2 = require("lib.levels.level_1.stage_2")

--- @type LevelConfig
return {
  id = hash("level_1"),
  start = hash("stage_1"),
  stages = {
    [hash("stage_1")] = {
      data = Stage1,
      connections = { hash("stage_2") }
    },
    [hash("stage_2")] = {
      data = Stage2,
      connections = { hash("stage_3") }
    },
    [hash("stage_3")] = {
      data = Stage2,
      connections = { hash("stage_4") }
    },
    [hash("stage_4")] = {
      data = Stage2,
      connections = nil
    }
  }
}

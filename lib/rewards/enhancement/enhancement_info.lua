local EnhancementType = require("lib.rewards.enhancement.enhancement_type")

local Types = {
  Ricochet = {
    id = EnhancementType.Ricochet,
    title = "Ricochet",
    value = 1,
  }
}

return {
  Types = Types,
  List = { Types.Ricochet }
}

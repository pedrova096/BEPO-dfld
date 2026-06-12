local SpecialType = require("lib.rewards.special.special_type")

local Types = {
  Bomb = {
    id = SpecialType.Bomb,
    title = "Bomba",
    value = 1,
    killing_recharge = 3,
  }
}

return {
  Types = Types,
  List = { Types.Bomb }
}

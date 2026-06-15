local SpecialType = require("lib.rewards.special.special_type")

local Types = {
  [SpecialType.Bomb] = {
    id = SpecialType.Bomb,
    title = "Bomba",
    movable = true,
    initial_uses = 1,
    recharge_value = 3,
    recharge_type = "kill",
  }
}

return {
  Types = Types,
  List = { Types[SpecialType.Bomb] }
}

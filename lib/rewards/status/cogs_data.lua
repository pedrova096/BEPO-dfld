local UpgradeType = require("lib.rewards.status.upgrade_type")

local Types = {
  [UpgradeType.Life] = {
    id = UpgradeType.Life,
    icon = "cog_icon_life",
    text = "+Salud",
    value = 1,
  },
  [UpgradeType.Velocity] = {
    id = UpgradeType.Velocity,
    icon = "cog_icon_velocity",
    text = "+Velocidad",
    value = 1,
  },
  [UpgradeType.CriticalChance] = {
    id = UpgradeType.CriticalChance,
    icon = "cog_icon_critic",
    text = "+Critico",
    value = 0.1,
  },
  [UpgradeType.Damage] = {
    id = UpgradeType.Damage,
    icon = "cog_icon_damage",
    text = "+Daño",
    value = 1
  },
}

return {
  Types = Types,
  List = { Types[UpgradeType.Life], Types[UpgradeType.Velocity], Types[UpgradeType.CriticalChance], Types[UpgradeType.Damage] }
}

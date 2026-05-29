local RewardTypes = require("lib.rewards.reward_types")
local StatusUpgrade = require("lib.rewards.status.upgrade_type")

local M = {}

M.RewardTypes = {
  [RewardTypes.StatusSelector] = {
    name = "Selector de estados",
    icon = "cog_set_icon",
  },
  [RewardTypes.SpecificStatus] = {
    name = "Estado especifico",
    icon = "cog_icon",
  },
  [RewardTypes.SpecialAction] = {
    name = "Mejora especial",
    icon = "toolbox_icon",
  },
  [RewardTypes.EnhancementUpgrade] = {
    name = "Mejora de potenciador",
    icon = "toolbox_icon",
  },
}

M.StatusUpgrades = {
  [StatusUpgrade.Ammo] = {
    name = "Municion",
    icon = "cog_icon_ammo",
  },
  [StatusUpgrade.Velocity] = {
    name = "Velocidad",
    icon = "cog_icon_velocity",
  },
  [StatusUpgrade.Life] = {
    name = "Salud",
    icon = "cog_icon_life",
  },
  [StatusUpgrade.Damage] = {
    name = "Dano",
    icon = "cog_icon_damage",
  },
  [StatusUpgrade.CriticalChance] = {
    name = "Critico",
    icon = "cog_icon_critic",
  },
}

M.RewardTypeIds = {
  RewardTypes.StatusSelector,
  RewardTypes.SpecificStatus,
  RewardTypes.SpecialAction,
  RewardTypes.EnhancementUpgrade,
}

M.StatusUpgradeIds = {
  StatusUpgrade.Ammo,
  StatusUpgrade.Velocity,
  StatusUpgrade.Life,
  StatusUpgrade.Damage,
  StatusUpgrade.CriticalChance,
}

function M.get_name(reward, reward_variant)
  if reward == RewardTypes.SpecificStatus and reward_variant then
    local status = M.StatusUpgrades[reward_variant]
    if status then
      return "++" .. status.name
    end
  end

  local reward_info = M.RewardTypes[reward]
  return reward_info and reward_info.name or ""
end

function M.get_icon(reward, reward_variant)
  if reward == RewardTypes.SpecificStatus and reward_variant then
    local status = M.StatusUpgrades[reward_variant]
    if status then
      return status.icon
    end
  end

  local reward_info = M.RewardTypes[reward]
  return reward_info and reward_info.icon or ""
end

return M

local Rewards = require("lib.rewards.reward_types")

return {
  [Rewards.StatusSelector] = require("lib.rewards.status_selector"),
  [Rewards.SpecialAction] = require("lib.rewards.special_actions"),
  [Rewards.EnhancementUpgrade] = require("lib.rewards.enhancement_upgrade"),
}

local AttackerBase = require("utils.attacker.attacker")
local Msg = require("lib.msg")

local M = setmetatable({}, { __index = AttackerBase })
M.__index = M

function M:new(options)
  local instance = AttackerBase.new(self, options)
  setmetatable(instance, M)
  instance:_init()
  return instance
end

function M:on_prepare()
  msg.post(self.attack_url, Msg.Attacker.PREPARE, {
    time = self.time_config.prepare,
  })
end

function M:on_attack()
  msg.post(self.attack_url, Msg.Weapon.TRIGGER_WEAPON, {
    direction = self.state.direction,
  })
end

function M:on_cooldown()
  msg.post(self.attack_url, Msg.Weapon.RELEASE_WEAPON, {
    time = self.time_config.cooldown,
  })
end

function M:set_direction(direction)
  self.state.direction = direction
  msg.post(self.attack_url, Msg.Attacker.SET_DIRECTION, {
    direction = direction,
  })
end

function M:on_reset()
  self.state.direction = nil
  msg.post(self.attack_url, Msg.Attacker.RESET)
end

return M

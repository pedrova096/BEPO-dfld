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
  local combo_number = self.state.combo_number
  msg.post(self.attack_url, Msg.Attacker.ATTACK, {
    combo_number = combo_number,
    time = self.time_config.attack,
  })
end

function M:on_recover()
  msg.post(self.attack_url, Msg.Attacker.PREPARE, {
    time = self.time_config.recover,
  })
end

function M:on_cooldown()
  self.state.direction = nil
  msg.post(self.attack_url, Msg.Attacker.COOLDOWN, {
    time = self.time_config.cooldown,
  })
end

function M:set_direction(direction)
  self.state.direction = direction
  msg.post(self.attack_url, Msg.Attacker.SET_DIRECTION, {
    direction = direction,
  })
end

return M

local AttackerBase = require("utils.attacker.attacker")
local Msg = require("lib.msg")

local M = setmetatable({}, { __index = AttackerBase })
M.__index = M

function M:on_prepare()
  msg.post(".", Msg.Attacker.PREPARE)
end

function M:on_attack()
  local combo_number = self.state.combo_number
  msg.post(self.attack_url, Msg.Attacker.ATTACK, {
    combo_number = combo_number,
  })
end

function M:on_recover()
  msg.post(self.attack_url, Msg.Attacker.PREPARE)
end

function M:on_cooldown()
  msg.post(self.attack_url, Msg.Attacker.COOLDOWN)
end

return M

--- WeaponAttack module.
--- @class WeaponAttack : AttackModule

local AttackModule = require("utils.attacker.attack_module")
local Msg = require("lib.msg")

local M = setmetatable({}, { __index = AttackModule })
M.__index = M

local function normalize_times(options)
  local times = options.times
  if times then
    return {
      windup = times.windup or 0,
      attack = times.attack or 0,
      recovery = times.recovery or 0,
    }
  end

  local time_config = options.time_config or {}
  return {
    windup = time_config.prepare or 0,
    attack = time_config.attack or 0,
    recovery = time_config.recover or 0,
  }
end

--- @param options table
--- @return WeaponAttack
function M:new(options)
  options = options or {}

  local instance = AttackModule.new(self, {
    times = normalize_times(options),
    urls = options.urls or {
      Root = options.attack_url,
    },
    attack_checker = options.attack_checker or options.checker,
    cooldown = options.cooldown or (options.time_config and options.time_config.cooldown) or 1.0,
  })

  instance.attack_url = options.attack_url or (instance.urls and instance.urls.Root)
  instance.state = {
    direction = nil,
  }

  return instance
end

function M:on_windup_start()
  if not self.attack_url then return end

  msg.post(self.attack_url, Msg.Attacker.START_WINDUP, {
    time = self.times.windup,
  })
end

function M:on_attack_start()
  AttackModule.on_attack_start(self)

  if not self.attack_url then return end

  msg.post(self.attack_url, Msg.Weapon.FIRE, {
    direction = self.state.direction,
  })
end

function M:on_attack_exit()
  if not self.attack_url then return end

  msg.post(self.attack_url, Msg.Weapon.STOP_FIRING, {
    time = self.cooldown,
  })
end

function M:set_direction(direction)
  self.state.direction = direction

  if not self.attack_url then return end

  msg.post(self.attack_url, Msg.Attacker.SET_DIRECTION, {
    direction = direction,
  })
end

function M:set_time_config(time_config)
  time_config = time_config or {}
  self.times.windup = time_config.prepare or self.times.windup or 0
  self.times.attack = time_config.attack or self.times.attack or 0
  self.times.recovery = time_config.recover or 0
  self.cooldown = time_config.cooldown or self.cooldown
end

function M:can_attack()
  return self:can_execute()
end

function M:get_total_time_without_cooldown()
  return self:get_total_time()
end

function M:reset()
  self.status = AttackModule.AttackStatus.Idle
  self.cooldown_dt = 0
  self.current = {}
  self.state.direction = nil

  if not self.attack_url then return end

  msg.post(self.attack_url, Msg.Weapon.STOP_FIRING)
  msg.post(self.attack_url, Msg.Attacker.RESET)
end

return M

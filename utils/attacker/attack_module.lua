--- AttackModule — base class for all melee attack types.

--- @class AttackModule
--- @field status string
--- @field times { windup: number, attack: number, recovery?: number }
--- @field urls table
--- @field attack_checker table
--- @field cooldown number
--- @field cooldown_dt number
--- @field current table
local M = {}
M.__index = M

M.AttackStatus = {
    Idle = "Idle",
    Windup = "Windup",
    Attack = "Attack",
    Recovery = "Recovery",
}

--- @class AttackModuleOptions
--- @field times { windup: number, attack: number, recovery?: number }
--- @field urls { Root: string, Visual: string, VisualSprite: string, Target: userdata }
--- @field attack_checker? table object with a can_execute() method
--- @field cooldown? number seconds before this attack can fire again (default 1.0)

--- Creates a new AttackModule instance.
--- @param proto table the subclass metatable (or M itself for base instances)
--- @param options AttackModuleOptions
--- @return AttackModule
function M.new(proto, options)
    local instance = setmetatable({}, proto or M)

    instance.status = M.AttackStatus.Idle
    instance.times = options.times
    instance.urls = options.urls
    instance.attack_checker = options.attack_checker
    instance.cooldown = options.cooldown or 1.0
    instance.cooldown_dt = 0
    instance.current = {}

    return instance
end

function M:on_windup_start() end

function M:on_windup_exit() end

function M:on_attack_start()
    self.current.elapsed = 0
end

function M:on_attack_exit() end

function M:on_recovery_start() end

function M:on_recovery_exit() end

function M:_tick_idle(dt)
    if self.status ~= M.AttackStatus.Idle then return end

    if self.cooldown_dt > 0 then
        self.cooldown_dt = math.max(0, self.cooldown_dt - dt)
    end
end

function M:_tick_windup(dt)
    if self.status ~= M.AttackStatus.Windup then return end

    self.current.elapsed = (self.current.elapsed or 0) + dt

    if self.current.elapsed >= self.times.windup then
        self:on_windup_exit()
        self.status = M.AttackStatus.Attack
        self:on_attack_start()
    end
end

function M:_tick_attack(dt)
    if self.status ~= M.AttackStatus.Attack then return end

    self.current.elapsed = (self.current.elapsed or 0) + dt

    if self.current.elapsed >= self.times.attack then
        self:on_attack_exit()

        local recovery = self.times.recovery or 0
        if recovery > 0 then
            self.status = M.AttackStatus.Recovery
            self.current.elapsed = 0
        else
            self:_finish()
        end
    end
end

function M:_tick_recovery(dt)
    if self.status ~= M.AttackStatus.Recovery then return end

    self.current.elapsed = (self.current.elapsed or 0) + dt

    if self.current.elapsed >= (self.times.recovery or 0) then
        self:on_recovery_exit()
        self:_finish()
    end
end

function M:_finish()
    self.status = M.AttackStatus.Idle
    self.cooldown_dt = self.cooldown
    self.current = {}
end

--- Returns the total time of the attack (windup + attack + recovery).
--- @return number
function M:get_total_time()
    return self.times.windup + self.times.attack + (self.times.recovery or 0)
end

--- Returns true when this attack is ready and the checker approves.
--- @return boolean
function M:can_execute()
    if self.status ~= M.AttackStatus.Idle then return false end
    if self.cooldown_dt > 0 then return false end
    if self.attack_checker and not self.attack_checker:can_execute() then return false end
    return true
end

--- Starts the attack. No-op when not in IDLE.
function M:execute()
    if self.status ~= M.AttackStatus.Idle then return end
    self.status = M.AttackStatus.Windup
    self.current.elapsed = 0
    self:on_windup_start()
end

--- Advances the state machine. Subclasses call this first, then run their own pipes.
--- @param dt number delta time in seconds
function M:update(dt)
    self:_tick_idle(dt)
    self:_tick_windup(dt)
    self:_tick_attack(dt)
    self:_tick_recovery(dt)
end

--- Force the attack back to IDLE (starts cooldown). Safe to call from any phase.
function M:interrupt()
    if self.status == M.AttackStatus.Idle then return end
    if self.status == M.AttackStatus.Windup then
        self:on_windup_exit()
    elseif self.status == M.AttackStatus.Attack then
        self:on_attack_exit()
    elseif self.status == M.AttackStatus.Recovery then
        self:on_recovery_exit()
    end
    self:_finish()
end

--- @return boolean
function M:is_idle()
    return self.status == M.AttackStatus.Idle
end

--- @return boolean
function M:is_windup()
    return self.status == M.AttackStatus.Windup
end

--- @return boolean true in WINDUP, ATTACK, or RECOVERY
function M:is_attacking()
    return self.status ~= M.AttackStatus.Idle
end

--- @return boolean
function M:is_on_cooldown()
    return self.cooldown_dt > 0
end

return M

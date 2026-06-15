--- @class SpecialActionConfig
--- @field id hash|string Special action id.
--- @field max_uses number|nil Maximum stored uses.
--- @field required_recharge number|nil Recharge required to restore one use.
--- @field recharge_type string|nil Source type used to recharge the action.

--- @class SpecialActionOptions : SpecialActionConfig
--- @field recharge number|nil Initial recharge progress.

--- Runtime state for a player special action.
--- @class SpecialAction : SpecialActionConfig
--- @field uses number Current available uses.
--- @field recharge number Current recharge progress.
--- @field status "idle"|"ready"|"recharging"|"empty" Current availability status.
local M = {}
M.__index = M

local DEFAULT_MAX_USES = 1
local DEFAULT_REQUIRED_RECHARGE = 0

local SpecialActionStatus = {
	Idle = "idle",
	Ready = "ready",
	Recharging = "recharging",
	Empty = "empty",
}

M.Status = SpecialActionStatus

local function get_status(self)
	if not self.id then
		return SpecialActionStatus.Idle
	end

	if self.uses > 0 then
		return SpecialActionStatus.Ready
	end

	if self.required_recharge > 0 and self.recharge > 0 then
		return SpecialActionStatus.Recharging
	end

	return SpecialActionStatus.Empty
end

local function refresh_status(self)
	self.status = get_status(self)
end

--- Create a new special action runtime.
--- @param config SpecialActionOptions|nil Initial config and state.
--- @return SpecialAction
function M:new(config)
	config = config or {}

	local max_uses = config.max_uses or DEFAULT_MAX_USES
	local instance = setmetatable({
		id = config.id,
		max_uses = max_uses,
		required_recharge = config.required_recharge or DEFAULT_REQUIRED_RECHARGE,
		recharge_type = config.recharge_type,
		uses = max_uses,
		recharge = config.recharge or 0,
		status = SpecialActionStatus.Idle,
	}, self)

	refresh_status(instance)
	return instance
end

--- Assign the action values
--- @param config SpecialActionOptions
function M:set_action(config)
	self.id = config.id
	self.max_uses = config.max_uses or DEFAULT_MAX_USES
	self.required_recharge = config.required_recharge or DEFAULT_REQUIRED_RECHARGE
	self.recharge_type = config.recharge_type
	self.uses = self.max_uses
	self.recharge = config.recharge or 0
	refresh_status(self)
end

--- Return current recharge progress value and maximum.
--- @return number value
--- @return number length
function M:get_recharge_progress()
	if self.required_recharge <= 0 then
		return 1, 1
	end

	if self.uses > 0 then
		return self.required_recharge, self.required_recharge
	end

	return self.recharge, self.required_recharge
end

--- Return whether the action has a runtime object and at least one use.
--- @return boolean
function M:is_ready()
	return self.status == SpecialActionStatus.Ready
end

--- Add recharge progress and restore uses when enough charge is collected.
--- @param amount number|nil Recharge amount.
--- @return boolean is_ready Whether the action can be used after recharge.
function M:add_recharge(amount)
	amount = amount or 1

	if self.uses < self.max_uses then
		self.recharge = math.min(self.recharge + amount, self.required_recharge)

		if self.recharge >= self.required_recharge then
			self.uses = self.max_uses
			self.recharge = 0
		end
	end

	refresh_status(self)
	return self:is_ready()
end

--- Consume one use if the action is ready.
--- @return boolean consumed Whether a use was consumed.
function M:consume()
	if not self:is_ready() then
		return false
	end

	self.uses = self.uses - 1
	refresh_status(self)
	return true
end

return M

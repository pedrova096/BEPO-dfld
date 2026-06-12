--- @class SpecialActionConfig
--- @field id hash|string Special action id.
--- @field max_uses number|nil Maximum stored uses.
--- @field required_recharge number|nil Recharge required to restore one use.

--- @class SpecialActionOptions : SpecialActionConfig
--- @field object_id hash|nil Runtime object id. Can be assigned later with `set_object_id`.

--- @class SpecialActionState
--- @field uses number Current available uses.
--- @field recharge number Current recharge progress.
--- @field object_id hash|nil Runtime object id. Can be assigned later with `set_object_id`.
--- @field status "idle"|"ready"|"recharging"|"empty" Current availability status.

--- Runtime state for a player special action.
--- Keeps stable config on the instance and mutable values inside `state`.
--- @class SpecialAction : SpecialActionConfig
--- @field state SpecialActionState Mutable runtime state.
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

local function get_status(state, required_recharge)
	if not state.object_id then
		return SpecialActionStatus.Idle
	end

	if state.uses > 0 then
		return SpecialActionStatus.Ready
	end

	if required_recharge > 0 and state.recharge > 0 then
		return SpecialActionStatus.Recharging
	end

	return SpecialActionStatus.Empty
end

local function refresh_status(self)
	self.state.status = get_status(self.state, self.required_recharge)
end

--- Create a new special action runtime.
--- @param config SpecialActionOptions|nil Initial config and state.
--- @return SpecialAction
function M:new(config)
	config = config or {}

	return setmetatable({
		id = config.id,
		max_uses = config.max_uses or DEFAULT_MAX_USES,
		required_recharge = config.required_recharge or DEFAULT_REQUIRED_RECHARGE,
		state = {
			uses = 0,
			recharge = 0,
			status = SpecialActionStatus.Idle,
			object_id = config.object_id,
		},
	}, self)
end

--- Assign the action values
--- @param config SpecialActionOptions
function M:set_action(config)
	self.id = config.id
	self.max_uses = config.max_uses
	self.required_recharge = config.required_recharge
	self.state.object_id = config.object_id
	refresh_status(self)
end

--- Return current recharge progress from 0 to 1.
--- @return number
function M:get_recharge_ratio()
	if self.required_recharge <= 0 then
		return 1
	end

	return self.state.recharge / self.required_recharge
end

--- Return whether the action has a runtime object and at least one use.
--- @return boolean
function M:is_ready()
	return self.state.status == SpecialActionStatus.Ready
end

--- Add recharge progress and restore uses when enough charge is collected.
--- @param amount number|nil Recharge amount.
--- @return boolean is_ready Whether the action can be used after recharge.
function M:add_recharge(amount)
	amount = amount or 1

	if self.state.uses < self.max_uses then
		self.state.recharge = math.min(self.state.recharge + amount, self.required_recharge)

		if self.state.recharge >= self.required_recharge then
			self.state.uses = self.max_uses
			self.state.recharge = 0
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

	self.state.uses = self.state.uses - 1
	refresh_status(self)
	return true
end

return M

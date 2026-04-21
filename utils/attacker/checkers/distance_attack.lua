--- DistanceAttackChecker

--- @class DistanceAttackChecker
local M = {}
M.__index = M

--- @class DistanceAttackCheckerOptions
--- @field target userdata target game object URL or id
--- @field max_distance number world-unit radius that must be satisfied

--- @param options DistanceAttackCheckerOptions
--- @return DistanceAttackChecker
function M:new(options)
    local instance = setmetatable({}, M)
    instance.target = options.target
    instance.max_distance = options.max_distance or 30
    return instance
end

--- Returns true when the owner is within max_distance of the target.
--- Measured in world space so it works regardless of parent transforms.
--- @return boolean
function M:can_execute()
    if not self.target then return false end

    local own_pos = go.get_world_position()
    local target_pos = go.get_world_position(self.target)

    return vmath.length(target_pos - own_pos) <= self.max_distance
end

--- Update the target at runtime (e.g. when the enemy re-acquires a new one).
--- @param target userdata
function M:set_target(target)
    self.target = target
end

return M

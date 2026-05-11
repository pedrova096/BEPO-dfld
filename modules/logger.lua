local M = {}
M.__index = M

local function stringify_fields(fields)
	if not fields then return "" end

	local parts = {}
	for key, value in pairs(fields) do
		table.insert(parts, string.format("%s=%s", tostring(key), tostring(value)))
	end

	table.sort(parts)
	return table.concat(parts, " ")
end

local function emit(scope, message, fields)
	local suffix = stringify_fields(fields)
	if suffix ~= "" then
		print(string.format("[%s] %s %s", scope, message, suffix))
		return
	end

	print(string.format("[%s] %s", scope, message))
end

function M.new(enabled, scope)
	local instance = setmetatable({}, M)
	if type(enabled) == "string" then
		instance.enabled = scope or false
		instance.scope = enabled
		return instance
	end

	instance.enabled = enabled or false
	if type(scope) == "table" then
		instance.scope = scope.scope or "LOGGER"
	else
		instance.scope = scope or "LOGGER"
	end

	return instance
end

function M:log(message, fields)
	if not self.enabled then return end
	emit(self.scope, message, fields)
end

function M:debug(message, fields)
	self:log(message, fields)
end

function M.log_scoped(scope, message, fields)
	emit(scope, message, fields)
end

function M.debug_scoped(enabled, scope, message, fields)
	if not enabled then return end
	emit(scope, message, fields)
end

function M.new_debugger(enabled, scope)
	return M.new(enabled, scope)
end

return M

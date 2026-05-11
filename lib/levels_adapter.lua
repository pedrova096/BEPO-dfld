local LevelsIndex = require("lib.levels.index")

local M = {}

function M.get_level(level_id)
	local source_level = LevelsIndex[level_id]
	if not source_level then
		error(("Level not found for level_id %s"):format(tostring(level_id)))
	end

	local level = {
		id = level_id,
		start = source_level.start,
		stages = {},
	}

	for stage_id, stage_data in pairs(source_level.stages) do
		local connections
		if stage_data.connections then
			connections = {}
			for _, connection_stage_id in ipairs(stage_data.connections) do
				table.insert(connections, {
					next_stage = connection_stage_id,
					reward = source_level.stages[connection_stage_id].data.reward,
				})
			end
		end

		level.stages[stage_id] = {
			data = stage_data.data,
			connections = connections,
			reward = stage_data.data.reward,
		}
	end

	return level
end

return M

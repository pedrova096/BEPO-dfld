--- @class LevelConnectionPayload
--- @field id hash Target stage id.
--- @field difficulty number|nil Target stage difficulty.
--- @field reward hash|nil Target stage reward.

--- @class LevelStagePayload
--- @field id hash Stage id.
--- @field data table Stage config table consumed by the level runtime.
--- @field connections LevelConnectionPayload[]|nil Available connection targets for this stage.
--- @field reward hash|nil Reward id available from this stage.

--- @class LevelStageMap
--- @field data StageConfig Stage config table consumed by the level runtime.
--- @field connections hash[]|nil Ordered next-stage ids available from this stage.
--- @field difficulty number|nil Optional difficulty metadata exposed in connection payloads.
--- @field reward hash|nil Optional reward id exposed in connection payloads.

--- @class LevelConfig
--- @field id hash Stable level id.
--- @field start hash Entry stage id for the level.
--- @field stages table<hash, LevelStageMap> Stage nodes keyed by stage id.

--- @class LevelConnectionAdapter
--- @field next_stage hash Target stage id loaded when this connection is selected.
--- @field reward hash Reward id offered by this connection.

--- @class LevelStageMapAdapter
--- @field data table Stage config table consumed by the level runtime.
--- @field connections LevelConnectionAdapter[]|nil Ordered next-stage ids available from this stage.
--- @field reward hash|nil Reward id available from this stage.

--- @class LevelAdapter
--- @field id hash Stable level id.
--- @field start hash Entry stage id for the level.
--- @field stages table<hash, LevelStageMapAdapter> Stage nodes keyed by stage id.

--- @class LevelState
--- @field level_id hash|nil Active level id.
--- @field stage_start_id hash|nil Entry stage id for the active level.
--- @field status "idle"|"loading_stage"|"waiting_stage_start"|"running_stage" Current run flow state.
--- @field current_stage_id hash|nil Currently loaded stage id.
--- @field current_stage LevelStagePayload|nil Currently loaded stage payload.
--- @field pending_stage_id hash|nil Stage id requested but not yet loaded.

--- @class LevelStageLoadOptions
--- @field transition boolean|nil Whether the stage should wait for an external transition before starting.
--- @field duration number|nil Optional transition duration metadata for the adapter.
--- @field stage LevelStagePayload|nil Explicit stage payload, usually provided by the adapter on stage load.

--- Level run-session state for one active level.
--- Owns level navigation, the active stage, the pending stage load, and run flow flags.
--- This does not execute waves. That belongs to the stage runtime.
--- @class Level
--- @field state LevelState Session state, including active level config and flow status.
--- @field stages table<hash, LevelStageMapAdapter>|nil Stage nodes keyed by stage id.
local M = {}
M.__index = M

local LevelStatus = {
	Idle = "idle",
	LoadingStage = "loading_stage",
	WaitingStageStart = "waiting_stage_start",
	RunningStage = "running_stage",
}

local function build_initial_state()
	return {
		level_id = nil,
		stage_start_id = nil,
		status = LevelStatus.Idle,
		current_stage_id = nil,
		current_stage = nil,
		pending_stage_id = nil,
	}
end

--- Create a new Level session instance.
--- @param level LevelAdapter|nil Initial level config.
--- @return Level
function M:new(level)
	local instance = setmetatable({}, self)
	instance.state = build_initial_state()
	instance.stages = nil

	if level then
		instance:set_level(level)
	end

	return instance
end

--- Set or replace the active level config.
--- Also resets any in-progress run state.
--- @param level LevelAdapter
function M:set_level(level)
	if not level then
		error("Level session requires a level")
	end

	self.state.level_id = level.id
	self.state.stage_start_id = level.start
	self.stages = level.stages
	self:reset_run_state()
end

--- Reset transient run state while keeping the active level config.
function M:reset_run_state()
	self.state.status = LevelStatus.Idle
	self.state.current_stage_id = nil
	self.state.current_stage = nil
	self.state.pending_stage_id = nil
end

--- Return the active level session once configured.
--- @return Level
function M:get_level()
	if not self.state.level_id or not self.state.stage_start_id or not self.stages then
		error("Level session has no active level")
	end
	return self
end

--- Return the active level id.
--- @return hash
function M:get_level_id()
	self:get_level()
	return self.state.level_id
end

--- Resolve one stage node by id.
--- @param stage_id hash
--- @return LevelStageMapAdapter
function M:get_stage(stage_id)
	self:get_level()
	local stage = self.stages and self.stages[stage_id]
	if not stage then
		error(("Stage %s not found in level %s"):format(tostring(stage_id), tostring(self.state.level_id)))
	end

	return stage
end

--- Return the configured entry stage id for the active level.
--- @return hash
function M:get_start_stage_id()
	self:get_level()
	if not self.state.stage_start_id then
		error(("Level %s has no start stage"):format(tostring(self.state.level_id), tostring(self.state.stage_start_id)))
	end

	return self.state.stage_start_id
end

--- Resolve the next stage id selected from the current stage's connection options.
--- @param current_stage_id hash
--- @param connection_id hash
--- @return hash|nil
function M:get_next_connection_stage_id(current_stage_id, connection_id)
	local current_stage = self:get_stage(current_stage_id)
	if not current_stage.connections then return nil end

	for _, connection in ipairs(current_stage.connections) do
		if connection.next_stage == connection_id then
			return connection.next_stage
		end
	end

	error(("Connection target %s is not available from stage %s"):format(tostring(connection_id),
		tostring(current_stage_id)))
end

--- Queue a stage as the next stage to load.
--- This does not mark the stage as current yet.
--- @param stage_id hash
--- @return LevelStagePayload
function M:request_stage_load(stage_id)
	local stage = self:get_stage(stage_id)
	local stage_payload = {
		id = stage_id,
		data = stage.data,
		connections = stage.connections,
		reward = stage.reward,
	}

	self.state.pending_stage_id = stage_id
	self.state.status = LevelStatus.LoadingStage

	return stage_payload
end

--- Start a run from the configured level start stage.
--- @param options { level: LevelAdapter }
--- @return LevelStagePayload
function M:start_run(options)
	self:set_level(options.level)

	-- transition = false,
	return self:request_stage_load(self:get_start_stage_id())
end

--- Mark the pending stage as loaded and ready or waiting to start.
--- @param options LevelStageLoadOptions|nil
--- @return LevelStagePayload
function M:load_stage(options)
	options = options or {}
	local stage_payload = options.stage
	if not stage_payload then
		error("Cannot load stage without an explicit stage payload")
	end

	self.state.current_stage_id = stage_payload.id
	self.state.current_stage = stage_payload
	self.state.pending_stage_id = nil
	self.state.status = LevelStatus.WaitingStageStart

	return stage_payload
end

--- Mark the current loaded stage as started.
--- @return LevelStagePayload
function M:start_stage()
	if not self.state.current_stage then
		error("Cannot start stage without a loaded stage")
	end

	self.state.status = LevelStatus.RunningStage
	return self.state.current_stage
end

--- Select one of the current stage connection targets and queue it for loading.
--- @param connection_id hash
--- @param options LevelStageLoadOptions|nil
--- @return LevelStagePayload|nil
function M:choose_connection(connection_id, options)
	if self:is_loading_stage() then return nil end
	if not self.state.current_stage_id then return nil end

	local next_stage_id = self:get_next_connection_stage_id(self.state.current_stage_id, connection_id)
	if not next_stage_id then return nil end

	return self:request_stage_load(next_stage_id)
end

--- Return the current stage payload.
--- @return LevelStagePayload|nil
function M:get_current_stage()
	return self.state.current_stage
end

--- Return the current stage id.
--- @return hash|nil
function M:get_current_stage_id()
	return self.state.current_stage_id
end

--- Return the current stage reward id.
--- @return hash|nil
function M:get_current_reward()
	local current_stage = self.state.current_stage
	if not current_stage then return nil end

	return current_stage.reward
end

--- @return boolean
function M:is_loading_stage()
	return self.state.status == LevelStatus.LoadingStage
end

--- @return boolean
function M:is_stage_waiting_to_start()
	return self.state.status == LevelStatus.WaitingStageStart
end

M.Status = LevelStatus

return M

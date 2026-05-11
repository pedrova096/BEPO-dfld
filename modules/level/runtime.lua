local Events = require("modules.level.events")
local Stage = require("modules.level.stage.stage")
local WaveBuilder = require("modules.level.wave.wave_builder")

--- @class LevelRuntimeLoadOptions
--- @field stage LevelStagePayload

--- @class LevelRuntime
--- @field stage Stage
--- @field events { name: string, payload: table }[]
--- @field debug boolean
--- @field current_stage_id hash|nil
--- @field current_stage LevelStagePayload|nil
local M = {}
M.__index = M

local function push_event(self, name, payload)
	table.insert(self.events, {
		name = name,
		payload = payload or {},
	})
end

--- Create a stage runtime for the active stage combat flow.
--- This owns wave execution and emits runtime intents, but it does not know about level progression.
--- @param options { max_overlap: number?, debug: boolean? }|nil
--- @return LevelRuntime
function M:new(options)
	options = options or {}
	local instance = setmetatable({}, self)

	instance.events = {}
	instance.debug = options.debug or false
	instance.current_stage_id = nil
	instance.current_stage = nil

	instance.stage = Stage:new({
		max_overlap = options.max_overlap or 2,
		debug = instance.debug,
		on_spawn = function(spawn_options)
			push_event(instance, Events.SPAWN_ENEMY_REQUESTED, spawn_options)
		end,
		on_wave_start = function(index, wave)
			push_event(instance, Events.WAVE_STARTED, {
				index = index,
				wave_id = wave.id,
			})
		end,
		on_stage_complete = function()
			push_event(instance, Events.STAGE_COMPLETED, {
				stage_id = instance.current_stage_id,
			})
		end,
	})

	return instance
end

--- Drain and clear queued runtime events.
--- @return { name: string, payload: table }[]
function M:drain_events()
	local events = self.events
	self.events = {}
	return events
end

--- Prepare runtime state for a newly loaded stage.
--- @param options LevelRuntimeLoadOptions
--- @return LevelStagePayload
function M:load_stage(options)
	options = options or {}
	local stage_payload = options.stage
	if not stage_payload then
		error("Cannot load runtime stage without a stage payload")
	end

	self.current_stage_id = stage_payload.id
	self.current_stage = stage_payload
	self.stage:set_waves(WaveBuilder.from_config(stage_payload.data and stage_payload.data.waves or {}, {
		debug = self.debug,
	}))

	return stage_payload
end

--- Start the active stage runtime.
--- @return LevelStagePayload
function M:start_stage()
	if not self.current_stage then
		error("Cannot start runtime without a loaded stage")
	end

	self.stage:start()
	push_event(self, Events.STAGE_STARTED, {
		stage_id = self.current_stage_id,
		stage = self.current_stage,
	})

	return self.current_stage
end

--- Advance the active stage runtime.
--- @param dt number
function M:update(dt)
	self.stage:update(dt)
end

--- Route a kill into the active stage runtime.
--- @param options { enemy_id: hash|string|nil, wave_id: number|nil, position: vector3|table|nil }|nil
function M:enemy_killed(options)
	options = options or {}
	self.stage:on_enemy_killed(options.wave_id)
	push_event(self, Events.ENEMY_RELEASE_REQUESTED, {
		enemy_id = options.enemy_id,
		wave_id = options.wave_id,
		position = options.position,
	})
end

--- Confirm that an enemy has fully despawned from the engine side.
--- @param options { enemy_id: hash|string|nil }|nil
function M:enemy_despawned(options)
	options = options or {}
	push_event(self, Events.ENEMY_RELEASE_CONFIRMED, {
		enemy_id = options.enemy_id,
	})
end

--- @return LevelStagePayload|nil
function M:get_current_stage()
	return self.current_stage
end

--- @return hash|nil
function M:get_current_stage_id()
	return self.current_stage_id
end

--- @return boolean
function M:is_running()
	return self.stage:is_running()
end

M.Events = Events

return M

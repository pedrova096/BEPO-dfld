local Logger = require("modules.logger")

--- @class EnemyDef
--- @field id string unique identifier for this enemy type (e.g. "slime", "warrior")
--- @field cost number budget cost to spawn this enemy
--- @field chance number relative spawn weight (does not need to sum to 1)

--- @class SpawnOptions
--- @field wave_id number unique identifier of the wave
--- @field enemy EnemyDef enemy data to spawn

--- @class StageConfig
--- @field waves WaveConfig[] Ordered wave configs played by this stage.
--- @field difficulty number Stage difficulty rating.
--- @field reward hash Reward id available after completing this stage.
--- @field tilemap_id hash Tilemap id used to build this stage.

--- Stage orchestrator. Manages an ordered sequence of waves with overlap support.
--- Waves advance when the front wave's overlap_time triggers or when a wave completes.
--- Up to max_overlap waves can run concurrently.
--- @class Stage
--- @field waves Wave[] ordered array of wave instances
--- @field max_overlap number max concurrent active waves (default 3)
--- @field on_spawn fun(spawn_options: SpawnOptions)? called each time an enemy should be spawned; the caller handles factory creation
--- @field on_wave_start fun(index: number, wave: Wave)|nil called when a wave starts
--- @field on_stage_complete fun()|nil called when all waves are done
--- @field active_waves {index: number, wave: Wave, overlap_triggered: boolean}[]
--- @field next_index number index of the next wave to activate
--- @field running boolean whether the stage is currently in progress
--- @field completed boolean whether the stage is finished
--- @field debug boolean whether debug logging is enabled
local M = {}
M.__index = M

local logger = Logger.new_debugger()

--- Create a new Stage instance.
--- @param options {waves: Wave[]?, max_overlap: number?, on_spawn: fun(spawn_options: SpawnOptions), on_wave_start: fun(index: number, wave: Wave), on_stage_complete: fun(), debug: boolean?}
--- @return Stage
function M:new(options)
	local instance = setmetatable({}, self)

	instance.waves = options.waves or {}
	instance.max_overlap = options.max_overlap or 3
	instance.on_spawn = options.on_spawn
	instance.on_wave_start = options.on_wave_start
	instance.on_stage_complete = options.on_stage_complete
	instance.debug = options.debug or false
	logger = Logger.new_debugger(instance.debug, "LEVEL.STAGE")

	instance.active_waves = {}
	instance.next_index = 1
	instance.running = false
	instance.completed = false

	return instance
end

--- Replace the stage wave list.
--- Useful when reloading or swapping stage definitions at runtime.
--- @param waves Wave[]
function M:set_waves(waves)
	self.waves = waves
	self.active_waves = {}
	self.next_index = 1
	self.running = false
	self.completed = false

	logger:log("waves_set", { count = #self.waves, })
end

--- Start the stage by activating the first wave.
function M:start()
	if self.running or self.completed then return end
	if #self.waves == 0 then return end

	self.running = true
	logger:log("started", {
		waves = #self.waves,
		max_overlap = self.max_overlap,
	})
	self:activate_next_wave()
end

--- Activate the next wave in the sequence if slots are available.
--- Exclusive waves wait until all active waves have completed.
function M:activate_next_wave()
	if self.next_index > #self.waves then return end
	if #self.active_waves >= self.max_overlap then return end

	local wave = self.waves[self.next_index]
	if wave.exclusive and #self.active_waves > 0 then return end
	local entry = {
		index = self.next_index,
		wave = wave,
		overlap_triggered = false,
	}

	table.insert(self.active_waves, entry)
	wave.on_spawn = self.on_spawn
	wave:start()

	logger:log("wave_activated", {
		index = entry.index,
		wave_id = wave.id,
		active = #self.active_waves,
	})

	if self.on_wave_start then
		self.on_wave_start(self.next_index, wave)
	end

	self.next_index = self.next_index + 1
end

--- Update all active waves, handle overlap triggers, and remove completed waves.
--- @param dt number delta time in seconds
function M:update(dt)
	if not self.running or self.completed then return end

	for _, entry in ipairs(self.active_waves) do
		entry.wave:update(dt)
	end

	-- check overlap trigger on front (oldest) wave
	local front = self.active_waves[1]
	if front
			and front.wave.overlap_time
			and front.wave.elapsed >= front.wave.overlap_time
			and not front.overlap_triggered
	then
		front.overlap_triggered = true
		logger:log("wave_overlap_triggered", { index = front.index, wave_id = front.wave.id })
		self:activate_next_wave()
	end

	-- remove completed waves (backwards to avoid index shifting)
	for i = #self.active_waves, 1, -1 do
		local entry = self.active_waves[i]
		if entry.wave.completed then
			table.remove(self.active_waves, i)
			logger:log("wave_completed", {
				index = entry.index,
				wave_id = entry.wave.id,
				active = #self.active_waves,
			})
			if not entry.overlap_triggered then
				self:activate_next_wave()
			end
		end
	end

	-- stage complete when no active waves and all waves consumed
	if #self.active_waves == 0 and self.next_index > #self.waves then
		self.running = false
		self.completed = true
		logger:log("completed", { waves = #self.waves })
		if self.on_stage_complete then
			self.on_stage_complete()
		end
	end
end

--- Route an enemy kill to the correct active wave.
--- @param wave_id number the wave id that owns the killed enemy
function M:on_enemy_killed(wave_id)
	for _, entry in ipairs(self.active_waves) do
		local wave = entry.wave
		if wave.id == wave_id then
			logger:log("enemy_killed_routed", { wave_id = wave_id })
			wave:on_enemy_killed()
			return
		end
	end

	logger:log("enemy_killed_unmatched", { wave_id = wave_id, })
end

--- @return boolean
function M:is_complete()
	return self.completed
end

--- @return boolean
function M:is_running()
	return self.running
end

return M

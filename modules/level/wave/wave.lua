local Logger = require("modules.logger")

--- @class WaveOptions
--- @field id? number unique identifier for this wave (default 0)
--- @field spawn_interval number? seconds between spawn ticks (default 2)
--- @field spawn_concurrent number? enemies spawned per tick (default 1)
--- @field enemy_pool EnemyDef[]? weighted enemy definitions
--- @field overlap_time number? seconds after start before the next wave can begin alongside this one
--- @field exclusive boolean? when true, this wave only starts once all previous waves are fully done (default false)
--- @field on_spawn fun(spawn_options: SpawnOptions)? called each time an enemy should be spawned; the caller handles factory creation
--- @field debug boolean? enable debug logging for this wave

--- Abstract base wave class for enemy spawning.
--- Handles spawn timing, weighted enemy selection, and alive tracking.
--- Subclasses must implement `can_spawn()` and `is_complete()`.
--- @class Wave
--- @field id number unique identifier for this wave
--- @field spawn_interval number seconds between spawn ticks
--- @field spawn_concurrent number enemies spawned per tick
--- @field enemy_pool EnemyDef[] weighted enemy definitions
--- @field overlap_time number|nil seconds before next wave can start alongside
--- @field exclusive boolean when true, wave only starts once all previous waves are fully done
--- @field on_spawn fun(spawn_options: SpawnOptions)|nil called when an enemy should be spawned
--- @field alive_count number currently alive enemies from this wave
--- @field elapsed number seconds since wave started
--- @field spawn_timer number accumulator for spawn interval
--- @field total_spawned number total enemies spawned by this wave
--- @field started boolean whether the wave has been started
--- @field completed boolean whether the wave has finished
--- @field debug boolean whether debug logging is enabled
local M = {}
M.__index = M

local logger = Logger.new_debugger()

--- Create a new Wave instance.
--- @param options WaveOptions
--- @return Wave
function M:new(options)
	local instance = setmetatable({}, self)

	instance.id = options.id or 0
	instance.spawn_interval = options.spawn_interval or 2
	instance.spawn_concurrent = options.spawn_concurrent or 1
	instance.enemy_pool = options.enemy_pool or {}
	instance.overlap_time = options.overlap_time or nil
	instance.exclusive = options.exclusive or false
	instance.on_spawn = options.on_spawn
	instance.debug = options.debug or false

	logger = Logger.new_debugger(instance.debug, string.format("LEVEL.WAVE:%s", tostring(instance.id)))

	instance.alive_count = 0
	instance.elapsed = 0
	instance.spawn_timer = 0
	instance.total_spawned = 0
	instance.started = false
	instance.completed = false

	return instance
end

--- Start the wave, resetting timers.
function M:start()
	self.started = true
	self.elapsed = 0
	self.spawn_timer = self.spawn_interval

	logger:debug("started", {
		interval = string.format("%.2f", self.spawn_interval),
		concurrent = self.spawn_concurrent,
		overlap = self.overlap_time,
		exclusive = self.exclusive,
	})
end

--- Handle spawning logic for the wave. Called by update() when it's time to spawn.
function M:spawn_cycle()
	if self.spawn_timer >= self.spawn_interval and self:can_spawn() then
		logger:debug("spawn_cycle", {
			timer = string.format("%.2f", self.spawn_timer),
			alive = self.alive_count,
			total_spawned = self.total_spawned,
		})

		self.spawn_timer = 0

		local concurrent = self.spawn_concurrent + math.random(-1, 1)

		for _ = 1, concurrent do
			local enemy_def = self:pick_enemy()
			if enemy_def and self:validate_spawn(enemy_def) then
				self:commit_spawn(enemy_def)
			elseif enemy_def then
				logger:debug("spawn_skipped", { enemy = enemy_def.id, reason = "validate_spawn_failed" })
			else
				logger:debug("spawn_skipped", { reason = "no_enemy_selected" })
			end
		end
	end
end

--- Update the wave each frame. Advances timers, spawns enemies, checks completion.
--- @param dt number delta time in seconds
function M:update(dt)
	if not self.started or self.completed then return end

	self.elapsed = self.elapsed + dt
	self.spawn_timer = self.spawn_timer + dt

	self:spawn_cycle()
	if self:is_complete() then
		self.completed = true
		logger:debug("completed", {
			elapsed = string.format("%.2f", self.elapsed),
			total_spawned = self.total_spawned,
			alive = self.alive_count,
		})
	end
end

--- Select a random enemy from the pool using weighted probability.
--- @return EnemyDef|nil
function M:pick_enemy()
	local total = 0
	for _, def in ipairs(self.enemy_pool) do
		total = total + def.chance
	end

	local roll = math.random() * total
	local cumulative = 0

	for _, def in ipairs(self.enemy_pool) do
		cumulative = cumulative + def.chance
		if roll <= cumulative then
			return def
		end
	end

	return self.enemy_pool[1]
end

--- Validate whether an enemy can be spawned. Base always returns true.
--- Override in subclasses (e.g. BudgetWave checks remaining budget).
--- @param _enemy_def EnemyDef the enemy definition from the pool
--- @return boolean
---@diagnostic disable-next-line: unused-local
function M:validate_spawn(_enemy_def)
	return true
end

--- Commit a spawn: increments counters and fires on_spawn.
--- @param enemy_def EnemyDef the enemy definition from the pool
function M:commit_spawn(enemy_def)
	self.total_spawned = self.total_spawned + 1
	self.alive_count = self.alive_count + 1

	logger:debug("spawn_committed", {
		enemy = enemy_def.id,
		alive = self.alive_count,
		total_spawned = self.total_spawned,
	})

	if self.on_spawn then
		self.on_spawn({
			wave_id = self.id,
			enemy = enemy_def,
		})
	end
end

--- Notify the wave that one of its enemies was killed.
function M:on_enemy_killed()
	self.alive_count = math.max(0, self.alive_count - 1)
	logger:debug("enemy_killed", { alive = self.alive_count })

	if self.alive_count == 0 then
		local old_spawn_timer = self.spawn_timer
		self.spawn_timer = math.max(self.spawn_interval * 3 / 4, self.spawn_timer)
		logger:debug("spawn_timer_boosted", {
			timer = string.format("%.2f", self.spawn_timer),
			before = string.format("%.2f", old_spawn_timer),
			reason = "no_alive_enemies",
		})
	end
end

--- Return whether the wave can still spawn enemies. Abstract — subclass must implement.
--- @return boolean
--- @abstract
function M:can_spawn()
	error("can_spawn() is abstract - must be implemented by subclass")
end

--- Return whether the wave is complete. Abstract — subclass must implement.
--- @return boolean
--- @abstract
function M:is_complete()
	error("is_complete() is abstract - must be implemented by subclass")
end

--- Return the progress of the wave as a number between 0 and 1.
--- @return number
function M:get_progress()
	error("get_progress() is abstract - must be implemented by subclass")
end

return M

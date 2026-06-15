local ManualTweener = require("utils.manual_tweener")

---@alias ProgressGUIColor vector4|number[]

---@class ProgressGUIOptions
---@field progress_id string GUI node id using the progress_gui material.
---@field bar_id string|nil Optional parent/container node toggled with the progress node.
---@field length number|nil Maximum value and number of visual segments. Defaults to 1.
---@field value number|nil Initial value. Defaults to length.
---@field animation_time number|nil Fill tween duration in seconds. Defaults to 0.25.
---@field trail_delay number|nil Delay before the background/trail fill follows in seconds. Defaults to 0.15.
---@field color_bar ProgressGUIColor|nil Foreground fill color.
---@field color_bg ProgressGUIColor|nil Background/trail fill color.
---@field color_division ProgressGUIColor|nil Segment divider color.
---@field show boolean|nil Whether the nodes start visible. Defaults to true.

---@class ProgressGUISetValueOptions
---@field instant boolean|nil Apply immediately without tweening.
---@field duration number|nil Override fill tween duration in seconds.
---@field trail_delay number|nil Override background/trail delay in seconds.

---@class ProgressGUISetColorOptions
---@field color_bar ProgressGUIColor|nil Foreground fill color.
---@field color_bg ProgressGUIColor|nil Background/trail fill color.
---@field color_division ProgressGUIColor|nil Segment divider color.

---@class ProgressGUI
---@field bar_node node|nil
---@field progress_node node
---@field length number
---@field value number
---@field animation_time number
---@field trail_delay number
---@field bar_animation ManualTweener
---@field bg_animation ManualTweener
local M = {}
M.__index = M

local DEFAULT_ANIMATION_TIME = 0.25
local DEFAULT_TRAIL_DELAY = 0.15

---@param color ProgressGUIColor|nil
---@return vector4
local function to_vector4(color)
	if not color then
		return vmath.vector4(1, 1, 1, 1)
	end

	if color.x then
		return color
	end

	return vmath.vector4(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
end

---@param value number
---@param min number
---@param max number
---@return number
local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

---@param value number
---@param length number
---@return number
local function get_progress(value, length)
	if length <= 0 then
		return 0
	end

	return clamp(value / length, 0, 1)
end

---Create a GUI progress controller backed by the progress_gui material.
---@param options ProgressGUIOptions
---@return ProgressGUI
function M:new(options)
	local instance = setmetatable({}, self)

	instance.bar_node = options.bar_id and gui.get_node(options.bar_id) or nil
	instance.progress_node = gui.get_node(options.progress_id)
	instance.length = options.length ~= nil and options.length or 1
	instance.value = options.value ~= nil and options.value or instance.length
	instance.animation_time = options.animation_time ~= nil and options.animation_time or DEFAULT_ANIMATION_TIME
	instance.trail_delay = options.trail_delay ~= nil and options.trail_delay or DEFAULT_TRAIL_DELAY

	instance.bar_animation = ManualTweener:new({
		easing = ManualTweener.EASING_OUTEXPO,
		from = 1,
		to = 1
	})
	instance.bg_animation = ManualTweener:new({
		easing = ManualTweener.EASING_OUTEXPO,
		from = 1,
		to = 1
	})

	gui.set(instance.progress_node, "color_bar", to_vector4(options.color_bar))
	gui.set(instance.progress_node, "color_bg", to_vector4(options.color_bg))
	if options.color_division then
		gui.set(instance.progress_node, "color_division", to_vector4(options.color_division))
	end
	instance:set_visible(options.show ~= false)
	instance:set_value(instance.value, { instant = true })
	instance:_set_division()

	return instance
end

---Update material uniforms that define segment spacing and divider width.
function M:_set_division()
	local interval = self.length > 0 and 1 / self.length or 0
	local size = gui.get_size(self.progress_node)
	local width = size.x > 0 and 1 / size.x or 0

	gui.set(self.progress_node, "params.w", interval)
	gui.set(self.progress_node, "params.z", width)
end

---@param visible boolean
function M:set_visible(visible)
	if self.bar_node then
		gui.set_visible(self.bar_node, visible)
	end
	gui.set_visible(self.progress_node, visible)
end

---Show the progress nodes.
function M:show()
	self:set_visible(true)
end

---Hide the progress nodes.
function M:hide()
	self:set_visible(false)
end

---@param length number|nil New maximum value and segment count.
function M:set_length(length)
	if length == nil or length == self.length then return end

	self.length = length
	self:_set_division()
	self:set_value(self.value, { instant = true })
end

---@param options ProgressGUISetColorOptions
function M:set_colors(options)
	if options.color_bar then
		gui.set(self.progress_node, "color_bar", to_vector4(options.color_bar))
	end

	if options.color_bg then
		gui.set(self.progress_node, "color_bg", to_vector4(options.color_bg))
	end

	if options.color_division then
		gui.set(self.progress_node, "color_division", to_vector4(options.color_division))
	end
end

---@param value number|nil New value clamped between 0 and length.
---@param options ProgressGUISetValueOptions|nil
function M:set_value(value, options)
	options = options or {}

	self.value = clamp(value or 0, 0, self.length)
	local progress = get_progress(self.value, self.length)

	self.bar_animation:pause()
	self.bg_animation:pause()

	if options.instant then
		gui.set(self.progress_node, "params.x", progress)
		gui.set(self.progress_node, "params.y", progress)
		self.bar_animation:reset()
		self.bg_animation:reset()
		return
	end

	local duration = options.duration ~= nil and options.duration or self.animation_time
	local delay = options.trail_delay ~= nil and options.trail_delay or self.trail_delay

	self.bar_animation:restart({
		from = self.bar_animation:get(),
		to = progress,
		duration = duration,
	})

	self.bg_animation:restart({
		from = self.bar_animation:get(),
		to = progress,
		duration = duration,
		delay = delay
	})
end

---Apply current tweened progress values to the material uniforms.
function M:_apply_params()
	local bar_progress = self.bar_animation:get()
	local bg_progress = self.bg_animation:get()
	gui.set(self.progress_node, "params.x", bar_progress);
	gui.set(self.progress_node, "params.y", bg_progress);
end

---@param dt number Delta time in seconds.
function M:update(dt)
	self.bar_animation:tick(dt)
	self.bg_animation:tick(dt)
	self:_apply_params()
end

---@return number value Current clamped value.
function M:get_value()
	return self.value
end

---@return number progress Current value normalized from 0 to 1.
function M:get_progress()
	return get_progress(self.value, self.length)
end

return M

local M = {}
M.__index = M

local DEFAULT_DURATION = 3
local FADE_DURATION = 0.35
local DEFAULT_CAPACITY = 3
local DEFAULT_SPACING = 24

local function get_cloned_node(nodes, node_id)
	local short_id = node_id:match("([^/]+)$")
	return nodes[node_id] or nodes[hash(node_id)] or nodes[short_id] or nodes[hash(short_id)]
end

local function set_alpha(node, alpha)
	gui.cancel_animations(node, "color.w")
	gui.set(node, "color.w", alpha)
end

local function create_slot(frame_node, text_node, icon_node)
	return {
		frame_node = frame_node,
		text_node = text_node,
		icon_node = icon_node,
		base_position = gui.get_position(frame_node),
		current_id = nil,
		hide_timer = nil,
		active = false,
		generation = 0,
	}
end

function M:new(options)
	local instance = setmetatable({}, self)

	instance.capacity = math.max(1, math.floor(options.n or options.capacity or options.max_items or DEFAULT_CAPACITY))
	instance.spacing = options.spacing or DEFAULT_SPACING
	instance.slots = {}
	instance.active_slots = {}
	instance.next_id = 0

	local frame_node = gui.get_node(options.frame_node_id)
	local text_node = gui.get_node(options.text_node_id)
	local icon_node = options.icon_node_id and gui.get_node(options.icon_node_id) or nil
	instance.slots[1] = create_slot(frame_node, text_node, icon_node)

	for i = 2, instance.capacity do
		local nodes = gui.clone_tree(frame_node)
		instance.slots[i] = create_slot(
			get_cloned_node(nodes, options.frame_node_id),
			get_cloned_node(nodes, options.text_node_id),
			options.icon_node_id and get_cloned_node(nodes, options.icon_node_id) or nil
		)
	end

	for _, slot in ipairs(instance.slots) do
		gui.set_enabled(slot.frame_node, false)
		set_alpha(slot.frame_node, 0)
		set_alpha(slot.text_node, 0)
		if slot.icon_node then
			gui.set_enabled(slot.icon_node, false)
			set_alpha(slot.icon_node, 0)
		end
	end

	return instance
end

function M:_cancel_hide_timer(slot)
	if not slot.hide_timer then return end

	timer.cancel(slot.hide_timer)
	slot.hide_timer = nil
end

function M:_next_toast_id()
	self.next_id = self.next_id + 1
	return self.next_id
end

function M:_remove_active_slot(slot)
	for i, active_slot in ipairs(self.active_slots) do
		if active_slot == slot then
			table.remove(self.active_slots, i)
			return
		end
	end
end

function M:_find_active_slot(toast_id)
	for _, slot in ipairs(self.active_slots) do
		if slot.current_id == toast_id then
			return slot
		end
	end
	return nil
end

function M:_get_available_slot()
	for _, slot in ipairs(self.slots) do
		if not slot.active then
			return slot
		end
	end
	return nil
end

function M:_relayout()
	for i, slot in ipairs(self.active_slots) do
		local position = slot.base_position + vmath.vector3(0, -(i - 1) * self.spacing, 0)
		gui.cancel_animations(slot.frame_node, "position")
		gui.animate(slot.frame_node, "position", position, gui.EASING_OUTEXPO, FADE_DURATION)
	end
end

function M:_hide_slot(slot, relayout)
	self:_cancel_hide_timer(slot)
	self:_remove_active_slot(slot)

	slot.active = false
	slot.current_id = nil
	slot.generation = slot.generation + 1
	local generation = slot.generation

	if slot.icon_node then
		gui.cancel_animations(slot.icon_node, "color.w")
		gui.animate(slot.icon_node, "color.w", 0, gui.EASING_OUTEXPO, FADE_DURATION)
	end

	gui.cancel_animations(slot.text_node, "color.w")
	gui.animate(slot.text_node, "color.w", 0, gui.EASING_OUTEXPO, FADE_DURATION)

	gui.cancel_animations(slot.frame_node, "color.w")
	gui.animate(slot.frame_node, "color.w", 0, gui.EASING_OUTEXPO, FADE_DURATION, 0, function()
		if slot.generation ~= generation then return end

		gui.set_enabled(slot.frame_node, false)
		if slot.icon_node then
			gui.set_enabled(slot.icon_node, false)
		end
	end)

	if relayout ~= false then
		self:_relayout()
	end
end

function M:hide(toast_id)
	if toast_id then
		local slot = self:_find_active_slot(toast_id)
		if slot then
			self:_hide_slot(slot)
		end
		return
	end

	for i = #self.active_slots, 1, -1 do
		self:_hide_slot(self.active_slots[i], false)
	end
	self:_relayout()
end

function M:show(options)
	options = options or {}
	local toast_id = options.id or self:_next_toast_id()
	local slot = self:_find_active_slot(toast_id)

	if slot then
		self:_remove_active_slot(slot)
	elseif #self.active_slots >= self.capacity then
		slot = self.active_slots[#self.active_slots]
		self:_remove_active_slot(slot)
	else
		slot = self:_get_available_slot()
	end

	if not slot then return end

	self:_cancel_hide_timer(slot)

	slot.active = true
	slot.current_id = toast_id
	slot.generation = slot.generation + 1
	table.insert(self.active_slots, 1, slot)

	gui.set_text(slot.text_node, options.text or "")
	if slot.icon_node then
		if options.icon then
			gui.set_enabled(slot.icon_node, true)
			gui.play_flipbook(slot.icon_node, options.icon)

			gui.cancel_animations(slot.icon_node, "color.w")
			gui.set(slot.icon_node, "color.w", 0)
			gui.animate(slot.icon_node, "color.w", 1, gui.EASING_OUTEXPO, FADE_DURATION)
		else
			gui.set_enabled(slot.icon_node, false)
			set_alpha(slot.icon_node, 0)
		end
	end

	gui.set_enabled(slot.frame_node, true)

	gui.cancel_animations(slot.frame_node, "color.w")
	gui.set(slot.frame_node, "color.w", 0)
	gui.animate(slot.frame_node, "color.w", 1, gui.EASING_OUTEXPO, FADE_DURATION)

	gui.cancel_animations(slot.text_node, "color.w")
	gui.set(slot.text_node, "color.w", 0)
	gui.animate(slot.text_node, "color.w", 1, gui.EASING_OUTEXPO, FADE_DURATION)

	self:_relayout()

	local duration = options.duration or DEFAULT_DURATION
	if duration > 0 then
		slot.hide_timer = timer.delay(duration, false, function()
			self:hide(toast_id)
		end)
	end
end

return M

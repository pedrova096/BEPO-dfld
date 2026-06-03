---@class BottomNavGUIItemOptions
---@field id string Template instance id, such as "play_nav_item".
---@field label string|nil Text shown under the icon.
---@field icon string|nil Atlas animation used when the item is not selected.
---@field selected_icon string|nil Atlas animation used when the item is selected.
---@field on_select fun(item: BottomNavGUIItem)|nil Called after the item is selected by input or select().

---@class BottomNavGUIOptions
---@field selected_bg_node_id string Node id for the selected background indicator.
---@field items BottomNavGUIItemOptions[] Nav items to bind.
---@field selected_id string|nil Initially selected item id.
---@field selected_scale vector3|nil Icon scale for the selected item.
---@field unselected_scale vector3|nil Icon scale for unselected items.
---@field selected_y number|nil Root item y position when selected.
---@field unselected_y number|nil Root item y position when unselected.
---@field animation_time number|nil Duration for selection transitions.
---@field easing number|nil Defold GUI easing constant used by transitions.

---@class BottomNavGUIItem
---@field id string
---@field label string
---@field icon string|nil
---@field selected_icon string|nil
---@field on_select fun(item: BottomNavGUIItem)|nil
---@field root_node node
---@field icon_node node
---@field text_node node
---@field position vector3

---@class BottomNavGUI
---@field selected_id string|nil
---@field pressed_item BottomNavGUIItem|nil
---@field items BottomNavGUIItem[]
---@field items_by_id table<string, BottomNavGUIItem>
local M = {}
M.__index = M

local DEFAULT_SELECTED_SCALE = vmath.vector3(1.25, 1.25, 1)
local DEFAULT_UNSELECTED_SCALE = vmath.vector3(1, 1, 1)
local DEFAULT_SELECTED_Y = 4
local DEFAULT_UNSELECTED_Y = 0
local DEFAULT_ANIMATION_TIME = 0.18
local DEFAULT_EASING = gui.EASING_OUTEXPO

local function get_template_node(instance_id, node_id)
	return gui.get_node(instance_id .. "/" .. node_id)
end

---@param action table
---@return number|nil x
---@return number|nil y
local function get_action_position(action)
	if action.touch and action.touch[1] then
		return action.touch[1].x, action.touch[1].y
	end

	return action.x, action.y
end

---@param options BottomNavGUIItemOptions
---@return BottomNavGUIItem
local function create_item(options)
	local item = {
		id = options.id,
		label = options.label or "",
		icon = options.icon,
		selected_icon = options.selected_icon or options.icon,
		on_select = options.on_select,
		root_node = get_template_node(options.id, "item"),
		icon_node = get_template_node(options.id, "icon"),
		text_node = get_template_node(options.id, "text"),
	}

	item.position = gui.get_position(item.root_node)

	gui.set_text(item.text_node, item.label)
	if item.icon then
		gui.play_flipbook(item.icon_node, item.icon)
	end

	return item
end

---@param options BottomNavGUIOptions
---@return BottomNavGUI
function M:new(options)
	local instance = setmetatable({}, self)

	instance.selected_bg_node = gui.get_node(options.selected_bg_node_id)
	instance.selected_scale = options.selected_scale or DEFAULT_SELECTED_SCALE
	instance.unselected_scale = options.unselected_scale or DEFAULT_UNSELECTED_SCALE
	instance.selected_y = options.selected_y or DEFAULT_SELECTED_Y
	instance.unselected_y = options.unselected_y or DEFAULT_UNSELECTED_Y
	instance.animation_time = options.animation_time or DEFAULT_ANIMATION_TIME
	instance.easing = options.easing or DEFAULT_EASING
	instance.items = {}
	instance.items_by_id = {}
	instance.pressed_item = nil
	instance.selected_id = nil

	for _, item_options in ipairs(options.items or {}) do
		local item = create_item(item_options)
		table.insert(instance.items, item)
		instance.items_by_id[item.id] = item
	end

	instance:select(options.selected_id or (instance.items[1] and instance.items[1].id), { silent = true })

	return instance
end

---@param item BottomNavGUIItem
---@param selected boolean
---@param animated boolean
function M:_set_item_selected(item, selected, animated)
	local position = gui.get_position(item.root_node)
	position.y = selected and self.selected_y or self.unselected_y
	local scale = selected and self.selected_scale or self.unselected_scale

	gui.cancel_animations(item.root_node, "position.y")
	gui.cancel_animations(item.icon_node, "scale")
	if animated then
		gui.animate(item.root_node, "position.y", position.y, self.easing, self.animation_time)
		gui.animate(item.icon_node, "scale", scale, self.easing, self.animation_time)
	else
		gui.set_position(item.root_node, position)
		gui.set_scale(item.icon_node, scale)
	end

	if selected and item.selected_icon then
		gui.play_flipbook(item.icon_node, item.selected_icon)
	elseif item.icon then
		gui.play_flipbook(item.icon_node, item.icon)
	end
end

---@param item_id string
---@param options { silent: boolean }|nil
---@return boolean selected True when the item id exists and selection was applied.
function M:select(item_id, options)
	local item = self.items_by_id[item_id]
	if not item then
		return false
	end

	local animated = not (options and options.silent)
	self.selected_id = item_id
	for _, nav_item in ipairs(self.items) do
		self:_set_item_selected(nav_item, nav_item == item, animated)
	end

	local selected_bg_position = gui.get_position(self.selected_bg_node)
	selected_bg_position.x = item.position.x
	gui.cancel_animations(self.selected_bg_node, "position.x")
	if animated then
		gui.animate(self.selected_bg_node, "position.x", selected_bg_position.x, self.easing, self.animation_time)
	else
		gui.set_position(self.selected_bg_node, selected_bg_position)
	end

	if not (options and options.silent) and item.on_select then
		item.on_select(item)
	end

	return true
end

---@param action table Defold GUI input action.
---@return BottomNavGUIItem|nil
function M:_get_picked_item(action)
	local x, y = get_action_position(action)
	if not x or not y then
		return nil
	end

	for _, item in ipairs(self.items) do
		if gui.pick_node(item.root_node, x, y) then
			return item
		end
	end

	return nil
end

---@param action table Defold GUI input action.
---@return boolean consumed True when the bottom nav handled or captured the input.
function M:on_input(action)
	if action.pressed then
		self.pressed_item = self:_get_picked_item(action)
		return self.pressed_item ~= nil
	end

	if action.released and self.pressed_item then
		local item = self:_get_picked_item(action)
		local pressed_item = self.pressed_item
		self.pressed_item = nil

		if item and item.id == pressed_item.id then
			return self:select(item.id)
		end

		return true
	end

	return self.pressed_item ~= nil
end

return M

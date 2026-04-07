--
-- Generates a filled box (quad) into a mesh using PRIMITIVE_TRIANGLES.
--

---@class BufferMakerBox
---@field width number
---@field height number
---@field color vector4
---@field mesh_url string|userdata
---@field _mesh_buffer userdata
---@field _position_stream userdata
---@field _texcoord_stream userdata
---@field _tint_stream userdata
---@field _buffer_resource userdata|nil
local M = {}
M.__index = M

local unique_buffer_id = 0

local VERTEX_COUNT = 6

---@class BufferMakerBoxOptions
---@field mesh_url string|userdata URL to the mesh component
---@field width number? Width of the box in pixels (default 100)
---@field height number? Height of the box in pixels (default 100)
---@field color vector4? RGBA tint color (default white)

---Create and initialize a BufferMakerBox instance.
---@param opts BufferMakerBoxOptions
---@return BufferMakerBox
function M.new(opts)
	local instance = setmetatable({}, M)

	instance.mesh_url = opts.mesh_url
	instance.width = opts.width or 100
	instance.height = opts.height or 100
	instance.color = opts.color or vmath.vector4(1, 1, 1, 1)

	instance._mesh_buffer = buffer.create(VERTEX_COUNT, {
		{ name = hash("position"),  type = buffer.VALUE_TYPE_FLOAT32, count = 3 },
		{ name = hash("texcoord0"), type = buffer.VALUE_TYPE_FLOAT32, count = 2 },
		{ name = hash("tint"),      type = buffer.VALUE_TYPE_FLOAT32, count = 4 },
	})

	instance._position_stream = buffer.get_stream(instance._mesh_buffer, "position")
	instance._texcoord_stream = buffer.get_stream(instance._mesh_buffer, "texcoord0")
	instance._tint_stream = buffer.get_stream(instance._mesh_buffer, "tint")
	instance._buffer_resource = nil

	instance:build()
	return instance
end

--- Generate box vertices as two triangles (quad). Centered at origin.
--- UVs: (0,0) bottom-left, (1,1) top-right.
function M:build()
	local hw = self.width * 0.5
	local hh = self.height * 0.5
	local color = self.color

	-- Two triangles: (0,0)-(1,0)-(1,1) and (0,0)-(1,1)-(0,1) in UV
	-- Triangle 1: bottom-left, bottom-right, top-right
	-- Triangle 2: bottom-left, top-right, top-left
	local pos = {
		-hw, -hh, 0,  -- 1 bottom-left
		hw,  -hh, 0,  -- 2 bottom-right
		hw,  hh,  0,  -- 3 top-right
		-hw, -hh, 0,  -- 4 bottom-left
		hw,  hh,  0,  -- 5 top-right
		-hw, hh,  0,  -- 6 top-left
	}
	local uvs = {
		0, 0,
		1, 0,
		1, 1,
		0, 0,
		1, 1,
		0, 1,
	}
	local tints = {}
	for i = 1, VERTEX_COUNT do
		tints[i] = color
	end

	faststream.set_table_universal(self._position_stream, pos)
	faststream.set_table_universal(self._texcoord_stream, uvs)
	faststream.set_table_raw(self._tint_stream, tints)

	if not self._buffer_resource then
		unique_buffer_id = unique_buffer_id + 1
		local path = "/repulse_box/box_mesh_" .. unique_buffer_id .. ".bufferc"
		self._buffer_resource = resource.create_buffer(path, { buffer = self._mesh_buffer })
		go.set(self.mesh_url, "vertices", self._buffer_resource)
	end
end

--- Update the box size and rebuild geometry.
---@param width number Width in pixels
---@param height number? Height in pixels (uses width if nil)
function M:set_size(width, height)
	self.width = width
	self.height = height or width
	self:build()
end

--- Update the box color and rebuild geometry.
---@param color vector4 New RGBA color
function M:set_color(color)
	self.color = color
	self:build()
end

--- Release the buffer resource.
function M:final()
	if self._buffer_resource then
		resource.release(self._buffer_resource)
	end
end

return M

--
-- Generates a filled box (quad) into a mesh using PRIMITIVE_TRIANGLES.
--
-- Properties expected on `self`:
--
-- * width (number)  - Width of the box in pixels (default 100).
-- * height (number)  - Height of the box in pixels (default 100).
-- * color (vector4) - RGBA tint color (default white).
-- * mesh_url (hash) - URL to the mesh component.
--

local M = {}

local unique_buffer_id = 0

local VERTEX_COUNT = 6

--- Initialize buffers and build the box geometry.
---@param self table Script instance or property table
function M.init(self)
	self._mesh_buffer = buffer.create(VERTEX_COUNT, {
		{ name = hash("position"),  type = buffer.VALUE_TYPE_FLOAT32, count = 3 },
		{ name = hash("texcoord0"), type = buffer.VALUE_TYPE_FLOAT32, count = 2 },
		{ name = hash("tint"),      type = buffer.VALUE_TYPE_FLOAT32, count = 4 },
	})

	self._position_stream = buffer.get_stream(self._mesh_buffer, "position")
	self._texcoord_stream = buffer.get_stream(self._mesh_buffer, "texcoord0")
	self._tint_stream = buffer.get_stream(self._mesh_buffer, "tint")
	self._buffer_resource = nil

	M.build(self)
end

--- Generate box vertices as two triangles (quad). Centered at origin.
--- UVs: (0,0) bottom-left, (1,1) top-right.
---@param self table Script instance
function M.build(self)
	local width = self.width or 100
	local height = self.height or 100
	local color = self.color or vmath.vector4(1, 1, 1, 1)

	local hw = width * 0.5
	local hh = height * 0.5

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
---@param self table Script instance
---@param width number Width in pixels
---@param height number Height in pixels (optional, uses width if nil)
function M.set_size(self, width, height)
	self.width = width
	self.height = height or width
	M.build(self)
end

--- Update the box color and rebuild geometry.
---@param self table Script instance
---@param color vector4 New RGBA color
function M.set_color(self, color)
	self.color = color
	M.build(self)
end

--- Release the buffer resource.
---@param self table Script instance
function M.final(self)
	if self._buffer_resource then
		resource.release(self._buffer_resource)
	end
end

return M

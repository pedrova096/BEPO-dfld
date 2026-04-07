--
-- Generates a filled circle into a mesh using PRIMITIVE_TRIANGLES.
--
-- Properties expected on `self`:
--
-- * segments (number) - Number of segments around the circle (default 32).
-- * radius (number) - Radius of the circle in pixels (default 100).
-- * color (vector4) - RGBA tint color (default white).
-- * mesh_url (hash) - URL to the mesh component.
--

local M = {}

local unique_buffer_id = 0

--- Initialize buffers and build the circle geometry.
---@param self table Script instance or property table
function M.init(self)
	local segments = self.segments or 32
	local vertex_count = 3 * segments

	self._segments = segments
	self._mesh_buffer = buffer.create(vertex_count, {
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

--- Generate circle vertices as independent triangles (center, rim[i], rim[i+1])
--- and push them into the mesh buffer streams.
---@param self table Script instance
function M.build(self)
	local segments = self._segments
	local radius = self.radius or 100
	local color = self.color or vmath.vector4(1, 1, 1, 1)
	local step = (2 * math.pi) / segments

	local pos = {}
	local uvs = {}
	local tints = {}
	local pk = 1
	local uk = 1
	local tk = 1

	for i = 0, segments - 1 do
		local a1 = i * step
		local a2 = (i + 1) * step
		local cos1, sin1 = math.cos(a1), math.sin(a1)
		local cos2, sin2 = math.cos(a2), math.sin(a2)

		-- center
		pos[pk] = 0; pos[pk + 1] = 0; pos[pk + 2] = 0
		uvs[uk] = 0.5; uvs[uk + 1] = 0.5
		tints[tk] = color
		pk = pk + 3; uk = uk + 2; tk = tk + 1

		-- rim point i
		pos[pk] = cos1 * radius; pos[pk + 1] = sin1 * radius; pos[pk + 2] = 0
		uvs[uk] = (cos1 + 1) * 0.5; uvs[uk + 1] = (sin1 + 1) * 0.5
		tints[tk] = color
		pk = pk + 3; uk = uk + 2; tk = tk + 1

		-- rim point i+1
		pos[pk] = cos2 * radius; pos[pk + 1] = sin2 * radius; pos[pk + 2] = 0
		uvs[uk] = (cos2 + 1) * 0.5; uvs[uk + 1] = (sin2 + 1) * 0.5
		tints[tk] = color
		pk = pk + 3; uk = uk + 2; tk = tk + 1
	end

	faststream.set_table_universal(self._position_stream, pos)
	faststream.set_table_universal(self._texcoord_stream, uvs)
	faststream.set_table_raw(self._tint_stream, tints)

	if not self._buffer_resource then
		unique_buffer_id = unique_buffer_id + 1
		local path = "/attack_zone/circle_mesh_" .. unique_buffer_id .. ".bufferc"
		self._buffer_resource = resource.create_buffer(path, { buffer = self._mesh_buffer })
		go.set(self.mesh_url, "vertices", self._buffer_resource)
	end
end

--- Update the circle radius and rebuild geometry.
---@param self table Script instance
---@param radius number New radius
function M.set_radius(self, radius)
	self.radius = radius
	M.build(self)
end

--- Update the circle color and rebuild geometry.
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

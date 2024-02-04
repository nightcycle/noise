--!strict
--!native
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
function getPoint3D(seed: number, roundX: number, roundY: number, roundZ: number): Vector3
	local xSeed = 0.01 + Random.new(roundX * seed + 1):NextNumber()
	local ySeed = 0.01 + Random.new(roundY * seed + 2):NextNumber()
	local zSeed = 0.01 + Random.new(roundZ * seed + 3):NextNumber()
	local omniSeed = 10000000 * (xSeed + ySeed + zSeed)

	return Vector3.new(roundX, roundY, roundZ) + Vector3.one * 0.5 + 0.5 * Random.new(omniSeed):NextUnitVector()
end
function getPoint2D(seed: number, roundX: number, roundY: number): Vector3
	local xSeed = 0.01 + Random.new(roundX * seed + 1):NextNumber()
	local ySeed = 0.01 + Random.new(roundY * seed + 2):NextNumber()
	local omniSeed = 10000000 * (xSeed + ySeed)

	local vec = Random.new(omniSeed):NextUnitVector()

	return Vector3.new(roundX, roundY) + Vector3.one * 0.5 + 0.5 * Vector3.new(vec.X, vec.Y)
end

-- Class
-- Types
export type Noise = {
	__index: Noise,
	Seed: number,
	_VoronoiCache2D: { [Vector3]: number },
	_VoronoiCache3D: { [Vector3]: number },
	_PointCache2D: { [Vector3]: { [number]: Vector3 } },
	_PointCache3D: { [Vector3]: { [number]: Vector3 } },
	_PerlinHash3D: { [number]: number },
	_PerlinHash2D: { [number]: number },
	-- Vector: (self: Noise, x: number, y: number, z: number?) -> Vector3,
	Random: (self: Noise, x: number, y: number, z: number?) -> number,
	Perlin: (self: Noise, x: number, y: number, z: number?) -> number,
	Cellular: (self: Noise, x: number, y: number, z: number?) -> number,
	Voronoi: (self: Noise, x: number, y: number, z: number?) -> number,
	new: (seed: number?) -> Noise,
}

-- Class
local Noise = {} :: Noise
Noise.__index = Noise

function Noise:Random(x: number, y: number, z: number?): number
	if z then
		local xSeed = 0.01 + Random.new(x * self.Seed * 1):NextNumber()
		local ySeed = 0.01 + Random.new(y * self.Seed * 2):NextNumber()
		local zSeed = 0.01 + Random.new(z * self.Seed * 3):NextNumber()
		local seed = 100000 * ((xSeed + ySeed + zSeed) % 1)
		return Random.new(seed):NextNumber()
	else
		local xSeed = 0.01 + Random.new(x * self.Seed * 1):NextNumber()
		local ySeed = 0.01 + Random.new(y * self.Seed * 2):NextNumber()
		local seed = 100000 * ((xSeed + ySeed) % 1)
		return Random.new(seed):NextNumber()
	end
end

-- function Noise:Vector(x: number, y: number, z: number?): Vector3
-- 	if z then
-- 		local vec = Vector3.new(x, y, z)
-- 		local points: { [number]: Vector3 } = {}
-- 		local origin = Vector3.new(math.floor(x), math.floor(y), math.floor(z))

-- 		if self._PointCache3D[origin] then
-- 			points = self._PointCache3D[origin]
-- 		else
-- 			for x = -1, 1 do
-- 				for y = -1, 1 do
-- 					for z = -1, 1 do
-- 						table.insert(points, getPoint3D(self.Seed, origin.X + x, origin.Y + y, origin.Z + z))
-- 					end
-- 				end
-- 			end
-- 			self._PointCache3D[origin] = points
-- 		end

-- 		local closest: Vector3
-- 		local cDist: number?

-- 		for i, point: Vector3 in ipairs(points) do
-- 			local dist = (point - vec :: any).Magnitude
-- 			if not closest or (cDist and dist < cDist) or not cDist then
-- 				closest = point
-- 				cDist = dist
-- 			end
-- 		end

-- 		return closest
-- 	else
-- 		local vec = Vector3.new(x, y)
-- 		local points: { [number]: Vector3 } = {}
-- 		local origin = Vector3.new(math.floor(x), math.floor(y))

-- 		if self._PointCache2D[origin] then
-- 			points = self._PointCache2D[origin]
-- 		else
-- 			for x = -1, 1 do
-- 				for y = -1, 1 do
-- 					-- if offset == Vector3.zero then
-- 					table.insert(points, getPoint2D(self.Seed, origin.X + x, origin.Y + y))
-- 					-- end
-- 				end
-- 			end
-- 			self._PointCache2D[origin] = points
-- 		end

-- 		local closest: Vector3
-- 		local cDist: number?

-- 		for i, point: Vector3 in ipairs(points) do
-- 			local dist = (point - vec :: any).Magnitude
-- 			if not closest or (cDist and dist < cDist) or not cDist then
-- 				closest = point
-- 				cDist = dist
-- 			end
-- 		end

-- 		return closest
-- 	end
-- end

do
	local R1_3 = 3 / 8
	local R2_3 = 7 / 10

	function Noise:Cellular(x: number, y: number, z: number?): number
		if z then
			local vec = Vector3.new(x, y, z)
			local points: { [number]: Vector3 } = {}
			local origin = Vector3.new(math.floor(x), math.floor(y), math.floor(z))

			if self._PointCache3D[origin] then
				points = self._PointCache3D[origin]
			else
				for pX = -1, 1 do
					for pY = -1, 1 do
						for pZ = -1, 1 do
							table.insert(points, getPoint3D(self.Seed, origin.X + pX, origin.Y + pY, origin.Z + pZ))
						end
					end
				end
				self._PointCache3D[origin] = points
			end

			local closest: Vector3
			local cDist: number?
			local farthest: Vector3
			local fDist: number = 0

			for i, point: Vector3 in ipairs(points) do
				local dist = (point - vec :: any).Magnitude
				if not closest or (cDist and dist < cDist) or not cDist then
					closest = point
					cDist = dist
				end
				if not farthest or dist > fDist then
					farthest = point
					fDist = dist
				end
			end
			assert(cDist)

			return cDist
		else
			local vec = Vector3.new(x, y)
			local points: { [number]: Vector3 } = {}
			local origin = Vector3.new(math.floor(x), math.floor(y))

			if self._PointCache2D[origin] then
				points = self._PointCache2D[origin]
			else
				for pX = -1, 1 do
					for pY = -1, 1 do
						-- if offset == Vector3.zero then
						table.insert(points, getPoint2D(self.Seed, origin.X + pX, origin.Y + pY))
						-- end
					end
				end
				self._PointCache2D[origin] = points
			end

			local closest: Vector3
			local cDist: number?

			for i, point: Vector3 in ipairs(points) do
				local dist = (point - vec :: any).Magnitude
				if not closest or (cDist and dist < cDist) or not cDist then
					closest = point
					cDist = dist
				end
			end
			assert(cDist)

			return (cDist - R1_3) / R2_3
		end
	end
end

do
	function Noise:Voronoi(x: number, y: number, z: number?): number
		if z then
			local vec = Vector3.new(x, y, z)
			local points: { [number]: Vector3 } = {}
			local origin = Vector3.new(math.floor(x), math.floor(y), math.floor(z))

			if self._PointCache3D[origin] then
				points = self._PointCache3D[origin]
			else
				for pX = -1, 1 do
					for pY = -1, 1 do
						for pZ = -1, 1 do
							local offset = Vector3.new(pX, pY, pZ)
							-- if offset == Vector3.zero then
							table.insert(points, getPoint3D(self.Seed, origin.X + offset.X, origin.Y + offset.Y, origin.Z + offset.Z))
							-- end
						end
					end
				end
				self._PointCache3D[origin] = points
			end

			local closest: Vector3
			local cDist: number = math.huge

			for i, point: Vector3 in ipairs(points) do
				local dist = (point - vec :: any).Magnitude
				if not closest or dist < cDist then
					closest = point
					cDist = dist
				end
			end

			if self._VoronoiCache3D[closest] == nil then
				self._VoronoiCache3D[closest] = self:Random(closest.X, closest.Y, closest.Z)
			end
			return self._VoronoiCache3D[closest]
		else
			local vec = Vector3.new(x, y)
			local points: { [number]: Vector3 } = {}
			local origin = Vector3.new(math.floor(x), math.floor(y))

			if self._PointCache2D[origin] then
				points = self._PointCache2D[origin]
			else
				for pX = -1, 1 do
					for pY = -1, 1 do
						for pZ = -1, 1 do
							local offset = Vector3.new(pX, pY, pZ)
							-- if offset == Vector3.zero then
							table.insert(points, getPoint2D(self.Seed, origin.X + offset.X, origin.Y + offset.Y))
							-- end
						end
					end
				end
				self._PointCache2D[origin] = points
			end

			local closest: Vector3
			local cDist: number = math.huge

			for i, point: Vector3 in ipairs(points) do
				local dist = (point - vec :: any).Magnitude
				if not closest or dist < cDist then
					closest = point
					cDist = dist
				end
			end

			if self._VoronoiCache2D[closest] == nil then
				self._VoronoiCache2D[closest] = self:Random(closest.X, closest.Y)
			end
			return self._VoronoiCache2D[closest]
		end
	end
end

-- https://github.com/luau-lang/luau/blob/master/VM/src/lmathlib.cpp#L343
do
	local kPerlinGrad = {
		{ 1, 1, 0 },
		{ -1, 1, 0 },
		{ 1, -1, 0 },
		{ -1, -1, 0 },
		{ 1, 0, 1 },
		{ -1, 0, 1 },
		{ 1, 0, -1 },
		{ -1, 0, -1 },
		{ 0, 1, 1 },
		{ 0, -1, 1 },
		{ 0, 1, -1 },
		{ 0, -1, -1 },
		{ 1, 1, 0 },
		{ 0, -1, 1 },
		{ -1, 1, 0 },
		{ 0, -1, -1 },
	}

	local function perlin_fade(t: number): number
		return t * t * t * (t * (t * 6 - 15) + 10)
	end

	local function perlin_lerp(t: number, a: number, b: number): number
		return a + t * (b - a)
	end

	local function perlin_grad(hash: number, x: number, y: number, z: number): number
		local g = kPerlinGrad[(hash % 16) + 1] -- Lua arrays start at 1, not 0
		return g[1] * x + g[2] * y + g[3] * z
	end

	function Noise:Perlin(x: number, y: number, z: number?): number
		z = z or 0
		assert(z)

		local xflr = math.floor(x)
		local yflr = math.floor(y)
		local zflr = math.floor(z)

		local xi = xflr % 256
		local yi = yflr % 256
		local zi = zflr % 256

		local xf = x - xflr
		local yf = y - yflr
		local zf = z - zflr

		local u = perlin_fade(xf)
		local v = perlin_fade(yf)
		local w = perlin_fade(zf)

		-- assuming kPerlinHash is previously defined and in scope
		local p = self._PerlinHash3D -- Reference the pre-defined hash array here

		local a = (p[xi + 1] + yi) % 256 -- Lua index starts from 1
		local aa = (p[a + 1] + zi) % 256
		local ab = (p[a + 2] + zi) % 256 -- +1 in Lua due to 1-based indexing

		local b = (p[xi + 2] + yi) % 256 -- xi + 1 due to Lua 1-based indexing
		local ba = (p[b + 1] + zi) % 256
		local bb = (p[b + 2] + zi) % 256

		local la = perlin_lerp(u, perlin_grad(p[aa + 1], xf, yf, zf), perlin_grad(p[ba + 1], xf - 1, yf, zf))
		local lb = perlin_lerp(u, perlin_grad(p[ab + 1], xf, yf - 1, zf), perlin_grad(p[bb + 1], xf - 1, yf - 1, zf))
		local la1 = perlin_lerp(u, perlin_grad(p[aa + 2], xf, yf, zf - 1), perlin_grad(p[ba + 2], xf - 1, yf, zf - 1))
		local lb1 = perlin_lerp(u, perlin_grad(p[ab + 2], xf, yf - 1, zf - 1), perlin_grad(p[bb + 2], xf - 1, yf - 1, zf - 1))

		return 0.5 + 0.5 * perlin_lerp(w, perlin_lerp(v, la, lb), perlin_lerp(v, la1, lb1))
	end
end

function Noise.new(seed: number?): Noise
	local self: Noise = setmetatable({}, Noise) :: any
	self.Seed = seed or tick()
	self._PointCache3D = {}
	self._PointCache2D = {}
	self._VoronoiCache2D = {}
	self._VoronoiCache3D = {}
	local rng = Random.new(self.Seed)

	do
		self._PerlinHash3D = {}
		for i = 1, 257 do
			self._PerlinHash3D[i] = rng:NextInteger(1, 256)
		end
		table.freeze(self._PerlinHash3D)
	end

	do
		self._PerlinHash2D = {}
		for i = 1, 257 do
			self._PerlinHash2D[i] = rng:NextInteger(1, 256)
		end
		table.freeze(self._PerlinHash2D)
	end

	table.freeze(self)
	return self
end

return Noise

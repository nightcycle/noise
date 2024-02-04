--!strict
-- Services
-- Packages
-- Modules
local Noise = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("package"))
-- Types
-- Constants
local SAMPLE = 32
-- Variables
local noise = Noise.new()
-- References
-- Private Functions
-- Class
return {
	Functions = {
		["math.noise"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do
					math.noise(x,y)
				end
			end
		end,
		-- ["math.noise-3D"] = function()
		-- 	for x=1, SAMPLE do
		-- 		for y=1, SAMPLE do
		-- 			math.noise(x,y,0)
		-- 		end
		-- 	end
		-- end,
		["perlin-2D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do

					noise:Perlin(x,y)
				end
			end
		end,
		["perlin-3D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do
					noise:Perlin(x,y,0)
				end
			end
		end,
		["cellular-2D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do

					noise:Cellular(x,y)
				end
			end
		end,
		["cellular-3D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do
					noise:Cellular(x,y,0)
				end
			end
		end,
		["voronoi-2D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do

					noise:Voronoi(x,y)
				end
			end
		end,
		["voronoi-3D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do
					noise:Voronoi(x,y,0)
				end
			end
		end,
		["random-2D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do

					noise:Random(x,y)
				end
			end
		end,
		["random-3D"] = function()
			for x=1, SAMPLE do
				for y=1, SAMPLE do
					noise:Random(x,y,0)
				end
			end
		end,
	},

}
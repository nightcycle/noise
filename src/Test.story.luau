--!strict
-- Services
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
local Noise = require(script.Parent)

-- Types
type Maid = Maid.Maid
type Noise = Noise.Noise

-- Constants
local SIZE = Vector2.one * 128 --(64,64)
local FREQ = SIZE.X / 8
local SCALE = 256/SIZE.X
local SKIP_RENDER = false
-- Variables
-- References

function drawNoise(maid: Maid, label: string, solver: (noise: Noise, x: number, y: number) -> number): ImageLabel

	local imageLabel = maid:GiveTask(Instance.new("ImageLabel"))
	imageLabel.Size = UDim2.fromOffset(SIZE.X * SCALE, SIZE.Y * SCALE)
	imageLabel.LayoutOrder = -time()

	local editableImage = maid:GiveTask(Instance.new("EditableImage"))
	editableImage.Size = SIZE

	local isAlive = true
	maid:GiveTask(function()
		isAlive = false
	end)

	local noise = Noise.new(tick())

	local duration = 0
	local count = 0
	for y=0, editableImage.Size.Y-1 do
		if isAlive == false then break end
		for x=0, editableImage.Size.X-1 do
			local start = tick()
			local value = solver(noise, x,y)
			duration += tick() - start
			count += 1

			if not SKIP_RENDER then
				editableImage:DrawRectangle(
					Vector2.new(x,y),
					Vector2.one,
					Color3.fromHSV(0, 0, value),
					0
				)
			end
		end
	end

	editableImage.Parent = imageLabel

	return imageLabel
end

local function mathNoise(x: number, y: number, freq: number): number
	return 0.5 + 0.5 * math.noise(x/freq,y/freq,0)
end
-- Class
return function(frame: Frame)
	local maid = Maid.new()
	task.spawn(function()

		local listLayout = Instance.new("UIListLayout")
		listLayout.Parent = frame
		listLayout.Wraps = true
		listLayout.Padding = UDim.new(0, 4)

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = listLayout.Padding
		padding.PaddingBottom = listLayout.Padding
		padding.PaddingLeft = listLayout.Padding
		padding.PaddingRight = listLayout.Padding
		padding.Parent = frame

		drawNoise(maid, "math.noise", function(noise: Noise, x: number, y: number): number
			return mathNoise(x,y,FREQ)
		end).Parent = frame

		drawNoise(maid, "random-2D", function(noise: Noise, x: number, y: number): number
			return math.clamp(noise:Random(x/FREQ,y/FREQ,0), 0, 1)
		end).Parent = frame

		drawNoise(maid, "perlin-2D", function(noise: Noise, x: number, y: number): number
			return math.clamp(noise:Perlin(x/FREQ,y/FREQ), 0, 1)
		end).Parent = frame

		drawNoise(maid, "cellular-2D", function(noise: Noise, x: number, y: number): number
			return math.clamp(noise:Cellular(x/FREQ,y/FREQ), 0, 1)
		end).Parent = frame

		drawNoise(maid, "voronoi-2D", function(noise: Noise, x: number, y: number): number
			return math.clamp(noise:Voronoi(x/FREQ,y/FREQ), 0, 1)
		end).Parent = frame
	end)
	return function()
		maid:Destroy()
	end
end
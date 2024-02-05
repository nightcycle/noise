# Usage

## Random

<img src="./media/random.png" alt="random">

```lua
local seed = 12356
local x = 0.5
local y = 0.25
local noise = Noise.new(seed)
local value = noise:Random(x,y) -- a value from 0 to 1 (ish)
```

## Perlin

<img src="./media/perlin.png" alt="perlin">

```lua
local seed = 12356
local x = 0.5
local y = 0.25
local noise = Noise.new(seed)
local value = noise:Perlin(x,y) -- a value from 0 to 1 (ish)
```

## Worley / Cellular

<img src="./media/worley.png" alt="worley">

```lua
local seed = 12356
local x = 0.5
local y = 0.25
local noise = Noise.new(seed)
local value = noise:Cellular(x,y) -- a value from 0 to 1 (ish)
```

## Voronoi

<img src="./media/voronoi.png" alt="voronoi">

```lua
local seed = 12356
local x = 0.5
local y = 0.25
local noise = Noise.new(seed)
local value = noise:Voronoi(x,y) -- a value from 0 to 1 (ish)
```

# Benchmark

Each map was sampled 32 times, including math.noise, to determine how long each of them took. Some maps have built in optimizations for when only x and y are provided.

<img src="./media/bench.png" alt="bench">

As you can see, math.noise is 2x faster than anything else. The perlin implementation is literally a translation of the official luau source code, so it's unsurprisingly running the fastest. The only reason you'd used this over math.noise is if you want deterministic seed control. The random noise map is just a bunch of Random datatypes in a trenchcoat, so it's also fairly fast.

In general, the more complex maps require around 50-60 microseconds to run per call - not a dealbreaker, but you'll want to be smart when you use them. They do cache their outputs though, so calling a repeat set of conditions can be faster than math.noise.


local count = 0
DeadPlayers = {}
local dp = DeadPlayers
local meta = {} --metatable is required to prevent indexing fields with functions via 'pairs'

setmetatable(dp, meta)
meta.__index = meta

meta.add = function(plyr)
	if count >= config.MAX_GRAVES then
		count = 0
	end
	count = count + 1
	local t = love.timer.getTime()
	dp[count] = {plyr.x, plyr.y, t + config.GRAVE_TIME}
end

-- meta.think = function(dt)
	-- for _, v in pairs(np) do
		-- v:think(dt)
	-- end
-- end

meta.free = function()
	local t = love.timer.getTime()
	for k, v in pairs(dp) do
		if v[3] < t then
			dp[k] = nil
		end
	end
end

meta.draw = function()
	for _, v in pairs(dp) do
		local x, y = camera.ToScreen(v[1], v[2])
		funcs.DrawEx(textures.grave, x, y)
	end
end

return DeadPlayers
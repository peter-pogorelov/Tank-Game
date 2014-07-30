entitypool = {}
local ep = entitypool
local meta = {} --metatable is required to prevent indexing fields with functions via 'pairs'

setmetatable(ep, meta)
meta.__index = meta

meta.add = function(e)
	table.insert(ep, e)
end

meta.update = function(dt)
	for k, v in pairs(ep) do
		if getmetatable(v) == AmmoStack then
			if funcs.Distance(v.x, v.y, player.x, player.y) < player:getMaxWidth() then
				if player:getAmmo() < config.PLAYER_AMMO then
					player:setAmmo(v.value)
					table.remove(ep, k)
				end
			end
		end
	end
end

meta.draw = function()
	for _, v in pairs(ep) do
		v:draw()
	end
end

return ep
local count = 0
npcpool = {}
local np = npcpool
local meta = {} --metatable is required to prevent indexing fields with functions via 'pairs'

setmetatable(np, meta)
meta.__index = meta

meta.add = function(npc)
	if count >= config.MAX_NPC then
		count = 0
	end
	count = count + 1
	np[count] = npc
end

meta.think = function(dt)
	for _, v in pairs(np) do
		v:think(dt)
	end
end

meta.free = function()
	for k, v in pairs(np) do
		if v:isDead() then
			v:kill()
			np[k] = nil
		end
	end
end

meta.draw = function()
	for _, v in pairs(np) do
		local x, y = v:getPos()
		local x1, y1 = player:getPos()
		
		if funcs.Distance(x, y, x1, y1) < config.DRAWING_DISTANCE then
			v:draw()
		end
	end
end

meta.collide = function(ent, x, y)
	for _, v in pairs(np) do
		if v ~= ent then
			local x1, y1 = v:getPos()
			if funcs.Distance(x1, y1, x, y) < ent:getMaxWidth() + v:getMaxWidth() then
				return true
			end
		end
	end
	
	return false
end

return np
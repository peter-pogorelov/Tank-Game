local count = 0
bulletpool = {}
local bp = bulletpool
local meta = {} --metatable is required to prevent indexing fields with functions via 'pairs'

setmetatable(bp, meta)
meta.__index = meta

meta.add = function(bul)
	if count >= config.MAX_BULLETS then
		count = 0
	end
	count = count + 1
	bp[count] = bul
end

meta.update = function(dt)
	for k, v in pairs(bp) do
		v:updatePos(dt)
		
		if not player:hasCollision(v.x, v.y) then
			for _, n in pairs(npcPool) do--check collisions with npc
				if n:hasCollision(v.x, v.y) then
					n:damage(v.damage)
					bp[k] = nil
					break
				end
			end
		else
			player:damage(v.damage)
			bp[k] = nil
		end
	end
end

meta.free = function()
	for k, v in pairs(bp) do
		local vx, vy = camera.ToScreen(v:getPos())
		if vx < 0 or vx > screen.width or vy < 0 or vy > screen.height then
			bp[k] = nil
		end
	end
end

meta.draw = function()
	for _, v in pairs(bp) do
		v:draw()
	end
end

return bp
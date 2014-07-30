map = {
	struct_size = 10,
	real_cell = 64,
	size = 0, 
	ent_count = 0, 
	wall_count = 0, 
	cell_size = 0, 
	raw = {}, 
	ents = {}, 
	walls = {}
}

function map.load(name)
	local f = io.open(name, 'rb')
	if f ~= nil then
		local t = f:read('*a')
		f:close()
		map.size = string.byte(t, 1)
		local count = 2
		
		for i = 0, map.size-1 do
			map.raw[i] = {}
			for j = 0 , map.size-1 do
				map.raw[i][j] = string.byte(t, i*map.size + j + 2)
				count = count + 1
			end
		end
		
		map.ent_count = string.byte(t, count)
		count = count + 1
		
		for i = 0, map.ent_count - 1 do
			local off = count
			local x = funcs.ReadDWord(t, off)
			off = off + 4
			local y = funcs.ReadDWord(t, off)
			off = off + 4
			local ent = string.byte(t, off)
			off = off + 1
			local entType = string.byte(t, off)
			table.insert(map.ents, {['x'] = x, ['y'] = y, ['ent'] = ent, ['type'] = entType})
			count = count + map.struct_size
		end
		
		map.wall_count = string.byte(t, count)
		map.cell_size = string.byte(t, count + 1)
		
		for k, v in pairs(map.ents) do --resize coords using given value of cell size 
			map.ents[k].x = v.x / map.cell_size * map.real_cell
			map.ents[k].y = v.y / map.cell_size * map.real_cell
		end
	else
		error('Unable to load map. File "'..name..'" is corrupted or doesnt exist')
	end
end

function map.draw()
	local x, y = player.x, player.y
	local cx, cy = math.floor(player.x / map.real_cell), math.floor(player.y / map.real_cell)
	local dcells = config.DRAWING_CELLS
	
	for i = cx - dcells, cx + dcells do
		for j = cy - dcells, cy + dcells do
			if map.raw[i] ~= nil and map.raw[i][j] ~= nil then
				love.graphics.draw(textures.map[map.raw[i][j]], i * 64 - camera.x, j * 64 - camera.y)
			end
		end
	end
end

function map.isOutside(x, y)
	if type(x) == 'table' then
		x, y = x[1], x[2]
	end
	local size = map.real_cell * map.size
	return x <= 0 or x >= size or y <= 0 or y >= size
end

return map
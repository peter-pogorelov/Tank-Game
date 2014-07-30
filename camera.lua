camera = {x = 0, y = 0, border_reach = false}
camera.screen = {
	width = nil,
	height = nil,
	area = {
		top = nil,
		bottom = nil,
		left = nil,
		right = nil
	}
}

local scr = camera.screen

camera.setup = function(x, y)--coords of entity
	camera.x, camera.y = x - scr.width / 2, y - scr.height / 2
end

camera.ToScreen = function(x, y)
	return x - camera.x, y - camera.y
end

camera.ToGlobal = function(x, y)
	return x + camera.x, y + camera.y
end

camera.update = function(x, y)
	x, y = camera.ToScreen(x, y)
	camera.border_reach = (x <= scr.area.left or x >= scr.area.right) or (y <= scr.area.top or y >= scr.area.bottom)
end

camera.updatePos = function(dx, dy)
	camera.x = camera.x + dx
	camera.y = camera.y + dy
end

camera.isBorderReached = function()
	return camera.border_reach
end

scr.setup = function()
	scr.width = love.graphics.getWidth()
	scr.height = love.graphics.getHeight()
	
	scr.area.right = scr.width - scr.width / 3
	scr.area.left = scr.width / 3
	scr.area.top = scr.height / 3
	scr.area.bottom = scr.height - scr.height / 3
end

scr.center = function()
	return scr.width / 2, scr.height / 2
end

return camera
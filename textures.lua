textures = {}
local texs = textures

texs.tank = {}
texs.map = {}

textures.load = function()
	texs.tank['default'] = {
		['gun'] = love.graphics.newImage('textures/gun.png'),
		['head'] = love.graphics.newImage('textures/head.png'),
		['body'] = love.graphics.newImage('textures/body.png')
	}
	
	texs.tank['deadly'] = {
		['gun'] = love.graphics.newImage('textures/dgun.png'),
		['head'] = love.graphics.newImage('textures/dhead.png'),
		['body'] = love.graphics.newImage('textures/dbody.png')
	}
	
	texs.bullet = love.graphics.newImage('textures/bullet.png')
	
	texs.grave = love.graphics.newImage('textures/grave.png')
	texs.ammo = love.graphics.newImage('textures/ammo.png')

	texs.map[5] = love.graphics.newImage('textures/grass.png')
	texs.map[3] = love.graphics.newImage('textures/sand.png')
end

return textures
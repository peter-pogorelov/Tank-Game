textures = require "textures"
funcs = require "funcs"
config = require "config"
map = require "map"
ents = require "ents"
contrl = require "contrl"
plyr = require "player"
camera = require "camera"
bulletPool = require "bulletpool"
npcPool = require "npcpool"
entEnum = require "entenum"
deadPlayers = require "deadplayers"
hud = require "hud"
entityPool = require "entitypool"

screen = camera.screen
controller = contrl.Controller

player = nil
healthBar = nil
ammoBar = nil

function love.load()
	math.randomseed(os.time())
	math.random()
	config.read('.\\game\\config.txt')

	mapname = config.MAP_NAME--take it from the config in the future
	map.load('.\\game\\'..mapname)
	love.window.setTitle('Codename: '..mapname)
	textures.load()
	screen.setup()
	
	for _, v in pairs(map.ents) do
		if entEnum[v.ent] == 'Spawnpoint' then
			if entEnum['Spawnpoint'][v.type] == 'player' then
				player = ents.Spawnpoint:new{x = v.x, y = v.y}:spawn()
			end
		elseif entEnum[v.ent] == 'NPC' then
			if entEnum['NPC'][v.type] == 'tank' then
				local e = plyr.Enemy:new()
				e:init(v.x, v.y, nil, nil, (
					function()
						local rnd = math.random(1, 3)
						
						if rnd == 1 then
							return 'straight'
						elseif rnd == 2 then
							return 'sinusoid'
						elseif rnd == 3 then
							return 'strafing'
						end
					end
				)())
				npcPool.add(e)
			end
		elseif entEnum[v.ent] == 'Ammo' then
			local e = ents.AmmoStack:new()
			e:init(v.x, v.y)
			entityPool.add(e)
		end
	end
	
	if player == nil then
		error('Spawnpoint for player is required.')
	end
	
	camera.setup(player.x, player.y)
	healthBar = hud.HealthBar:new()
	healthBar:init(player, 0, screen.height - 10, screen.width / 2, 10)
	
	ammoBar = hud.AmmoBar:new()
	ammoBar:init(player, screen.width / 2, screen.height - 10, screen.width / 2, 10)
end

function love.update(dt)
	controller.update()
	local box = player:getBox(dt)
	
	if not map.isOutside(box[1]) and not map.isOutside(box[2]) and not map.isOutside(box[3]) and not map.isOutside(box[4]) then
		player:move(dt)
		camera.update(player.x, player.y)
	
		if camera.isBorderReached() then
			camera.updatePos(player:getDelta('x', dt), player:getDelta('y', dt))
		end
	end
	
	if player:isDead() then
		love.event.quit()
	end
	
	--healthBar:update(player)
	--ammoBar:update(player)
	
	bulletPool.update(dt)
	bulletPool.free()
	
	npcPool.think(dt)
	npcPool.free()
	
	entityPool.update()
	deadPlayers.free()
	
	if controller.isFiring() and player:canAttack() then
		player:attack()
	end
end

function love.draw() --only drawing in local(screen) coords.
	map.draw()
	
	love.graphics.setBackgroundColor(0, 0, 0)
	entityPool.draw()
	deadPlayers.draw()
	npcPool.draw()
	player:draw()
	bulletPool.draw()
	healthBar:draw()
	ammoBar:draw()
end
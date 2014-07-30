Player = Entity:new{health = 100, ammo = 10, x = 0, y = 0, ang = -math.pi / 2, speed = 100}

-- function Player:new(t)
	-- t = t or {}
	-- setmetatable(t, self)
	-- self.__index = self
	-- return t
-- end

function Player:setHealth(v)
	self.health = v
end

function Player:getHealth()
	return self.health
end

function Player:getAmmo()
	return self.ammo
end

function Player:setAmmo(v)
	if v <= config.PLAYER_AMMO then
		self.ammo = v
	else
		self.ammo = config.PLAYER_AMMO
	end
end

function Player:isDead()
	return self.health <= 0
end

function Player:damage(dmg)
	self.health = self.health - dmg
end

function Player:kill()
	deadPlayers.add(self)
end
	
LocalPlayer = Player:new{modelName = 'default'}

function LocalPlayer:init(x, y, health, ammo)
	self.x = x
	self.y = y
	
	if health ~= nil then
		self.health = health
	else
		self.health = config.PLAYER_HEALTH
	end
	
	if ammo ~= nil then
		self.ammo = ammo
	else
		self.ammo = config.PLAYER_AMMO 
	end
end

function LocalPlayer:getDelta(kind, delta)
	if kind == 'x' then
		return self.speed * delta * math.cos(self.angle + self:getDelta('ang', delta)) * controller.getMoveState()
	elseif kind == 'y' then
		return self.speed * delta * math.sin(self.angle + self:getDelta('ang', delta)) * controller.getMoveState()
	elseif kind == 'ang' then
		return config.PLAYER_ROTATION_SPEED * delta * controller.getRotState()
	end
end

function LocalPlayer:getNextPos(dt)
	local x = self.x + self:getDelta('x', dt)
	local y = self.y + self:getDelta('y', dt)
	
	return x, y
end

function LocalPlayer:move(dt)
	local dx, dy = self:getNextPos(dt)
	self.angle = self.angle + self:getDelta('ang', dt)
	
	--it is required to check whenever client reaches a dead zone on the screen
	self.x = dx --global position of client on the map
	self.y = dy
end

function LocalPlayer:mouseAngle()--angle between mouse und tank according to a viewport
	local x, y = love.mouse.getPosition()
	local mx, my = camera.ToScreen(self:getPos())--from funcs.lua
	return math.atan2(y - my, x - mx)
end

function LocalPlayer:localAngle(x, y)
	return math.atan2(y - self.y, x - self.x)
end

function LocalPlayer:getMaxWidth()--remaster that 
	local a = textures.tank[self.modelName].body:getWidth() / 2
	return math.sqrt(2*a^2)
end

function LocalPlayer:getGunPos()
	local ang = self:mouseAngle()
	local clientPic = textures.tank[self.modelName]
	local hxoff, hyoff = funcs.GetImageCenter(clientPic.head)
	local gxoff, gyoff = funcs.GetImageSize(clientPic.gun)
	
	return self.x + (hxoff + gxoff)*math.cos(ang), self.y + (hyoff + gyoff)*math.sin(ang)
end

function LocalPlayer:canAttack()
	return self:getAmmo() > 0
end

function LocalPlayer:attack()
	local x, y = self:getPos()
	local gx, gy = self:getGunPos()
	local ang = self:mouseAngle()
	local bullet = ents.Bullet:new()
	bullet:init(gx, gy, ang)
	bulletPool.add(bullet)
	self:setAmmo(self:getAmmo()-1)
end

function LocalPlayer:draw()
	local ang = self:mouseAngle()
	local x, y = camera.ToScreen(self:getPos())
	local clientPic = textures.tank[self.modelName]
	funcs.DrawEx(clientPic.body, x, y, self.angle)
	funcs.DrawEx(clientPic.head, x, y)
	local hxoff, hyoff = funcs.GetImageCenter(clientPic.head)
	local gxoff, gyoff = funcs.GetImageCenter(clientPic.gun)
	funcs.DrawEx(clientPic.gun, x + math.cos(ang)*(hxoff+gxoff), y + math.sin(ang)*(hyoff+gyoff), ang)
end

function LocalPlayer:getBox(dt)
	local box = {}
	local body = textures.tank[self.modelName].body
	local w, h = funcs.GetImageSize(body)
	local x, y = 0, 0
	
	if dt ~= nil then
		x, y = self:getNextPos(dt)
	else
		x, y = self:getPos()
	end
	
	sq = math.sqrt((w/2)^2 + (h/2)^2)
	local x1, y1 = x + math.cos(self.angle + math.pi / 4)*sq, y + math.sin(self.angle + math.pi / 4)*sq
	local x2, y2 = x - math.cos(self.angle - math.pi / 4)*sq, y - math.sin(self.angle - math.pi / 4)*sq
	local x3, y3 = x - math.cos(self.angle + math.pi / 4)*sq, y - math.sin(self.angle + math.pi / 4)*sq
	local x4, y4 = x + math.cos(self.angle - math.pi / 4)*sq, y + math.sin(self.angle - math.pi / 4)*sq
	return {{x1,y1}, {x2,y2}, {x3,y3}, {x4,y4}}
end

function Player:hasCollision(x, y)
	local w,h = funcs.GetImageSize(textures.tank[self.modelName].body)
	return math.sqrt((self.x - x)^2 + (self.y - y)^2) < w / 2
end

--------------
--ENEMY-CODE--
--------------

Enemy = LocalPlayer:new{
	acitve = false, movetype = 'straight', 
	param = 0, x = 0, y = 0, q = 1, 
	modelName = 'deadly', can_attack = true,
	delay = 0
}

function Enemy:init(x, y, speed, health, movetype)
	self._x, self._y = x, y --coordinates of straight direction
	
	if health ~= nil then
		--error(health)
		self.health = health
	else
		self.health = config.PLAYER_HEALTH
	end
	
	if speed ~= nil then
		self.speed = speed
	else
		self.speed = config.ENEMY_SPEED
	end
	
	if movetype ~= nil then
		self.movetype = movetype
	else
		self.movetype = 'straight'
	end
end

function Enemy:getDelta(kind, delta, dang)
	if kind == 'x' then
		return self.speed * delta * math.cos(self.angle + (dang == nil and 0 or dang))
	elseif kind == 'y' then
		return self.speed * delta * math.sin(self.angle + (dang == nil and 0 or dang))
	elseif kind == 'ang' then
		return delta * self:getRotFactor()
	end
end

function Enemy:getNextPos(dt)
	local dang = 0
	local q = 1
	local x, y = 0, 0
	
	repeat -- check every x, y around the tank to prevent collisions between NPC's
		x = self._x + self:getDelta('x', dt, dang*q)
		y = self._y + self:getDelta('y', dt, dang*q)
		
		dang = dang + 0.01
		q = -q
	until not (dang < math.pi / 2 and npcPool.collide(self, x, y))

	if dang < math.pi / 2 then
		return x, y
	else
		return self._x, self._y
	end
end

function Enemy:moveSinusoid(dt)
	self.x, self.y = self:getNextPos(dt)
	
	self.param = self.param + self.q*config.SIN_SPEED*dt
	if self.param > config.SIN_WIDTH then
		self.q = -1
	end
	if self.param < -config.SIN_WIDTH then
		self.q = 1
	end
	
	self.angle = self.angle + self.q * dt * 2
	
	-- local nx = x + math.cos(self.angle + math.pi / 2) * self.param
	-- local ny = y + math.sin(self.angle + math.pi / 2) * self.param
	
	-- --causes freezes of enemies
	-- --if not npcPool.collide(self, nx, ny) then
		-- self.x = nx
		-- self.y = ny
	-- --end
end

function Enemy:moveStrafing(dt)
	local x, y = self:getNextPos(dt)
	
	self.param = self.param + self.q*config.STRAFE_SPEED*dt
	if self.param > config.STRAFE_WIDTH then
		self.q = -1
	end
	if self.param < -config.STRAFE_WIDTH then
		self.q = 1
	end
	
	--self.angle = self.angle + self.q * dt * 2
	
	local nx = x + math.cos(self.angle + math.pi / 2) * self.param
	local ny = y + math.sin(self.angle + math.pi / 2) * self.param
	
	--causes freezes of enemies
	--if not npcPool.collide(self, nx, ny) then
		self.x = nx
		self.y = ny
	--end
end

function Enemy:moveStraight(dt)
	self.x, self.y = self:getNextPos(dt)
end

function Enemy:isAimed()--remaster it in the future
	return self.active
end

function Enemy:hasCollision(x, y)
	local a = textures.tank[self.modelName].body:getWidth() / 2
	return math.sqrt((self.x - x)^2 + (self.y - y)^2) < a
end

function Enemy:getGunPos()
	local ang = self:localAngle(player.x, player.y)
	local clientPic = textures.tank[self.modelName]
	local hxoff, hyoff = clientPic.head:getWidth() / 2 * math.cos(ang), clientPic.head:getHeight() / 2 * math.sin(ang)
	local gxoff, gyoff = clientPic.gun:getWidth() * math.cos(ang), clientPic.gun:getHeight() * math.sin(ang)
	return self.x + hxoff + gxoff, self.y + hyoff + gyoff
end

function Enemy:draw()
	local ang = self.angle
	local x, y = camera.ToScreen(self.x, self.y)
	local clientPic = textures.tank[self.modelName]
	funcs.DrawEx(clientPic.body, x, y, self.angle)
	funcs.DrawEx(clientPic.head, x, y)
	local offx, offy = clientPic.head:getWidth() / 2 + clientPic.gun:getWidth() / 2, clientPic.head:getHeight() / 2 + clientPic.gun:getHeight() / 2
	ang = self:localAngle(player.x, player.y)
	funcs.DrawEx(clientPic.gun, x + math.cos(ang)*offx, y + math.sin(ang)*offy, ang)
end

function Enemy:getRotFactor()
	local delta = (self.angle - self:localAngle(player.x, player.y))
	if math.abs(delta) > math.pi then
		self.angle = self.angle - delta--*(delta < 0 and 1 or -1)
		return self:getRotFactor()
	end
	
	return delta < 0 and 1 or -1
end

function Enemy:think(dt)
	if not self.active and funcs.Distance(self._x, self._y, player.x, player.y) < config.ACTIVATION_DISTANCE then
		self.active = true
		self.x = self._x
		self.y = self._y
	end
	
	if self.active then
		if funcs.Distance(self._x, self._y, player.x, player.y) > config.FOLLOW_DISTANCE then
			if math.abs(self.angle + self:getDelta('ang', dt)) >= math.pi then
				self.angle = -self.ang
			end
			
			self.angle = self.angle + self:getDelta('ang', dt)--math.atan2(player.y - self._y, player.x - self._x)
		
			self._x, self._y = self:getNextPos(dt)
			
			if self.movetype == 'sinusoid' then
				self:moveSinusoid(dt)
			elseif self.movetype == 'straight' then
				self:moveStraight(dt)
			elseif self.movetype == 'strafing' then
				self:moveStrafing(dt)
			end
		end
		
		if not self.can_attack then
			local t = love.timer.getTime()
			
			if self.delay < t then
				self.can_attack = true
			end
		end
		
		if self:canAttack() then
			self:attack()
		end
	end
end

function Enemy:canAttack()
	return self.can_attack
end

function Enemy:attack()
	self.can_attack = false
	self.delay = love.timer.getTime() + config.SHOT_DELAY + math.random() * config.SHOT_DELTA
	local x, y = self.x, self.y
	local gx, gy = self:getGunPos()
	local ang = self:localAngle(player.x, player.y)
	local bullet = ents.Bullet:new()
	bullet:init(gx, gy, ang)
	bulletPool.add(bullet)
end

NetworkPlayer = Player:new() -- maybe in the future..

return {
	Player = Player,
	LocalPlayer = LocalPlayer,
	Enemy = Enemy
}
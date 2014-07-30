Entity = {
	x = 0, y = 0, angle = -math.pi / 2
}

function Entity:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

function Entity:setPos(x, y)
	self.x = x
	self.y = y
end

function Entity:getPos()
	return self.x, self.y
end

function Entity:setAng(val)
	self.angle = val
end

function Entity:getAng()
	return self.angle
end

--Bullet

Bullet = Entity:new{damage = 20, texture = nil}

function Bullet:init(x, y, ang, speed, damage, texture)
	self.x, self.y = x, y
	self.angle = ang
	
	if speed ~= nil then
		self.speed = speed
	else
		self.speed = config.BULLET_SPEED
	end
	
	if damage ~= nil then
		self.damage = damage
	else
		self.damage = config.BULLET_DAMAGE
	end
	
	if texture ~= nil then
		self.texture = texture
	else
		self.texture = textures.bullet
	end
end

function Bullet:getNextPos(dt)
	local x = self.x + self.speed * math.cos(self.angle) * dt
	local y = self.y + self.speed * math.sin(self.angle) * dt
	
	return x, y
end

function Bullet:updatePos(dt)
	self:setPos(self:getNextPos(dt))
end

function Bullet:draw()
	local xoff, yoff = funcs.GetImageCenter(self.texture)
	local x, y = camera.ToScreen(self:getPos())
	funcs.DrawEx(self.texture, x, y, self.angle)
end

--Ammo

AmmoStack = Entity:new()

function AmmoStack:init(x, y, v, texture)
	self.x = x
	self.y = y
	
	if v ~= nil then
		self.value = v
	else
		self.value = config.PLAYER_AMMO
	end
	
	if texture ~= nil then
		self.texture = texture
	else
		self.texture = textures.ammo
	end
end

function AmmoStack:draw()
	local x, y = camera.ToScreen(self:getPos())
	funcs.DrawEx(self.texture, x, y, nil)
end

--Spawnpoint

Spawnpoint = Entity:new{kind = 'player'} --player by default

function Spawnpoint:spawn()
	if self.kind == 'player' then
		local p = LocalPlayer:new()
		p:init(self.x, self.y, config.PLAYER_HEALTH, config.PLAYER_AMMO)
		return p
	end
	
	if self.kind == 'enemy' then --TODO
		
	end
end

return {
	Entity = Entity,
	Bullet = Bullet,
	AmmoStack = AmmoStack,
	Spawnpoint = Spawnpoint
}
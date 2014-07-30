Hud = {x = 0, y = 0}

function Hud:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

HealthBar = Hud:new()

function HealthBar:init(pl, x, y, w, h)
	self.ply = pl
	self.maxHealth = config.PLAYER_HEALTH
	
	self.x = x
	self.y = y
	
	self.width = w
	self.height = h
end

function HealthBar:draw()
	local dw = self.width * self.ply:getHealth() / self.maxHealth
	love.graphics.setColor(255 * self.ply:getHealth() / self.maxHealth, 0, 0)
	love.graphics.rectangle('fill', self.x, self.y, dw, self.height)
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle('fill', self.x+dw, self.y, self.width - dw, self.height)
	love.graphics.setColor(255, 255, 255)
end

AmmoBar = Hud:new()

function AmmoBar:init(pl, x, y, w, h)
	self.ply = pl
	self.maxAmmo = config.PLAYER_AMMO
	
	self.x = x
	self.y = y
	
	self.width = w
	self.height = h
end

function AmmoBar:draw()
	local dw = self.width * self.ply:getAmmo() / self.maxAmmo
	love.graphics.setColor(0, 255 * self.ply:getAmmo() / self.maxAmmo, 0)
	love.graphics.rectangle('fill', self.x, self.y, dw, self.height)
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle('fill', self.x+dw, self.y, self.width - dw, self.height)
	love.graphics.setColor(255, 255, 255)
end

return {
	Hud = Hud,
	HealthBar = HealthBar,
	AmmoBar = AmmoBar
}
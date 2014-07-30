contrl = {}

Controller = {
	drun = false,
	dm = 0,
	dr = 0,
	df = false,
	dfhold = false
}

Controller.update = function()
	if love.keyboard.isDown('w') then
		Controller.dm = 1
	elseif love.keyboard.isDown('s') then
		Controller.dm = -1
	else
		Controller.dm = 0
	end
	
	if love.keyboard.isDown('a') then
		Controller.dr = -1
	elseif love.keyboard.isDown('d') then
		Controller.dr = 1
	else
		Controller.dr = 0
	end
	
	if love.keyboard.isDown('shift') then
		Controller.drun = true
	else
		Controller.drun = false
	end
	
	Controller.dfhold = Controller.df
	
	if config.USING_MOUSE_TO_FIRE then
		Controller.df = love.mouse.isDown('l')
	else
		Controller.df = love.keyboard.isDown(' ')
	end
end

Controller.isRunning = function()
	return Controller.drun
end

Controller.getRotState = function()
	return Controller.dr
end

Controller.getMoveState = function()
	return Controller.dm
end

Controller.isFiring = function()
	if config.ALLOW_HOLDING_FIRE then
		return Controller.df
	end
	
	return Controller.df and not Controller.dfhold
end

contrl.Controller = Controller

return contrl
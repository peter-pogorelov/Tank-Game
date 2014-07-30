config = { --default config
	--map cfg
	MAP_NAME = 'map.map',
	DRAWING_CELLS = 10,
	--bullet pool
	MAX_BULLETS = 1024,
	--npc pool
	DRAWING_DISTANCE = 500,
	MAX_NPC = 200,
	--enemy AI
	ACTIVATION_DISTANCE = 500,
	ENEMY_SPEED = 40,
	FOLLOW_DISTANCE = 200,
	SIN_SPEED = 100,
	SIN_WIDTH = 60,
	STRAFE_SPEED = 100,
	STRAFE_WIDTH = 60,
	--controller
	ALLOW_HOLDING_FIRE = false,
	USING_MOUSE_TO_FIRE = true,
	--player
	PLAYER_AMMO = 20,
	PLAYER_HEALTH = 100,
	SHOT_DELAY = 3,--seconds
	SHOT_DELTA = 1,--seconds
	GRAVE_TIME = 30,--seconds
	MAX_GRAVES = 1000,
	PLAYER_SPEED = 300,
	PLAYER_ROTATION_SPEED = 2,
	--ents
	BULLET_DAMAGE = 20,
	BULLET_SPEED = 200,
	ROTATION_SPEED = 2,
	--config
	GENERATE_CONFIG = false
}



config.correctValue = function(x)
	if x == 'true' or x == 'false' then
		return x == 'true'
	elseif tonumber(x) ~= nil then
		return tonumber(x)
	else
		return x
	end
end

config.dump = function(filename)
	f = io.open(filename, 'w')
	f:write('[AUTOMATICALY GENERATED]\n')
	if f ~= nil then
		for k, v in pairs(config) do
			if type(v) ~= 'function' then
				f:write(k..'='..tostring(v)..'\n')
			end
		end
	end
	f:flush()
	f:close()
end

config.read = function(filename)
	local f = io.open(filename, 'r')
	if f ~= nil then
		f:close()
		local ptrn = '(%w+)%s*=%s*(%w+)'
		for line in io.lines(filename) do
			line = line:gsub('//.*', '')
			if line:find(ptrn) ~= nil then
				local a, b = line:find('=')
				local cmnd = line:sub(1, a-1)
				local val = line:sub(b+1, line:len())
				
				if config[cmnd] ~= nil then
					config[cmnd] = config.correctValue(val)
				end
			end
		end
	else
		if config.GENERATE_CONFIG then
			config.dump(filename)
		end
	end
end

return config
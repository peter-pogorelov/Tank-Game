funcs = {} --helper functions

function funcs.DrawEx(pic, x, y, r, xoff, yoff)
	if xoff == nil and yoff == nil then
		xoff, yoff = pic:getWidth() / 2, pic:getHeight() / 2
	end
	
	if r == nil then
		r = 0
	end
	
	love.graphics.draw(pic, x, y, r, 1, 1, xoff, yoff)
end

function funcs.BytesToDWord(bytes)
	return tonumber(string.format('0x%x%x%x%x', bytes[4], bytes[3], bytes[2], bytes[1]))
end

function funcs.ReadDWord(str, offs)
	local bytes = {}
	bytes[1] = string.byte(str, offs)
	bytes[2] = string.byte(str, offs+1)
	bytes[3] = string.byte(str, offs+2)
	bytes[4] = string.byte(str, offs+3)
	
	return funcs.BytesToDWord(bytes)
end

function funcs.Distance(x1, y1, x2, y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function funcs.GetImageCenter(img)
	return img:getWidth() / 2, img:getHeight() / 2
end

function funcs.GetImageSize(img)
	return img:getWidth(), img:getHeight()
end

function funcs.tstr(tbl) --debug function. recursively outputs whats inside a table
	local str = '{'
	for k, v in pairs(tbl) do
		if type(v) == 'table' then
			str = str..funcs.tstr(v)
		elseif type(v) == 'number' then
			str = str..k..':'..tostring(math.floor(v))
		else
			str = str..k..':'..tostring(v)
		end
		str = str..';'
	end
	if str ~= '{' then
		str = string.sub(str, 1, -2)
	end
	str = str..'}'

	return str
end

return funcs
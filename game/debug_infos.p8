__lua__6
-- debug infos

function debug_coords()
	line(10,70,10,70,8)
	print("point x:10 y:70", 10,60,8)
	
	print("ship_x:" .. pl_ship_x, 10, 10, 7)
	print("ship_y:" .. pl_ship_y, 10, 20, 7)
	print("drone_x:" .. drone_x, 10, 30, 12)
	print("drone_y:" .. drone_y, 10, 40, 12)
end

function info(text, val, plusy)
		if plusy == nil then
			plusy = 0
		end
		if val == nil then
			val = ""
		end
 	print(text .. ": " .. val, 5, 5+plusy, 7)
end
-->8

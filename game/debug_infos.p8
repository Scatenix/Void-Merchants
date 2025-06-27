__lua__13
-- debug infos

function debug_coords()
	line(10,70,10,70,8)
	print("point x:10 y:70", 10,60,8)
	
	print("ship_x:" .. pl_ship_x, 10, 10, 7)
	print("ship_y:" .. pl_ship_y, 10, 20, 7)
	print("drone_x:" .. drone_x, 10, 30, 12)
	print("drone_y:" .. drone_y, 10, 40, 12)
end

function info(text, val, plus_y)
		if plus_y == nil then
			plus_y = 0
		end
		if val == nil then
			val = ""
		end
	print(text .. ": " .. val, 5, 5+plus_y, 7)
end

function show_stored_items()
	y = 0
	for i in all(pl_items_stored) do
		info("i" .. y .. ": ", i[1], y)
		spr(i[1], 50, y+4)
		y+=7
	end
end
-->8

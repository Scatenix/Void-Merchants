__lua__16
-- title screen

function draw_titlescreen()
	-- version
	print("beta " ..GAME_VERSION, 84, 1, 10)
	-- void merchants
	sspr(88, 104, 40, 16, 24, 20, 80, 32)
	-- hide enemy ship
	rectfill(24, 20, 39, 36, 0)
	-- merchant station
	sspr(32, 112, 16, 16, 5, 4, 32, 32)
	-- black hole
	sspr(64, 72, 16, 16, 48, 55, 32, 32)
	-- small planet
	sspr(small_planets[current_small_planet][1], small_planets[current_small_planet][2], 16, 16, 96, 22, 16, 16)

	if wait_after_titlescreen or #pl_ship_shots > 0 then
		print("prepare!", 48, 110, 10)	
	else
		if animation_counter > 10 then
			print("press ❎ to play", 32, 110, 10)
			if save_game_exists() then
				print("press 🅾️ to load your last save", 2, 118, 12)
			end
		else
			print("press ❎ to play", 32, 111, 10)
			if save_game_exists() then
				print("press 🅾️ to load your last save", 2, 119, 12)
			end
		end
	end
end



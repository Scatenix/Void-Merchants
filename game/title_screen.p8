__lua__15
-- title screen

function draw_titlescreen()
	-- version
	print("beta " ..GAME_VERSION, 84, 1, 10)
	-- void merchants
	sspr(88, 104, 40, 16, 24, 20, 80, 32)
	-- hide enemy ship
	rectfill(24, 20, 39, 36, 0)
	-- black hole
	sspr(64, 72, 16, 16, 48, 55, 32, 32)
	-- small planet
	sspr(small_planets[current_small_planet][1], small_planets[current_small_planet][2], 16, 16, 96, 22, 16, 16)

	print("check out", 3, 59, 1)
	print("check out", 4, 60, 10)
	print("the", 15, 67, 1)
	print("the", 16, 68, 10)
	print("pdf manual", 1, 75, 2)
	print("pdf manual", 2, 76, 10)

	p = 0
	if animation_counter > 10 then
		p = 1
	end

	sspr(48, 8, 8, 16, 69, 41, 8, 16)
	sspr(32, 112, 16, 16, 5, 4-p, 32, 32)
	
	if wait_after_titlescreen or #pl_ship_shots > 0 then
		print("prepare!", 48, 103, 10)	
	else
		print("press ❎ to play", 32, 103+p, 10)
		if save_game_exists() then
			print("press 🅾️ to load your last save", 2, 112-p, 12)
		end
	end

	print("github/scatenix/void-merchants", 3, 121, 2)
	print("github/scatenix/void-merchants", 4, 122, 10)
end



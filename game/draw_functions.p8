__lua__3
-- draw functions

function draw_explosions()
	for exp in all(explosions) do
		spr(exp[3], exp[1], exp[2])
		if animation_counter == 7 or animation_counter == 14 or animation_counter == 21 then
			exp[3] += 1
			if exp[3] >= 144 then
				del(explosions, exp)
			end
		end
	end
end

function draw_hitmarkers()
	for mark in all(hitmarkers) do
		local col = 0
		if mark[4] == 1 then
			col = 11
		elseif mark[4] == 2 then
			col = 12
		elseif mark[4] == 3 then
			col = 8
		end

		pset(mark[1]-1, mark[2], col)
		pset(mark[1]+1, mark[2], col)
		pset(mark[1], mark[2]-1, col)
		pset(mark[1], mark[2]+1, col)

		mark[3] += 1
		if mark[3] >= 5 then
			del(hitmarkers, mark)
		end
	end
end

function draw_textbox(text1, text2, text3, text4, in_void)
	-- corners
	spr(137, 0, -1, 1, 1, true)
	spr(137, 0, 40, 1, 1, true, true)
	spr(137, 120, -1, 1, 1)
	spr(137, 120, 40, 1, 1, false, true)

	-- horizontal bars
	for i = 2, 122, 8 do
		spr(136, i, -1)
		spr(136, i, 40, 1, 1, false, true)
	end

	-- vertical bars
	for i = 8, 32, 8 do
		spr(138, -1, i)
		spr(138, 126, i)
	end

	-- extra dots for vertical bars
	line(0, 7, 0, 7, 6)
	line(127, 7, 127, 7, 6)

	-- printing all 4 lines of text
	print(conv_text_1, 5, 9, 7)
	print(conv_text_2, 5, 17, 7)
	print(conv_text_3, 5, 25, 7)
	print(conv_text_4, 5, 33, 7)

	-- drawing "waiting for input" indicator
	local waiting_indicator_woble = 0
	if animation_counter > 10 then
		waiting_indicator_woble = 1
	end
	line(120, 35+waiting_indicator_woble, 123, 35+waiting_indicator_woble, 9)
	line(120, 36+waiting_indicator_woble, 123, 36+waiting_indicator_woble, 9)
	line(121, 37+waiting_indicator_woble, 122, 37+waiting_indicator_woble, 9)

	if conv_partner == 1 then
		-- drawing planet
		sspr(planets[current_planet][1], planets[current_planet][2], 32, 32, 42, 44, 64, 64)
		
		-- drawing space-ship windows
		sspr(16, 112, 16, 16, 0, 44, 32, 32)
		sspr(16, 112, 16, 16, 0, 74, 32, 32)
		sspr(16, 112, 16, 16, 32, 44, 32, 32)
		sspr(16, 112, 16, 16, 32, 74, 32, 32)
		sspr(16, 112, 16, 16, 64, 44, 32, 32)
		sspr(16, 112, 16, 16, 64, 74, 32, 32)
		sspr(16, 112, 16, 16, 96, 44, 32, 32)
		sspr(16, 112, 16, 16, 96, 74, 32, 32)

		sspr(0, 112, 16, 8, 0, 106, 32, 16)
		sspr(0, 112, 16, 8, 32, 106, 32, 16)
		sspr(0, 112, 16, 8, 64, 106, 32, 16)
		sspr(0, 112, 16, 8, 96, 106, 32, 16)
		
		-- drawing trader
		sspr(char_trader, 8, 8, 8, 88, 48, 8*4, 8*4)
		sspr(char_trader, 16, 8, 8, 88, 80, 8*4, 8*4)

		-- drawing main character
		sspr(char_player, 8, 8, 8, 8, 48, 8*4, 8*4)
		sspr(char_player, 16, 8, 8, 8, 80, 8*4, 8*4)
	elseif conv_partner == 2 then
		-- drawing main character
		sspr(char_player, 8, 8, 8, 8, 48, 8*4, 8*4)
		sspr(char_player, 16, 8, 8, 8, 80, 8*4, 8*4)

		sspr(small_planets[7][1], small_planets[7][2], 16, 16, 59, 44, 32, 32)
		sspr(char_void, 8, 8, 8, 88, 48, 8*4, 8*4)
		sspr(char_void, 16, 8, 8, 88, 80, 8*4, 8*4)
		
		-- draw cloud
		if medium_animation_counter <= 25 then
			sspr(48, 112, 24, 8, -9, 102, 72, 24)
			sspr(48, 112, 24, 8, 54, 102, 72, 24)
		else
			sspr(48, 120, 24, 8, -9, 102, 72, 24)
			sspr(48, 120, 24, 8, 54, 102, 72, 24)
		end

		draw_void_noise()
	end

	-- fix transparent main character mouth
	rect(20, 74, 23, 75, 0)
end

-- Draws some randomly appearing particles with the same colors as the black hole
function draw_void_noise()
	-- TODO: implement
	-- min y = 44

	--rect(50,50,51,51,1)
	--rect(53,53,54,54,2)
	--rect(57,57,58,58,12)
	--rect(60,60,61,61,13)
	--rect(64,64,65,65,14)
end

function draw_battle_stats()
	spr(137, 0, 100, 1, 1, true)
	spr(137, 0, 126, 1, 1, true, true)
	spr(137, 120, 100, 1, 1)
	spr(137, 120, 126, 1, 1, false, true)

	for i = 2, 122, 8 do
		spr(136, i, 100)
		spr(136, i, 126, 1, 1, false, true)
	end

	for i = 107, 123, 8 do
		spr(138, -1, i)
		spr(138, 126, i)
	end

	print("hp:", 5, 110, 7)
	print(get_ship_life_as_string(), 16, 110, 8)

	print("sh:", 42, 110, 7)
	print(get_ship_shields_as_string(), 53, 110, 12)

	print("dr:", 79, 110, 7)
	print(get_drone_life_as_string(), 90, 110, 8)

	local draw_drone_shield_offset_y
	if drone_life < 4 then
		draw_drone_shield_offset_y = 90 + drone_life * 8
	elseif drone_life < 10 then
		draw_drone_shield_offset_y = 98
	else
		draw_drone_shield_offset_y = 102
	end

	if drone_shields > 0 then
		print("+", draw_drone_shield_offset_y, 110, 12)
		print(drone_shields, draw_drone_shield_offset_y + 4, 110, 12)
	end

	print("stg:", 5, 119, 7)
	print(get_free_storage(), 20, 119, 13)

	print("dmg:", 29, 119, 7)
	print(pl_ship_damage+drone_damage, 44, 119, 9)
	
	print("wps:", 53, 119, 7)
	print(pl_ship_weapons+drone_weapons, 68, 119, 5)
	
	print("sp:", 77, 119, 7)
	print(pl_ship_speed, 88, 119, 11)
	
	print("sts:", 101, 119, 7)
	print(pl_ship_shot_speed, 116, 119, 14)
end

function draw_ship()
	if jump_wobble and animation_counter % 3 == 0 then
		local x_rand = flr(rnd(3)) - 1;
		local y_rand = flr(rnd(3)) - 1;
		spr(pl_ship_sprite, pl_ship_x + x_rand, pl_ship_y + y_rand)
		spr(249 + pl_ship_shields, pl_ship_x + 9 + x_rand, pl_ship_y + y_rand, 1, 1, true, false)
	else
		spr(pl_ship_sprite, pl_ship_x, pl_ship_y)
		spr(249 + pl_ship_shields, pl_ship_x + 9, pl_ship_y, 1, 1, true, false)
	end
end

function draw_friendly_shots(array, col)
	for shot in all(array) do
	line(shot[1], shot[2], shot[1]+1, shot[2], col)
	shot[1] += 1 * pl_ship_shot_speed * 1.3
		if shot[1] > 150 then
		del(pl_ship_shots, shot)
		del(drone_shots, shot)
		end
	end
end

function draw_enemy_shots()
	for shot in all(enemy_shots) do
		line(shot[1], shot[2], shot[1]+1, shot[2], 8)
		shot[1] -= 1 * shot[3] * 1
		if shot[1] < 1 then
			del(enemy_shots, shot)
		end
	end
end

function draw_drone()
	if jump_wobble and animation_counter % 3 == 0 then
		local x_rand = flr(rnd(3)) - 1;
		local y_rand = flr(rnd(3)) - 1;
		spr(drone_sprite, drone_x + x_rand, drone_y + y_rand)
		spr(249 + drone_shields, drone_x + 9 + x_rand, drone_y + y_rand, 1, 1, true, false)
	else
		spr(drone_sprite, drone_x, drone_y)
		spr(249 + drone_shields, drone_x + 9, drone_y, 1, 1, true, false)
	end
end

function draw_enemies()
	for enemy in all(enemies) do
		spr(enemy[5], enemy[1], enemy[2])
		spr(249 + enemy[8], enemy[1] - 9, enemy[2])
		enemy[1] -= 0.1 * enemy[11]

		if enemy[1] - 4 > 127 then
			spr(199, 119, enemy[2])
		end
		
		-- this if is for the enemy_wobble
		if enemy[16] >= 20 / enemy[11] then
			if enemy[2] > 0 and enemy[2] < enemies_max_y + 1 and not enemy_colides_enemy(enemy[1], enemy[2], enemy[17]) then
				enemy[2] += enemy[14]
				if enemy[15] + enemy[13] <= enemy[2] or enemy[15] - enemy[13] >= enemy[2] then
					enemy[14] = enemy[14] - enemy[14] * 2
				end
			else
				enemy[14] = enemy[14] - enemy[14] * 2
				enemy[2] += enemy[14]
			end
			enemy[16] = 0
		end
		enemy[16] += 1

		if show_enemy_life and enemy[7] < calc_enemy_life(enemy[12]) then
			life_line = enemy[7] * 8 / calc_enemy_life(enemy[12])
			line(enemy[1], enemy[2]-2, enemy[1]+8, enemy[2]-2, 2)
			line(enemy[1], enemy[2]-2, enemy[1]+life_line, enemy[2]-2, 8)
		end

		if enemy[1] <= -7 then
			del(enemies, enemy)
		end
	end
end
-->8

__lua__3
-- draw functions
noise_dots = {}

function draw_money_pickups()
	for mp in all(money_pickups) do
		x = mid(0, mp[2] - 15, 90)
		y = flr(mp[3]) + 3
		spr(credit[1], x - 3, y - 2)
		print(" +" ..mp[1], x, y, 3)
		if mp[4] <= 0 then
			del(money_pickups, mp)
		end
		mp[3] -= 0.1
		mp[4] -= 1
	end
end

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
	-- fill background of textbox with a black rect
	rectfill(0, 0, 128, 44, 0)

	-- fill background underneath the trading station interior with a black rect
	rectfill(0, 112, 128, 128, 0)

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
	if animation_counter > 10 then
		print("🅾️", 118, 33, 13)
	else
		print("🅾️", 118, 34, 13)
	end

	if conv_partner == 1 then
		-- drawing planet
		sspr(planets[current_planet][1], planets[current_planet][2], 32, 32, 42, 44, 64, 64)
		
		-- drawing space-ship windows
		sspr(0, 112, 32, 16, 0, 44, 64, 32)
		sspr(0, 112, 32, 16, 0, 74, 64, 32)
		sspr(0, 112, 32, 16, 64, 44, 64, 32)
		sspr(0, 112, 32, 16, 64, 74, 64, 32)

		sspr(96, 120, 32, 8, 0, 106, 64, 16)
		sspr(96, 120, 32, 8, 64, 106, 64, 16)
		
		-- drawing trader
		sspr(64, 8, 8, 16, 88, 48, 8*4, 16*4)

		-- drawing main character
		sspr(56, 8, 8, 16, 8, 48, 8*4, 16*4)
	elseif conv_partner == 2 then
		-- draw black hole ground
		sspr(48, 112, 16, 16, 0, 96, 128, 32)

		-- drawing main character
		sspr(56, 8, 8, 16, 8, 48, 8*4, 16*4)

		sspr(small_planets[7][1], small_planets[7][2], 16, 16, 59, 44, 32, 32)

		-- drawing void creature
		sspr(48, 8, 8, 16, 88, 48, 8*4, 16*4)

		draw_void_noise()
	end

	-- fix transparent main character mouth
	rectfill(20, 72, 23, 75, 0)
end

function draw_void_noise()
	for dot in all(noise_dots) do
		rect(dot[1], dot[2], dot[1] + 1, dot[2] + 1 , dot[3])
	end
end

-- Draws some randomly appearing particles with the same colors as the black hole
function generate_void_noise(x1, y1, wx2, wy2, amount)
	local colors = {1, 2, 12, 13, 14}
	if animation_counter == 1 then
		noise_dots = {}
		for i=1, amount do
			local x = flr(rnd(wx2)) + x1
			local y = flr(rnd(wy2)) + y1
			local color = colors[flr(rnd(5)) + 1]
			add(noise_dots, {x, y, color})
		end
	end
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

	print("hp:", 4, 110, 7)
	print(" " .. pl_ship_life, 12, 110, 8)

	print("sh:", 38, 110, 7)
	print(" " .. pl_ship_shields, 46, 110, 12)

	local draw_drone_shield_offset_y
	if drone_life < 10 then
		draw_drone_shield_offset_y = 84
	else
		draw_drone_shield_offset_y = 88
	end

	if drone_life > 0 then
		print("dr:", 68, 110, 7)
		print(" " .. drone_life, 76, 110, 8)
		print("+" .. drone_shields, draw_drone_shield_offset_y, 110, 12)
	end

	print("stg:", 98, 110, 7)
	print(get_free_storage(), 114, 110, 13)

	print("dmg:", 4, 119, 7)
	print(pl_ship_damage .. "+" .. drone_damage, 20, 119, 9)

	print("wps:", 38, 119, 7)
	print(pl_ship_weapons .. "+" .. drone_weapons, 54, 119, 5)
	
	print("sp:", 68, 119, 7)
	print(format_one_decimal(pl_ship_speed), 80, 119, 11)
	
	print("sts:", 98, 119, 7)
	print(format_one_decimal(pl_ship_shot_speed), 114, 119, 14)
end

function format_one_decimal(n)
    return tostr(flr(n * 10 + 0.5) / 10)
end

function draw_ship()
	if jump_wobble and animation_counter % 3 == 0 then
		local x_rand = flr(rnd(3)) - 1;
		local y_rand = flr(rnd(3)) - 1;
		spr(pl_ship_sprite, pl_ship_x + x_rand, pl_ship_y + y_rand)
		spr(192 + pl_ship_shields, pl_ship_x + 9 + x_rand, pl_ship_y + y_rand, 1, 1, true, false)
	else
		spr(pl_ship_sprite, pl_ship_x, pl_ship_y)
		spr(192 + pl_ship_shields, pl_ship_x + 9, pl_ship_y, 1, 1, true, false)
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
		spr(192 + drone_shields, drone_x + 9 + x_rand, drone_y + y_rand, 1, 1, true, false)
	else
		spr(drone_sprite, drone_x, drone_y)
		spr(192 + drone_shields, drone_x + 9, drone_y, 1, 1, true, false)
	end
end

function draw_enemies()
	for enemy in all(enemies) do
		spr(enemy[5], enemy[1], enemy[2])
		spr(192 + enemy[8], enemy[1] - 9, enemy[2])
		
		if not prevent_enemy_moving_on_x then
			enemy[1] -= 0.1 * enemy[11]
		end

		if enemy[1] - 4 > 127 then
			spr(199, 119, enemy[2])
		end
		
		-- this is for the enemy_wobble
		if enemy[16] >= 20 / enemy[11] then
			if enemy[2] > 0 and enemy[2] < 96 + 1 and not enemy_colides_enemy(enemy[1], enemy[2], enemy[17]) then
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

		if enemy[7] < calc_enemy_life(enemy[12]) and not prevent_enemy_moving_on_x then
			life_line = enemy[7] * 8 / calc_enemy_life(enemy[12])
			line(enemy[1], max(enemy[2]-2, 1), enemy[1]+8, max(enemy[2]-2, 1), 2)
			line(enemy[1], max(enemy[2]-2, 1), enemy[1]+life_line, max(enemy[2]-2, 1), 8)
		end

		if enemy[1] <= -7 then
			del(enemies, enemy)
		end
	end
end
-->8

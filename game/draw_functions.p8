__lua__3
-- draw functions

function draw_explosions()
	for exp in all(explosions) do
		spr(exp[3], exp[1], exp[2])
		if adhs_counter == 7 or adhs_counter == 14 or adhs_counter == 21 then
		 exp[3] += 1
		 if exp[3] >= 144 then
		 	del(explosions, exp)
		 end
	 end
	end
end

function draw_hitmarkers()
	for mark in all(hitmarkers) do
		col = 0
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

	if drone_life < 4 then
		drplusy = 90 + drone_life * 8
	elseif drone_life < 10 then
		drplusy = 98
	else
		drplusy = 102
	end

	print("+", drplusy, 110, 12)
	print(drone_shields, drplusy + 4, 110, 12)

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
	spr(pl_ship_sprite, pl_ship_x, pl_ship_y)
 spr(249 + pl_ship_shields, pl_ship_x + 9, pl_ship_y, 1, 1, true, false)
end

function draw_friendly_shots(array, col)
	for shot in all(array) do
	line(shot[1], shot[2], shot[1]+1, shot[2], col)
	shot[1] += 1 * pl_ship_shot_speed * 1.3
		if shot[1] > 127 then
		del(pl_ship_shots, shot)
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
	spr(drone_sprite, drone_x, drone_y)
	spr(249 + drone_shields, drone_x + 9, drone_y, 1, 1, true, false)
end

function draw_enemys()
 for enemy in all(enemys) do
		spr(enemy[5], enemy[1], enemy[2])
		spr(249 + enemy[8], enemy[1] - 9, enemy[2])
		enemy[1] -= 0.1 * enemy[11]

		if enemy[1] - 4 > 127 then
			spr(199, 119, enemy[2])
		end
		
		-- this if is for the enemy_wobble
		if enemy[16] >= 20 / enemy[11] then
			if enemy[2] > 0 and enemy[2] < enemys_max_y + 1 and not enemy_colides_enemy(enemy[1], enemy[2], enemy[17]) then
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
		
		if show_enemy_life then
			life_line = enemy[7] * 8 / calc_enemy_life(enemy[12])
			line(enemy[1], enemy[2]-2, enemy[1]+8, enemy[2]-2, 2)
			line(enemy[1], enemy[2]-2, enemy[1]+life_line, enemy[2]-2, 8)
		end
		
		if enemy[1] <= -7 then
			del(enemys, enemy)
		end
 end
end
-->8

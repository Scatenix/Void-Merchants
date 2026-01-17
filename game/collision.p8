__lua__8
--collision

-- shots --> [1] = x; [2] = y
function friendly_shots_hit_enemy(shot_array, damage_from, ship1_drone2)
	for shot in all(shot_array) do
		for enemy in all(enemies) do
			local hit_x
			if enemy[8] > 0 then
				hit_x = shot[1] + 5 >= enemy[1] and shot[1] <= enemy[1] + 7
			else
				hit_x = shot[1] + 2 >= enemy[1] and shot[1] <= enemy[1] + 7
			end -- upper ship part _and_ lower ship part
			local hit_y = shot[2] >= enemy[2] + enemy[3] and shot[2] < enemy[2] + enemy[4] + enemy[3] + 1
			
			if hit_x and hit_y then
				if enemy[8] > 0 then
					enemy[8] -= 1
					sfx(3)
				else
					enemy[7] -= damage_from
					sfx(3)
				end
				if flr(enemy[7]) <= 0 then
					add(explosions, {enemy[1], enemy[2], 139})
					sfx(0, 0)
					enemy_drop_item(enemy)

					if not titlescreen_mode then
						pickup_money(max(5,level))
					end
					
					del(enemies, enemy)
				end

				add(hitmarkers, {shot[1] + rnd(6), shot[2], 0, ship1_drone2})
				del(shot_array, shot)
			end
		end
	end
end

function enemy_shots_hit_friendly(posx, posy, htbx_skip_pxl, htbx_width, player1_drone2)
	if player1_drone2 == 1 or (player1_drone2 == 2 and drone_tier > 0) then
		for shot in all(enemy_shots) do
			local hit_x
			if player1_drone2 == 1 and pl_ship_shields > 0 or player1_drone2 == 2 and drone_shields > 0 then
				hit_x = shot[1] - 11 <= posx and shot[1] >= posx
			else
				hit_x = shot[1] - 8 <= posx and shot[1] >= posx
			end
			local hit_y = shot[2] > posy - 1 + htbx_skip_pxl and shot[2] < posy + htbx_width + htbx_skip_pxl
			
			if hit_x and hit_y then
				local life = 0
				if player1_drone2 == 1 then
					if pl_ship_shields > 0 then
					pl_ship_shields -= 1
					else
					pl_ship_life -= shot[4]
					end
					life = pl_ship_life
				elseif player1_drone2 == 2 then
					if drone_shields > 0 then
						drone_shields -= 1
					else
						drone_life -= shot[4]
					end
					life = drone_life
				end
				sfx(7)
				
				if flr(life) <= 0 then
					sfx(1)
					if player1_drone2 == 1 then
							death_mode = true
							add(explosions, {56, 90, 139})
							battle_mode = false
							travel_after_battle_mode = false
							pl_ship_shot_speed_buff_time = 0
							pl_ship_speed_buff_time = 0
							speed_buff_timer()
							shot_speed_buff_timer()
					elseif player1_drone2 == 2 then
						kill_drone()
					end
				end

				add(hitmarkers, {shot[1] - rnd(5), shot[2], 0, 3})
				del(enemy_shots, shot)
			end
		end
	end
end

function enemy_colides_enemy(posx, posy, id)
	for enemy in all(enemies) do
		if id != enemy[17] then
			hity = enemy[2] - 8 < posy and enemy[2] + 8 > posy
			hitx = enemy[1] - 8 < posx and enemy[1] + 8 > posx
			if hity and hitx then
		  		return true
		 end
		end
	end
	return false
end

function floating_items_colides_player()
	local hit_x_drone = false
	local hit_y_drone = false

	for item in all(floating_items) do
		local hit_x_ship = item[1] <= pl_ship_x+8 and item[1] >= pl_ship_x or item[1]+8 <= pl_ship_x+8 and item[1]+8 >= pl_ship_x
		local hit_y_ship = item[2] <= pl_ship_y+8 and item[2] >= pl_ship_y or item[2]+8 <= pl_ship_y+8 and item[2]+8 >= pl_ship_y

		local hit_x_drone, hit_y_drone
		if drone_available then
			hit_x_drone = item[1] <= drone_x+drone_hitbox_width and item[1] >= drone_x or item[1]+8 <= drone_x+drone_hitbox_width and item[1]+8 >= drone_x
			hit_y_drone = item[2] <= drone_y+drone_hitbox_width and item[2] >= drone_y or item[2]+8 <= drone_y+drone_hitbox_width and item[2]+8 >= drone_y
		end

		if hit_x_ship and hit_y_ship or hit_x_drone and hit_y_drone then
			interpret_item(item)
		end
	end
end

-->8

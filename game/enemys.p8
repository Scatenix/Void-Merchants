__lua__7
-- enemys

enemys_max_y = 0
enemys = {}
enemy_shots = {}
enemy_shot_cooldown = 0

function add_enemy(lvl)
	y = flr(rnd(enemys_max_y))
	x = 127
	htbx = get_enemy_htbx_skp_pxl_width(lvl)
	htbx_skp_pxl = htbx[1]
	htbx_wdth = htbx[2]
	
	while enemy_colides_enemy(x, y, -1) do
		x += 12
	end
	
	enemy = {}
	--posx
	enemy[1] = x
	--posy
	enemy[2] = y
	--	h_sk_px
	enemy[3] = htbx_skp_pxl 
	-- h_width
	enemy[4] = htbx_wdth 
	-- sprite
	enemy[5] = 199 + lvl
	-- damage
	enemy[6] = lvl + 1
	-- life
	enemy[7] = calc_enemy_life(lvl)
	-- shields
	enemy[8] = flr(5.1 * lvl * 0.1 - 1) + 1
	if enemy[8] > 5 then
		enemy[8] = 5
	end
	-- weapons
	enemy[9] = flr(lvl / 5) + 1
	-- shot_speed
	enemy[10] = flr(lvl / 5) * 0.7 + 1
	-- speed
	enemy[11] = flr(lvl / 5) * 0.7 + 1
	-- value
	enemy[12] = lvl
	--wobble
	enemy[13] = flr(lvl / 5) + 1
	--wobble state (1;-1)
	enemy[14] = 1
	-- original y
	enemy[15] = enemy[2]
	--wobble counter
	enemy[16] = 0
	--id
	enemy[17] = #enemys+1
	
	add(enemys, enemy)
end

function calc_enemy_life(lvl)
	return lvl * 2 + 1
end

function get_enemy_htbx_skp_pxl_width(lvl)
	if tier == 1 or 3 or 11 then
 	return {0, 7}
 elseif tier == 2 or 8 or 9 or 10 or 12 or 14 or 20 then
 	return {0, 8}
 elseif tier == 4 or 5 or 6 then
 	return {2, 5}
 elseif tier == 7 or 13 or 15 or 16 or 17 or 19 then
 	return {1, 7}
 elseif tier == 18 then
 	return {1, 6}
	end
end

function enemy_shoot()
	if enemy_shot_cooldown == 6 or enemy_shot_cooldown == 12 or enemy_shot_cooldown == 18 then
		for enemy in all(enemys) do
	
			shot_mask = get_shot_mask(enemy[9])
	
			if play_sfx == true then
				sfx(5)
			end
	
			for shm in all(shot_mask) do
				if shm != -1 then
					shot = {enemy[1] -3, enemy[2] + shm, enemy[10], enemy[6]}
					add(enemy_shots, shot)
				end
			end
		end
	end
	if enemy_shot_cooldown == 44 then
		enemy_shot_cooldown = 0
	end
	enemy_shot_cooldown += 1
end

function enemy_drop_item(enemy)
	add_floating_item(speed_buff, enemy[1], enemy[2])
end

-->8

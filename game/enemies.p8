__lua__7
-- enemies

enemies_max_y = 0
enemies = {}
min_enemies_on_level = 0
enemy_shots = {}
enemy_shot_cooldown = 0
prevent_enemy_moving_on_x = false

-- max level 20
-- try_avoid_placing_behind: Try to not place an enemy behind another enemy.
--							 Places behind anyways if not avoidable because of to many enemies.
function add_enemy(lvl, try_avoid_placing_behind)
	if show_battle_stats == true then
		enemies_max_y = 96
	else
		enemies_max_y = 119
	end

	local y = flr(rnd(enemies_max_y))
	local x = 127
	local htbx = get_enemy_htbx_skp_pxl_width(lvl)
	local htbx_skp_pxl = htbx[1]
	local htbx_wdth = htbx[2]
	
	-- This counts how often we already tried to unsucessfully place an enemy
	-- If we tried more then 10 times, just place it behind an enemy
	-- Without this, the game can freeze in an infinite loop, because it is not able to find a place for an enemy
	local placement_tries = 0
	while enemy_colides_enemy(x, y, -1) do
		if placement_tries > 10 then
			add_enemy(lvl, false)
			return
		elseif try_avoid_placing_behind then
			placement_tries += 1
			y += 12
			if y > enemies_max_y then
				y = 3
			end
		else
			x += 12
		end
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
	enemy[10] = 1 + 0.1 * lvl--flr(lvl / 5) * 0.7 + 1
	-- speed
	enemy[11] = flr(lvl / 5) * 0.7 + 1
	-- value
	enemy[12] = lvl
	-- wobble
	enemy[13] = flr(lvl / 5) + 1
	-- wobble state (1;-1)
	enemy[14] = 1
	-- original y
	enemy[15] = enemy[2]
	-- wobble counter
	enemy[16] = 0
	-- id
	enemy[17] = #enemies+1
	-- shot_pattern (array with vals between 1 and 60)
	-- tells number of shots in one shot cycle, which lasts 60 frames and on which frame they are shot
	enemy[18] = get_shot_pattern(lvl)
	
	add(enemies, enemy)
end

function get_shot_pattern(lvl)
	if lvl >= 1 and lvl <= 3 then
		return {1}
	elseif lvl >= 4 and lvl <= 6 then
		return {6, 12, 36}
	elseif lvl >= 7 and lvl <= 9 then
		return {6, 14, 36, 44}
	elseif lvl >= 10 and lvl <= 12 then
		return {4, 8, 12, 16, 20}
	elseif lvl >= 13 and lvl <= 15 then
		return {2, 4, 6, 32, 34, 36}
	elseif lvl >= 16 and lvl <= 18 then
		return {2, 4, 6, 8, 24, 26, 28, 30}
	elseif lvl >= 19 and lvl <= 20 then
		return {2, 4, 6, 24, 26, 28, 48, 50, 52}
	end
end

function spawn_enemy_wave()
	if min_enemies_on_level > 0 then
		sfx(22)
		-- have always at least 2 enemies with up to 4 more (random). 1 more enemy ever 5 levels
		local enemy_number_this_wave = 2 + flr(rnd(4)) + flr(level * 0.2)
		min_enemies_on_level -= enemy_number_this_wave

		for i = 0, enemy_number_this_wave, 1 do
			local enemy_level = max(1, flr(rnd(5)) + (level - 4))
			add_enemy(enemy_level, true)
		end
	end
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
	if enemy_shot_cooldown == 60 then
		enemy_shot_cooldown = 0
	end
	enemy_shot_cooldown += 1

	--if enemy_shot_cooldown == 6 or enemy_shot_cooldown == 12 or enemy_shot_cooldown == 18 then
	
	for enemy in all(enemies) do
		if contains(enemy_shot_cooldown, enemy[18]) then
			local shot_mask = get_shot_mask(enemy[9])
	
			if play_sfx == true then
				sfx(5)
			end
	
			for shm in all(shot_mask) do
				if shm != -1 then
					local shot = {enemy[1] -3, enemy[2] + shm, enemy[10], enemy[6]}
					add(enemy_shots, shot)
				end
			end
		end
	end
end

function contains(val, arr)
	for i=1,#arr do
	  if arr[i] == val then
		return true
	  end
	end
	return false
  end

function enemy_drop_item(enemy)
	local droped_item = drop_item()
	if droped_item > 0 then
		add_floating_item(droped_item, enemy[1], enemy[2])
	end
end

-->8

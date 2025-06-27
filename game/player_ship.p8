__lua__5
-- player ship

pl_ship_x=50
pl_ship_y=20
pl_ship_hitbox_skip_pixel = 0 -- from mid
pl_ship_hitbox_width = 0 -- from mid
pl_ship_sprite=0
pl_ship_damage=0
pl_ship_base_damage=0
pl_ship_life=0
pl_ship_max_life=0
pl_ship_shields=0
pl_ship_weapons=0
pl_ship_shot_speed=0 -- actual projectile speed and fire rate
pl_ship_speed=0 -- float
pl_ship_default_shot_speed=0
pl_ship_default_speed=0
pl_ship_storage=0
pl_ship_shots = {}
pl_ship_shot_timer = 0
pl_ship_can_shoot = false
pl_ship_tier = 1
pl_ship_speed_buff_time = 0
pl_ship_shot_speed_buff_time = 0
pl_ship_damage_upgrades = 0

function set_pl_ship(tier)
	pl_ship_sprite = tier - 1
	htbx = get_ship_htbx_skp_pxl_width(tier)
	pl_ship_hitbox_skip_pixel = htbx[1]
	pl_ship_hitbox_width = htbx[2]
	pl_ship_damage = 2 * tier + pl_ship_damage_upgrades
	pl_ship_base_damage = 2 * tier
	pl_ship_life = 5 * tier
	pl_ship_max_life = pl_ship_life
	pl_ship_shields = flr(tier/2)
	pl_ship_max_shield = pl_ship_shields
	-- pl_ship_weapons=flr(tier/4)+1
	pl_ship_shot_speed = tier / 3 + 1
	pl_ship_speed = 1 + tier * 0.2
	pl_ship_default_shot_speed = tier / 3 + 1
	pl_ship_default_speed = 1 + tier * 0.2
	pl_ship_storage = tier * 2 + 4
	max_pl_weapons = min(tier, 5)
end

function get_ship_htbx_skp_pxl_width(tier)
	if tier == 1 then
		return {2, 5}
	elseif tier == 2 or tier == 3 then
		return {1, 7}
	elseif tier == 4 or tier == 5 or tier == 6 then
		return {0, 8}
	end
end

-- shotmask is used to tell at which positions shots come out of the enemy. -1 means no shot
function get_shot_mask(weapons)
	local shot_mask = {}
	
	if weapons == 0 then
		shot_mask = {-1, -1, -1, -1, -1}
	end
	if weapons == 1 then
		shot_mask = {-1, -1, 4, -1, -1}
	end
		if weapons == 2 then
		shot_mask = {-1, -1, 3, 5, -1}
	end
	if weapons == 3 then
		shot_mask = {-1, 2, 4, 6, -1}
	end
	if weapons == 4 then
		shot_mask = {1, 3, 5, 7, -1}
	end
	if weapons == 5 then
		shot_mask = {0, 2, 4, 6, 8}
	end
	return shot_mask
end

function ship_and_drone_shoot()
	local shot_freq = 10 / pl_ship_shot_speed
	if shot_freq <= pl_ship_shot_timer then
		pl_ship_can_shoot = true
	end

	if btn(5) and pl_ship_can_shoot == true then
		local shot_mask = get_shot_mask(pl_ship_weapons)
		if play_sfx == true then
			sfx(5)
		end

		for shm in all(shot_mask) do
			if shm != -1 then
				local shot = {pl_ship_x + 10, pl_ship_y + shm}
				add(pl_ship_shots, shot)
			end
		end

		if drone_available then
			local shot_mask = get_shot_mask(drone_weapons)
			for shm in all(shot_mask) do
				if shm != -1 then
					local shot = {drone_x + 10, drone_y + shm -2}
					add(drone_shots, shot)
				end
			end
		end

		pl_ship_can_shoot = false
		pl_ship_shot_timer = 0
	end

	if pl_ship_can_shoot == false then
		pl_ship_shot_timer += 1
	end
end

function ship_ctrl()
	if btn(0) then -- left
		pl_ship_x = max(pl_ship_x - pl_ship_speed, x_left_boundry)
	end
	if btn(1) then -- right
		-- - 5 because of the shield that a player can have
		pl_ship_x = min(pl_ship_x + pl_ship_speed, x_right_boundry - 5)
	end
	if btn(2) then -- up
		pl_ship_y = max(pl_ship_y - pl_ship_speed, y_up_boundry)
	end
	if btn(3) then -- down
		pl_ship_y = min(pl_ship_y + pl_ship_speed, y_down_boundry)
	end
end

function get_ship_life_as_string()
	local ship_life = ""
	if pl_ship_life < 4 then
		for i = 1, pl_ship_life do
			ship_life = ship_life .. "♥"
		end
	else
		ship_life = " " .. pl_ship_life
	end
	return ship_life
end

function get_ship_shields_as_string()
	local ship_shields = ""
	if pl_ship_shields < 4 then
		for i = 1, pl_ship_shields do
			ship_shields = ship_shields .. "◆"
		end
	else
		ship_shields = " " .. pl_ship_shields
	end
	return ship_shields
end

function ship_burner_calculation()
	if animation_counter == 10 or animation_counter == 20 then
	 	pl_ship_sprite += 16
	end
	if pl_ship_sprite > 37 then
	 	pl_ship_sprite -= 3*16
	end
end

-->8

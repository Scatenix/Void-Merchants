pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- main
-- shift + h = ♥

function _init()
	clear_screen()
	
	if show_battle_stats == true then
		stars_max_y = 105
		enemys_max_y = 96
 	else
		stars_max_y = 127
		enemys_max_y = 119
 	end
	
	add_enemy(1)
	add_enemy(1)
	
	
	set_pl_ship(6)
 	add_pl_drone(4)
end



-------------------------------



function _update()
	ship_ctrl()
	drone_ctrl()
	ship_and_drone_shoot()
	friendly_shots_hit_enemy(pl_ship_shots, pl_ship_damage, 1)
	friendly_shots_hit_enemy(drone_shots, drone_damage, 2)
	enemy_shots_hit_friendly(pl_ship_x, pl_ship_y, pl_ship_hitbox_skip_pixle, pl_ship_hitbox_width, 1)
	enemy_shots_hit_friendly(drone_x, drone_y, drone_hitbox_skip_pixle, drone_hitbox_width, 2)
	enemy_shoot()
	ship_burner_calculation()
	calculate_floating_items_drift()
	
	-- adhs_counter -> used for animations
	if adhs_counter == 21 then
 		adhs_counter = 0
 	end
	adhs_counter+=1
end




-------------------------------




function _draw()
	clear_screen()

	----- debug section
	
--	debug_coords()
--	info(enemy_shot_cooldown)
	
	----------------
	
	if death_screen == true then
		print("you died :c\nwanna play again? :)\nrestart the game!", 30, 30, 10)
	else
		if initial_draw == true then
			init_passing_stars()
			initial_draw = false
		end
		
		draw_passing_stars()
		
		if show_battle_stats then
		 	draw_battle_stats()
		end
	
		draw_floating_items()
		draw_enemys()
		draw_ship()
		draw_drone()
	
		draw_friendly_shots(pl_ship_shots, 11)
		draw_friendly_shots(drone_shots, 12)
		draw_enemy_shots()
		
		draw_hitmarkers()
		draw_explosions()
	end
end


-->8
-- global variables

show_battle_stats = true
adhs_counter = 0
x_left_boundry = 5
x_right_boundry = 120
y_up_boundry = 0
y_down_boundry = 97

initial_draw = true
death_screen = false
play_sfx = true


-- arrays

explosions = {}
hitmarkers = {}
-->8
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
-- player itself

pl_credits = 0
pl_items_stored = {}
reputation = 0


-- perks

show_enemy_life = true
-->8
-- player ships

pl_ship_x=50
pl_ship_y=20
pl_ship_hitbox_skip_pixle = 0 -- from mid
pl_ship_hitbox_width = 0 -- from mid
pl_ship_sprite=0
pl_ship_damage=0
pl_ship_life=0
pl_ship_shields=0--sris 250-255
pl_ship_weapons=0
pl_ship_shot_speed=0 -- actual projectile speed and fire rate
pl_ship_speed=0 -- float
pl_ship_storage=0 -- in tons
pl_ship_shots = {}
pl_ship_items_stored = {}
pl_ship_shot_timer = 0
pl_ship_can_shoot = false
pl_ship_tier = 1

function set_pl_ship(tier)
	pl_ship_sprite=tier-1
	htbx = get_ship_htbx_skp_pxl_width(tier)
	pl_ship_hitbox_skip_pixle = htbx[1]
	pl_ship_hitbox_width = htbx[2]
	pl_ship_damage=2*tier
	pl_ship_life=3*tier
	pl_ship_shields=flr(tier/2)
	pl_ship_weapons=flr(tier/4)+1
	pl_ship_shot_speed=tier/3+1
	pl_ship_speed=1
	pl_ship_storage=7
	pl_ship_tier=tier
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

function get_shot_mask(weapons)
	shot_mask = {}
	
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
 shot_freq = 10 / pl_ship_shot_speed
	if shot_freq <= pl_ship_shot_timer then
		pl_ship_can_shoot = true
	end
	
	if btn(4) and pl_ship_can_shoot == true then
		shot_mask = get_shot_mask(pl_ship_weapons)
		if play_sfx == true then
			sfx(5)
		end
		
		for shm in all(shot_mask) do
			if shm != -1 then
				shot = {pl_ship_x + 10, pl_ship_y + shm}
				add(pl_ship_shots, shot)
			end
		end
		
		shot_mask = get_shot_mask(drone_weapons)
		for shm in all(shot_mask) do
			if shm != -1 then
				shot = {drone_x + 10, drone_y + shm -2}
				add(drone_shots, shot)
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
	sp = pl_ship_speed * 1
	
	if btn(0) then
		if pl_ship_x > x_left_boundry then
			pl_ship_x -= sp
		end
	end
	if btn(1) then
	 	if pl_ship_x < x_right_boundry then
	 		pl_ship_x += sp
		end
	end
	if btn(2) then
	 	if pl_ship_y > y_up_boundry then
		 	pl_ship_y -= sp
		end
	end
	if btn(3) then
	 	if pl_ship_y < y_down_boundry then
			pl_ship_y += sp
		end
	end
end

-- with drone storage
function get_free_storage()
 	return pl_ship_storage + drone_storage - #pl_ship_items_stored
end

function get_ship_life_as_string()
	ship_life = ""
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
	ship_shields = ""
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
	if adhs_counter == 10 or adhs_counter == 20 then
	 	pl_ship_sprite += 16
	end
	if pl_ship_sprite > 37 then
	 	pl_ship_sprite -= 3*16
	end
end

-->8
-- player drones

drone_x = 0
drone_y = 0
drone_offset_y = 0
drone_offset_x = 0
drone_hitbox_skip_pixle = 8
drone_hitbox_width = 0
drone_sprite = 48
drone_damage = 00
drone_weapons = 0
drone_life = 0
drone_shields = 0
drone_storage = 0
drone_shots = {}
drone_available = false

function add_pl_drone(tier)
	-- get attack drone
	if tier >= 0 and tier <= 6 then
 	drone_sprite = 48 + tier
 	htbx = get_drone_htbx_skp_pxl_width(tier)
  drone_hitbox_skip_pixle = htbx[1]
  drone_hitbox_width = htbx[2]
  drone_damage = flr(10 * tier * 0.1) + 1
 	drone_life = flr(20 * tier * 0.1) + 1
 	drone_shields = flr(10 * tier * 0.1 - 1) + 1
 	drone_storage = flr(10 * tier * 0.1) + 1
 	drone_available = true
 	drone_weapons = flr(1 * tier * 0.5) + 1

	-- get storage drone
 elseif tier >= 7 and tier <= 9 then
 	drone_sprite = 6 + tier - 7
 	htbx = get_drone_htbx_skp_pxl_width(tier)
  drone_hitbox_skip_pixle = htbx[1]
  drone_hitbox_width = htbx[2]
  drone_damage = 0
 	drone_life = flr(20 * (tier-3) * 0.1) + 1
 	drone_shields = flr(10 * (tier-6.5) * 0.2) + 1
 	drone_storage = flr(10 * tier * 0.1) + 1
 	drone_available = true
 	drone_weapons = 0
	end
end

function get_drone_htbx_skp_pxl_width(tier)
 if tier == 1 then
 	return {3, 3}
 elseif tier == 2 or tier == 3 or tier == 5 then
  return {0, 7}
 elseif tier == 4 then
  return {2, 5}
 elseif tier == 6 then
  return {1, 7}
 elseif tier == 7 then
  return {4, 4}
 elseif tier == 8 then
  return {0, 8}
 elseif tier == 9 then
  return {1, 6}
 end
end

function drone_ctrl()
	if pl_ship_y < 7 then
		drone_offset_y = 2 * (pl_ship_y - 7)
		drone_offset_x = flr(drone_offset_y / 1.5)
		if drone_offset_x < -5 then
	  		drone_offset_x = 0 - pl_ship_y * 2
		end
	else
		drone_offset_y = 0
		drone_offset_x = 0
	end
	
	drone_x = pl_ship_x-5+drone_offset_x
	
	if adhs_counter <= 10 then
		drone_y = pl_ship_y-8 - drone_offset_y
	elseif adhs_counter > 10 then
	 	drone_y = pl_ship_y-9 - drone_offset_y
	end
end

function get_drone_life_as_string()
	 drone_life_string = ""
	 	if drone_life < 4 then
			for i = 1, drone_life do
				drone_life_string = drone_life_string .. "♥"
			end
		else
		 	drone_life_string = " " .. drone_life
		end
	return drone_life_string
end

function kill_drone()
	drone_hitbox_skip_pixle = 8
	drone_hitbox_width = 0
	drone_sprite = 48
	drone_damage = 00
	drone_weapons = 0
	drone_life = 0
	drone_shields = 0
	drone_storage = 0
	drone_shots = {}
	drone_available = false
	
	if #pl_ship_items_stored > pl_ship_storage then
		for i = pl_ship_storage+1, #pl_ship_items_stored do
			temp_item = pl_ship_items_stored[i]
			del(pl_ship_items_stored, temp_item)
			--todo drop-item into void
		end
	end
end
-->8
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
--collision

-- shots --> [1] = x; [2] = y
function friendly_shots_hit_enemy(shot_array, damage_from, ship1_drone2)
	info("htbx")
	for shot in all(shot_array) do
		for enemy in all(enemys) do
			if enemy[7] > 0 then
				hit_x = shot[1] + 5 >= enemy[1] and shot[1] <= enemy[1] + 7
			else
				hit_x = shot[1] + 2 >= enemy[1] and shot[1] <= enemy[1] + 7
			end -- upper ship part _and_ lower ship part
			hit_y = shot[2] >= enemy[2] + enemy[3] and shot[2] < enemy[2] + enemy[4] + enemy[3] + 1
			
			if hit_x and hit_y then
				if enemy[8] > 0 then
				 enemy[8] -= 1
				else
					enemy[7] -= damage_from
				end
				if flr(enemy[7]) <= 0 then
					create_explosion(enemy[1], enemy[2])
					enemy_drop_item(enemy)
					del(enemys, enemy)
				end

				create_hitmarker(shot[1], shot[2], ship1_drone2)
				del(shot_array, shot)
			end
		end
	end
end

function enemy_shots_hit_friendly(posx, posy, htbx_skip_pxl, htbx_width, player1_drone2)
	for shot in all(enemy_shots) do
		if player1_drone2 == 1 and pl_ship_shields > 0 or player1_drone2 == 2 and drone_shields > 0 then
			hit_x = shot[1] - 11 <= posx and shot[1] >= posx
		else
			hit_x = shot[1] - 8 <= posx and shot[1] >= posx
		end
		hit_y = shot[2] > posy - 1 + htbx_skip_pxl and shot[2] < posy + htbx_width + htbx_skip_pxl
		
		if hit_x and hit_y then
			life = 0
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
				create_explosion(posx, posy)
				if player1_drone2 == 1 then
						death_screen = true
						clear_screen()
						gc_all()
				elseif player1_drone2 == 2 then
					kill_drone()
				end
			end

			create_hitmarker(shot[1], shot[2], 3)
			del(enemy_shots, shot)
		end
	end
end

-- probably not needed anymore... just keeping for safety
--function new_enemy_colides_enemy(posx, posy)
--	for enemy in all(enemys) do
--		hity = enemy[2] - 8 < posy and enemy[2] + 8 > posy
--		hitx = enemy[1] - 8 < posx and enemy[1] + 8 > posx
--		if hity and hitx then
----		if hitx then
--	  		return true
--	 end
--	end
--	return false
--end

function enemy_colides_enemy(posx, posy, id)
	for enemy in all(enemys) do
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


-->8
-- items

floating_items = {}

speed_buff = 184
shot_speed_buff = 185

function add_floating_item(item_type, x, y)
	item = {}
	item[1] = x
	item[2] = y
	-- sprite and id
	item[3] = item_type
	-- item wobble
	item[4] = 1
	add(floating_items, item) 
end

function calculate_floating_items_drift()
	for item in all(floating_items) do
		item[1] -= 0.25
		item[2] -= item[4]
		item[4] = item[4]*-1
	end
end

function draw_floating_items()
	for item in all(floating_items) do
		spr(item[3], item[1], item[2])	
	end
end
-->8
-- common

function clear_screen()
 	rectfill(0, 0, 128, 128, 0)
end

function create_explosion(posx, posy)
	add(explosions, {posx, posy, 139})
	sfx(0)
end

function create_hitmarker(posx, posy, ship_drone_enemy)
	add(hitmarkers, {posx, posy, 0, ship_drone_enemy})
end
-->8
-- stars

star_speed_multiplier = 1
max_stars = 25
min_star_speed = 1
max_star_speed = 5
stars_counter_threshold = 2
stars_counter = 0
stars_max_y = 0
stars = {}

function init_passing_stars()
	for i = 1, max_stars do
		star = {flr(rnd(127)), flr(rnd(stars_max_y)), flr(rnd(max_star_speed-min_star_speed) + min_star_speed) * star_speed_multiplier} 
		add(stars, star)
	end
end

function draw_passing_stars()
	if star_speed_multiplier > 0 then
	 	stars_start_x = 127
	else
	 	stars_start_x = 0
	end

 	if stars_counter >= stars_counter_threshold and max_stars > #stars then
		star = {stars_start_x, flr(rnd(stars_max_y)), flr(rnd(max_star_speed-min_star_speed) + min_star_speed) * star_speed_multiplier}
		add(stars, star)
  		stars_counter = 0
 	end
 	stars_counter += 1
 
	for star in all(stars) do
		-- draw star
		line(star[1], star[2], star[1], star[2], 7)
		star[1] -= star[3]
		if star[1] < 0 or star[1] > 127 then
			del(stars, star)
		end
	end
end

function all_stars_speed_ctrl(speed_multiplier)
	for star in all(stars) do
		star[3] = star[3] * speed_multiplier
	end
	star_speed_multiplier = speed_multiplier
end
-->8
-- garbage collection

function gc_all()
explosions = nil
hitmarkers = nil
pl_ship_shots = nil
pl_ship_items_stored = nil
drone_shots = nil
enemys = nil
enemy_shots = nil
stars = nil
pl_items_stored = nil
end
-->8
-- data_ops

-- call once at _init
function init_data_ops()
	cartdata("void_merchants_4e40baa22f0e407277e79304514550b9e952ccef")
end

function save_game()
	dset(index, variable_value)
end

function load_game()
	variable = dget(index)
end
-->8
-- debug infos

function debug_coords()
	line(10,70,10,70,8)
	print("point x:10 y:70", 10,60,8)
	
	print("ship_x:" .. pl_ship_x, 10, 10, 7)
	print("ship_y:" .. pl_ship_y, 10, 20, 7)
	print("drone_x:" .. drone_x, 10, 30, 12)
	print("drone_y:" .. drone_y, 10, 40, 12)
end

function info(text, val, plusy)
		if plusy == nil then
			plusy = 0
		end
		if val == nil then
			val = ""
		end
 	print(text .. ": " .. val, 5, 5+plusy, 7)
end
__gfx__
0000000000000000000000005500dd000055500005d55dd00000000000566c000000000000000000000000000000aaaaaaaa0000000000000000033333300000
00000000005d000000050000005d00d0005ddd000a66655d0000000000d55600005dd55000000000000000000aaaaaaaaaaaaaa0000000000003333333333000
00dd00000dddd00005d55000a055500d95566660a99855dc0000000098dd550005d66cc0000000000000000aaaaaaaaaaaaaaaaaa00000000033333333333300
05556d00a95566d0a98d56500985c600a985cccd0d566dcc00000000000d00000d66ddd000000000000000aaaaaaaaaaaaaaaaaaaa0000000333ccc333333330
a985ccd0085ddccd0a98dcc50985c600a985cccd0d566dcc000566c0000566c005d66d500000000000000aaaaaaaa999aaaaaaaaaaa00000033ccc3333333330
05556d00a95566d0a98d5650a055500d95566660a99855dc000d5560000d5560985dd550000000000000aaaaaaa99aaaaa999aaaaaaa000033ccc333333c3333
00dd00000dddd00005d55000005d00d0005ddd000a66655d089dd550098dd55000d5500000000000000aaaaaaa9aaaaaaaaaaaa99aaaa00033cc3333333ccc33
00000000005d0000000500005500dd000055500005d55dd00000d0000000d000000000000000000000aaa9aaaaaaaaaaaa9aaaaa99aaaa003333333333333c33
0000000000000000000000005500dd000055500005d55dd00006d00000555d00008220000000000000aaa9aa99aaaaaaaa99aaaaaaaaaa0033333c3333333333
00000000005d000000050000005d00d0005ddd000966655d006ddd005055d60008882200000000000aaaaaaa9aaaaaaaaaa9aaaaaaaaaaa03333333333333333
00dd00000dddd00005d550009055500da5566660a88955dc06d111d0550444660eeee400000000000aaaaaaaaaaaaaaa9aa9aa9aaaaaaaa0333333333c333333
05556d009a5566d0a98d56500985c6009895cccd0d566dcc061818d00555dddd88882220000000000aaaaaaaaaaaaaaa9aaaaa999aaaaaa00333333ccc333330
9895ccd0095ddccd0aa9dcc50895c600a985cccd0d566dcc06d111d004bb9bb00bbb330000000000aaaaaaaaaaa9999a9aaaaaaa9aaaaaaa033333cccc333330
05556d00a85566d0989d5650a055500da5566660998955dc06dd11dd8444990006db6d0000000000aaaaaaaaaaa9aaaa9aaaaaaaaaaaaaaa0033333333333300
00dd00000dddd00005d55000005d00d0005ddd000a66655d066dddd1249000a09dd3dd4000000000aaaa9aaaaaaaaaaaaaaa99aaaaa99aaa0003333333333000
00000000005d0000000500005500dd000055500005d55dd00066dd112299aaa00994440000000000aaaa9aa99aaaaaaaaaaa9aaaaaaa9aaa0000033333300000
0000000000000000000000005500dd000055500005d55dd00606d111022288800077600000000000aaaaaaaa9aaaaaaaaaaa9aaaaaaa9aaa00000cccccc00000
00000000005d000000050000005d00d0005ddd000966655d006dd111002888000288820000000000aaaaaaaa99aaaa9aaaaaaaaaaaaaaaaa000cccccccccc000
00dd00000dddd00005d550009055500d95566660989955dc0060d110000880007826886000000000aaaaaaaaa99aaa999aaaaaaaaaaaaaaa00cccccccccccc00
05556d00895566d0a89d56500995c600a895cccd0d566dcc06000d11000000007222220600000000aaaa9aaaaa99aaaaaaaaaaaaaaaaaaaa0cccccccccccccc0
aa85ccd0095ddccd09a9dcc50895c6009995cccd0d566dcc006010100000000007292206000000000aaa9aaaaaaaaaaaaaaa9aaaaaaaaaa00cccccccccccccc0
05556d00a85566d0a98d5650a055500da5566660a88955dc000001000000000002755206000000000aaa9aaaaaaaaaaaaa999aaa9aaaaaa0cccccccccccccccc
00dd00000dddd00005d55000005d00d0005ddd000966655d000d00000000000000252055000000000aaa99aaaaaaaaaaa99aaaa99aaaaaa0cccccccaa66ccccc
00000000005d0000000500005500dd000055500005d55dd00600000000000000002920050000000000aaaaaaaaaaaaaaaaaaaa99aaaaaa00cccccca55a6acccc
0000000000000000000dd000000dd0000000000000d000000000000000000000000000000000000000aaaaaaa9aaaaaaaaaaaa9aaaaaaa00ccccccca66666acc
000000000000000000950000009500000000000005dd000000000050000000000000000000000000000aaaaaaa9aaaaaaaaaaaaaaaaaa000cccccccccca6cccc
0000000000000000000dd000000dd00000000d00a95000d000005d000000000000000000000000000000aaaaaaa99aaaaaaa9999aaaa0000cccccccccccccccc
0000000000000dd000000000000000dd00005dd005dd05dd0a5ddddd00000000000000000000000000000aaaaaaa9aaaaaa9aaaaaaa000000cccccccccccccc0
000000000000950000000dd00dd00950000a950000d0a95000955600000000000000000000000000000000aaaaaaaaaaaaaaaaaaaa0000000cccccccccccccc0
0000000000000dd000009500950000dd00005dd0000005dd0a5ddddd0000000000000000000000000000000aaaaaaaaaaaaaaaaaa000000000cccccccccccc00
000000000000000000000dd00dd0000000000d00000000d000005d00000000000000000000000000000000000aaaaaaaaaaaaaa000000000000cccccccccc000
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000aaaaaaaa00000000000000000cccccc00000
000000000000bbbbbbbb000000000000000000000000c777777c00000000000000000000000099999999000000000000000000000000dddddddd000000000000
000000000bbbbbbbbbbbbbb000000000000000000ccccc77777cccc00000000000000000099999999999999000000000000000000dddddddddddddd000000000
0000000bbbbbb33bbbbbbbbbb00000000000000ccccccccc7cccccccc0000000000000055999999999999999900000000000000dddddddddddddddddd0000000
000000bbbbb3bbbbbbbbbbbbbb000000000000cccccccccccccccccccc00000000000095555999999999999999000000000000dddddddddddddddddddd000000
00000bbbbb33bbbb333333bbbbb0000000000cccccccccccccccccccccc000000000099999559999999999999990000000000d6dddddddddd666ddddddd00000
0000bbbbbbbbbbbbbbbbbbbbbbbb00000000cccccccc33333333333ccccc00000000999999999999999955599999000000006666dddddddd6666dddddddd0000
000bbbbbbbbbbbbb33bbbbbbbbbbb000000ccccccc3333333333333333ccc000000999999999999999995555999990000006666ddddddddd66666dddddddd000
00bbbbbbbbbbb333bbbbbbbbbbbbbb0000cccccccc3333333333333333333c000099999999999999999995555999990000d6666ddddddd6666666ddddddddd00
00bbbbbbbbbbbbbbbbbbbbbbbbbbbb0000c333ccc33333333333333333333c000099999999999999999999955599990000666ddddddd666dddd6dddddddddd00
0bbbbb3333bbbbbbbbbb33bbbbb3bbb00c33333cc33333333333333333333cc0099999999999999999999999955999900ddddddddd666dddddddddddddddddd0
0bbbbbbbb333bbbbbbbbbbbbbbb33bb00c33333cc33333333333333333333cc0099999999555999999999999999999900dddddddd6666dddddddddddddddddd0
0bbbbbbbbbbbbbbbbbbbbbb33bbb3bb00c33333ccc3333333333333333333c30095999999555999999999999999999900ddddddd66666dddddddddddddddddd0
bbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbcc3333cccc33cc3cc333333333333c3c95599999555999999999999999999999dddddddd66666ddddddddd666ddddddd
bbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbcc3333ccccccc33ccc333333333333cc55999995559999999999999999999999ddddddddd6666ddddddddd6666dddddd
bbbbbb3bbbbbbbbbb3bbbbbbb3bbbbbbcc3333ccccc3ccccc3c333333333cccc59999995599999999955999999995999ddddddddd6666dddddddddd666dddddd
bbbbbb3bbbbbbb3333bbbbbbbbbbbbbbccc3cccccc333333cc3c333333cccccc99999995599999955555999999995999ddddddddd6666ddddddddddd666ddddd
bbbbbb3bbb3bbbbbbbbbbbbbbbbbbbbbccc3ccccc333333333cccccccccccccc99999995999999955559999999955999ddddddddd66666dddddddddd6666dddd
bbbbbb3bb33bbbbbbbbbbb33bbbbbbbbcc333cccc333333333cccccccccccccc99999999999999999559999999959999ddddddd666666666ddddddddd666dddd
bbbbbb3bb3bbbbbbbbbbb33bbbbbbbbbccc33cccc3333333333ccccccccccccc99999999999999999999999999959999dddddddd666666666ddddddddd66dddd
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcc333ccccccc3333333ccccccccccccc99999999999999999999999999559999ddddddddddd6666666dddddddd66dddd
0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00c3333ccccccc333333cccc33cccccc0099999999999999999999999555999900dddddddddddd66666ddddddddddddd0
0bbbbbbbbbbbbbbbbbbbbbbb33bbbbb00cc3333cccccc33333cccc33333cccc0099999999999555999999995599999900dddddddddddddd6666dddddddddddd0
0bbbbbbbbbb33bbbbbbbbbb33bbbbbb00cc3333ccccccc3333c3cc333333ccc0099999999999555599999999999999900ddddddddddddddd6666ddddddddddd0
00bbbbbbbbbb33bbbbbbbb33bbbbbb0000cc333ccccccc3333c3cc333333cc000099999999995555599999999999990000ddddddd6dddddddddddddddddddd00
00bbbbbb3bbbb333bbbbbbbbbbbbbb0000ccccccccccccc33cccccc33333cc000099599999999995599999999999990000dddddd66666ddddddddddd6ddddd00
000bbbbb33bbbbbbbbbbbbbbbbbbb000000cccccccccccccccccccc3333cc00000095999999999955599999999999000000ddddd666666ddddddddd66dddd000
0000bbbbb3bbbbbbbbbbbbbbbbbb00000000cccccccccccccccccccccccc0000000059999999999995559999999900000000ddddddddddddddddd6666ddd0000
00000bbbbbbbbbbbbb3bbbbbbbb0000000000ccccccccccc777cccccccc000000000099999999999999999999990000000000ddddddddddddd666666ddd00000
000000bbbbbbbbbb333bbbbbbb000000000000cccccccc777777cccccc00000000000099999999999999999999000000000000ddddddddddd666666ddd000000
0000000bbbbbbbbbbbbbbbbbb00000000000000ccccc777777777cccc0000000000000099999999999999999900000000000000dddddddddd6ddddddd0000000
000000000bbbbbbbbbbbbbb000000000000000000cc77777777777c00000000000000000099999999999999000000000000000000dddddddddddddd000000000
000000000000bbbbbbbb0000000000000000000000007777777700000000000000000000000099999999000000000000000000000000dddddddd000000000000
000000000000222222220000000000000000066666600000000001111110000000000000000000000600000000000000000a000000aa0aa00999099009000080
0000000002222222222222200000000000066666666660000001111d11111000000000000000000006000000000a000000a9a0a00a99a9a0a988889a00980098
000000022222222222888222200000000066666666666600001111dd1111110000000000000000000600000000a99a000a999a00a999989a9898888989000000
000000222222222222288888220000000666656665566660011111111d1111100000000000000000060000000a9899a00a98889aa98889899888898000000009
00000222222222222222288882200000066656565665666001111d111dddd11000000000000000000600000000a989a000a989900a99889a0888888900000000
0000222222222222222222888822000066666566566566661111d1111111111100000000000000000600000000099a000a9999a0a99898909089898a99000098
000222222222e222222222288822200066666666655666651111d11111111111666666660000006606000000000aa000000aaa00aa99999a9a98889980900009
002222222eeee22222eeee228882220066666666666666561111111111dd111100000000000000060600000000000000000000000aaa09a009a909a009009080
00222222eeee22222eeee22288822200666666666655666511ddd1111dd11d110020100d00e0200c000000000000000000000000000000000000000000000000
0222222eeee22222eeee22228882222066665566656656661111111111111d11d0000222222000000d5555d00000000000000000000800000000000000000000
022222eeee22222eeee2222228822220666566566566566611111dd111111111000222eeee222010056666500006000000999000008780000000000000000000
022222eee222222eee22222222222220066566566655666001111d11111111102022eeecceee220e056655500055600000908800088878000000000000000000
22222eee222222eee222222222222222066655666666666001111d11111d1110002eeccccccee200055566500005560000a00800008880000000000000000000
22222eee222222eee2222222882222220066666656666600001111111ddd1100022ecc1111cce220056666500056060000aaa800000800000000000000000000
22222eee222222ee22222288882222820006666565666000000111111111100002eec110011cee200d5555d00000000000000000000000000000000000000000
222222ee222222ee22222888822222880000066656600000000001111110000002ecc100001cce21000000000000000000000000000000000000000000000000
2222222e222222e22222888822222228000005555550000000000eeeeee0000002ecc100001cce20000000000000000000000000000000000000000000000000
22882222222222e222288822222222280005556555555000000ee8eeeeeee000d2eec110011cee20000000000000000000000000000000000000000000000000
2288822222222222222882222ee22222005556565555550000eee88eeeeeee00022ecc1111cce22e008080000009a000000670000005d0000000000000000000
2228822222222222222222222ee2222205555565555555500eeeee8888eeeee0002eeccccccee200087888000099aa00006677000055dd000000000000000000
022888888888222222222222eee2222005555555555555500eeeeeeee88eeee00022eeecceee220208888800009aaa0000677700005ddd000000000000000000
02222888888222222222222eee2222205555555555666555eeeeee8eee8eeeeee00222eeee22200000888000000aa00000077000000dd0000000000000000000
02222222222222222222222ee22222205566555556555655eeee8e8eee8ee8ee02000222222000c0000800000000000000000000000000000000000000000000
002222222222222222222eeee22222005655655556555655eee88e88ee8ee8ee000100e0c00d2000000000000000000000000000000000000000000000000000
002222222eeeeee222eeeeee222222005655655556555655eee8eee8eeeee8ee000000000000e200000000000000000000000000000000000000000000000000
00022222222eeeeeeeeeeee2222220005566555555666555ee88eee88eeeeeee03b3b00000000e20000000000000000000000000000000000000000000000000
00002222222eeeeeeeeeee22222200005555555655555555ee8eeeee8eeee8ee003b3b000000e2000a0a77000001c00000049000000000000000000000000000
0000022222222222222222222220000005555565655555500eeeeeeeee8888e00003b3b00e2000000a9aaa7000111c0000444900000000000000000000000000
0000002222222222222222222200000005555556555555500eee8eeee88eeee0003b3b0000e2000009499aa000111c0000444900000000000000000000000000
000000022222222222222ee220000000005555555555550000ee888eeeeeee0003b3b0000e200e20090999000001100000044000000000000000000000000000
000000000222222222eeee80000000000005555555555000000eeeeeeeeee00000000000000000e2000000000000000000000000000000000000000000000000
00000000000022222888000000000000000005555550000000000eeeeee000000000000000000e20000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000006000000006000000dd0000000000000000000000000000000000000000d000
00000000000000000000000000000000000000000000000000000000000000000859a00000859a000859a000000000000000000000000000000050000005d000
0000000000000000000000000000000000000000000000000000000000008800006000000006000000dd00000005500000055000000d00000005550000ddd500
0000000000000000000000000000000000000000000000000000000000008980000000000000060000000000005500000055550055dd9a000055dd9a085d559a
0000000000000000000000000000000000000000000000000000000000008998000060000000859a0000dd0008dd59a00880d9a00885d000088d0000085d559a
0000000000000000000000000000000000000000000000000000000000008980000859a006000600000859a0005500000055550055dd9a000055dd9a00ddd500
000000000000000000000000000000000000000000000000000000000000880000006000859a00000000dd000005500000055000000d0000000555000005d000
0000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000050000000d000
0dd00000000dd0000020000000020000002200000000200000000000000000000000000000000000000000000000022000000000000000000000000000000000
d00dd00000ddddd00859a00000859a000829a0000002d0000000500025500000022500000000d2220055dd0000dd222000000000000000000000000000000000
00000d00055d5500002000000002000000220000002d550000022050025200000022500000222200022550000225d20000000000000000000000000000000000
08dd559a856659a000000000000002000000000008d259a00225550002552000000225000885dd9a825d29a08822559a00000000000000000000000000000000
08dd559a856659a0000020000000859a0000220008d259a0885229a0882259a00000829a0885dd9a88229a008822559a00000000000000000000000000000000
00000d00055d5500000859a002000200000829a0002d550002255500025520000002250000222200825d29a00225d20000000000000000000000000000000000
d00dd00000ddddd000002000859a0000000022000002d0000002205002520000002250000000d2220225500000dd222000000000000000000000000000000000
0dd00000000dd00000000000020000000000000000002000000050002550000002250000000000000055dd000000022000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000007c
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000c0000007c000007cc
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000c0000000c0000000c0000000c0000007c0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000cc0000007c000007cc0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000cc000007cc0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000c0000000c0000000c0000000c0000007c0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000c000000cc000000cc000007cc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000c0000007c
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88ee888ee88ee8e8ee88ee888ee88ee8eeee88ee888ee88888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee8eeeee8ee8eee8e8ee8eee8eeee8eee8eeee8eeeee8ee88888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8eeee88ee8eee888ee8eee888ee8eee888ee8eeeee8ee88e8e888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee8eeeee8ee8eeeee8ee8eeeee8ee8eee8e8ee8eeeee8ee88888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee8eee888ee8eeeee8ee8eee888ee8eee888ee8eeeee8ee888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888
11111e1e1e1111e11e1e1e1e1e1e1111161116161161161611111611161611611611161116161611111111111111111111111111111111111111111111111111
11111ee11ee111e11e1e1ee11e1e1111166616661161166611111666166611611661161116161666111111111111111111111111111111111111111111111111
11111e1e1e1111e11e1e1e1e1e1e1111111616161161161111111116161611611611161116161116111111111111111111111111111111111111111111111111
11111e1e1eee11e111ee1e1e1e1e1111166116161666161116661661161616661666166616661661111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111661616166616661111166616161666166116661666111111661666161111661616161116661666166611661661
1e111e1e1e1e1e1111e111e11e1e1e1e111116111616116116161111161616161616161616111616111116111616161116111616161116161161116116161616
1ee11e1e1e1e1e1111e111e11e1e1e1e111116661666116116661111166116161661161616611661111116111666161116111616161116661161116116161616
1e111e1e1e1e1e1111e111e11e1e1e1e111111161616116116111111161616161616161616111616111116111616161116111616161116161161116116161616
1e1111ee1e1e11ee11e11eee1ee11e1e111116611616166616111666166611661616161616661616166611661616166611661166166616161161166616611616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee111116661661161611661111116611661616166116661666166611111111111111111cc11ccc111111ee1eee1111166616611616116611111166
111111e11e111111161616161616161111111611161616161616116116111616111117771777111111c11c1c11111e1e1e1e1111161616161616161111111611
111111e11ee11111166616161666166611111611161616161616116116611661111111111111111111c11c1c11111e1e1ee11111166616161666166611111611
111111e11e111111161616161616111611111611161616161616116116111616111117771777111111c11c1c11111e1e1e1e1111161616161616111611111611
11111eee1e11111116161666161616611666116616611166161611611666161611111111111111111ccc1ccc11111ee11e1e1111161616661616166116661166
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111666161111111166161616661666111111661666166616661666166611111111111111111cc11c11111111111111111111111111111111111111
11111111111116161611111116111616116116161111161116161616116111611611111111711777111111c11c11111111111111111111111111111111111111
11111111111116661611111116661666116116661111166616661661116111611661111117771111111111c11ccc111111111111111111111111111111111111
11111111111116111611111111161616116116111111111616111616116111611611111111711777111111c11c1c111111111111111111111111111111111111
1111111111111611166616661661161616661611166616611611161616661161166611111111111111111ccc1ccc111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee1111166616111111116616161666166611111166166616661666166616661111171111111ccc1ccc11111eee1e1e1eee1ee11111111111111111
111111e11e11111116161611111116111616116116161111161116161616116111611611111111711111111c111c111111e11e1e1e111e1e1111111111111111
111111e11ee111111666161111111666166611611666111116661666166111611161166111111117111111cc111c111111e11eee1ee11e1e1111111111111111
111111e11e11111116111611111111161616116116111111111616111616116111611611111111711111111c111c111111e11e1e1e111e1e1111111111111111
11111eee1e111111161116661666166116161666161116661661161116161666116116661111171111111ccc111c111111e11e1e1eee1e1e1111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111666161111111166161616661666111111661666166616661666166611111111111111111ccc17171cc11c111111111111111111111111111111
111111111111161616111111161116161161161611111611161616161161116116111111111117771111111c117111c11c111111111111111111111111111111
11111111111116661611111116661666116116661111166616661661116111611661111117771111111111cc177711c11ccc1111111111111111111111111111
111111111111161116111111111616161161161111111116161116161161116116111111111117771111111c117111c11c1c1111111111111111111111111111
1111111111111611166616661661161616661611166616611611161616661161166611111111111111111ccc17171ccc1ccc1111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111661666166611111166161616661666111116111616161111711171111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116111611116111111611161611611616111116111616161117111117111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116111661116111111666166611611666111116111616161117111117111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161611116111111116161611611611111116111666161117111117111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661666116116661661161616661611166616661161166611711171111111111111111111111111111111111111
88888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111711111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111771111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111777711111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111771111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111117111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822882888222888282288222822888888888888888888888888888888888888882228222822282228882822282288222822288866688
82888828828282888888882882888282882888288882882888888888888888888888888888888888888888828282828282828828828288288282888288888888
82888828828282288888882882228222882888288882882888888888888888888888888888888888888882228222822282828828822288288222822288822288
82888828828282888888882882828282882888288882882888888888888888888888888888888888888882888882828282828828828288288882828888888888
82228222828282228888822282228222828882228882822288888888888888888888888888888888888882228882822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__sfx__
000500001f353226531e3531d65318353166531434311643123430f6430b343086230732303623043230261302313006130131300613003130230302303033030230301303013030030300302003020130201300
0010000037620266201c65015650116500e6500c6500a650086500565003650026500065000640006400064000630006300063000620006200062000610006100061000610006000060000600006000060000600
00100010307103271033710377103a71037710327102e7102675028750297501f7501f7501f7501e7501d75034100000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001d3232c333283331a3231031310313103030a303103031030310303103031030310303103030030300303003030030300303003030030300303003030030300303003030130300302003020030208300
000a0000203342032420314223041a3041b3041b30400004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002d753207031d7030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001f7511f7511f7511f7511f7511f7511f7511f750227512275122751227512275122751227512275026750267502675026750267502675026750267502475024750247502475024750247502475024750
001000002935329353293332931329303293030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344



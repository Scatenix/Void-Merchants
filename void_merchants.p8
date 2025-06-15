pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- main
-- shift + h = ♥

-- Game loop description:
-- 1st void guy talks to you
-- starting journey with lightspeed into first stage
-- after every stage: slowly fly towards random planet, trader appears
-- accel again from this planet with light speed
-- next wave slightly harder
-- repeat
-- every 10 waves, void guy appears and says something
-- final wave (21): hardest wave, void guy is final boss
-- to not overcomplicate the final fight:
--		void creature lurks in the background (draw huge face of him)
--		and occasionally moves back, outside the right screen edge and appears
--		as smaller (1:1 scale) and fights like a ship with maybe lvl 25 or something
--		If feeling fancy, occasionally spawn bombs that explode and deal damage to player if in range. (do this only if he is in the background)

-- Possible void creature dialog
--	before lvl 1:
--	after lvl 5: I see you are making progress. Very good!
-- 	after lvl 10:
-- 	after lvl 15:
--  after lvl 20, before final boss:
--			Finally you are strong enough for me to consume your strength

-- SFX
-- 0 explosion
-- 1 big explosion
-- 2 music part 1
-- 3 hit sound?
-- 4 increased shooting speed sound
-- 5 shooting sound
-- 6 collect item sound
-- 7 hit sound?
-- 8 music part 2
-- 9 speed increase sound
-- 10 life pickup
-- 11 ship upgrade
-- 12 shield increase
-- 13 prepare for jump
-- 14 starting thrusters for jump
-- 15 jump
-- 16 hyper space
-- 17 sell
-- 18 land
-- 19 hyper space thrusters
-- 20 step out of hyperspace
-- 21 buy

function _init()
	clear_screen()
	music(0)

	if show_battle_stats == true then
		stars_max_y = 105
		enemys_max_y = 96
	else
		stars_max_y = 127
		enemys_max_y = 119
	end

	current_planet = flr(rnd(6)) + 1
	current_small_planet = flr(rnd(6)) + 1

	battle_mode = false
	travel_to_battle_mode = false
	travel_after_battle_mode = false
	converstaion_mode = false
	trading_mode = true
	death_mode = false

	level = 5
	

	-- for testing:
	-- tme = time() - 10

		-- add_enemy(1)
		-- add_enemy(3)
		-- add_enemy(6)
		-- add_enemy(9)
		-- add_enemy(14)
		-- add_enemy(18)
		-- add_enemy(1)
		-- add_enemy(1)
		-- add_enemy(1)
		-- add_enemy(1)

		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)
		-- add_floating_item(cobalt, 70, 70)

		drone_tier = 5

		set_pl_ship(6)
		set_pl_drone(drone_tier)

		-- pl_ship_storage = 8
		-- drone_storage = 6

		-- pl_items_stored = {155, 154, 187, 174, 155, 155, 154, 187, 174, 155, 155, 154, 187, 174}
end



-------------------------------



function _update()
	
	if travel_after_battle_mode then
		ship_ctrl()
		drone_ctrl()
		ship_and_drone_shoot()
		ship_burner_calculation()
		calculate_floating_items_drift()
		floating_items_colides_player()
		ship_and_drone_shoot()

		if jump_to_hyperspce then
			jump_to_hyperspce_animation()
		end
		if arrive_in_hyperspace then
			arrive_in_hyperspce_animation()
		end
		if show_trader_station_far then
			trader_station_x -= 1
		end
		if show_trader_station_near then
			if not stop_trader_station_near then
				trader_station_x -= 0.5
				pl_ship_x -= 0.15
			end
		end
		travel_from_battle_animation_script()
	-- end
	elseif battle_mode then
		ship_ctrl()
		drone_ctrl()
		ship_and_drone_shoot()
		friendly_shots_hit_enemy(pl_ship_shots, pl_ship_damage, 1)
		friendly_shots_hit_enemy(drone_shots, drone_damage, 2)
		enemy_shots_hit_friendly(pl_ship_x, pl_ship_y, pl_ship_hitbox_skip_pixel, pl_ship_hitbox_width, 1)
		enemy_shots_hit_friendly(drone_x, drone_y, drone_hitbox_skip_pixel, drone_hitbox_width, 2)
		enemy_shoot()
		ship_burner_calculation()
		calculate_floating_items_drift()
		floating_items_colides_player()
		speed_buff_timer()
		shot_speed_buff_timer()

		if not travel_after_battle_mode and #enemys == 0 then
			tme = time()
			travel_after_battle_mode = true
			current_planet = flr(rnd(6)) + 1
		end
	elseif converstaion_mode then
		pause_on_text = true
		conv_partner = 1
		trader_converstaion()
	elseif trading_mode then
		drone_ctrl()
		ship_burner_calculation()

		if trading_phase == 1 or trading_phase == 5 then
			trader_station_x -= 0.5
		elseif trading_phase == 2 then
			black_hole_x -= 1
		elseif trading_phase == 4 then
			advance_textbox()
		end

		trading_script()
	end

	animation_counters()
end

function animation_counters()
	-- animation_counter -> used for animations
	if animation_counter == 21 then
		animation_counter = 0
	end
	animation_counter+=1

	-- long_animation_counter -> used for animations with longer runtime
	if long_animation_counter == 101 then
		long_animation_counter = 0
	end
	long_animation_counter+=1
end

-------------------------------

function _draw()
	clear_screen()

----- debug section

--	debug_coords()
--	info(enemy_shot_cooldown)
	-- info(pl_ship_speed)
	if pause_on_text then
		info("pause_on_text true", 10)
	else 
		info("pause_on_text false", 10)
	end
----------------

	if death_mode == true then
		print("you died :c\nwanna play again? :)\nrestart the game!", 30, 30, 10)
	elseif battle_mode then
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
	elseif converstaion_mode then
		draw_textbox()
	elseif travel_after_battle_mode then
		draw_passing_stars()
		draw_floating_items()
		draw_trader_station()
		draw_drone()
		draw_ship()
		draw_friendly_shots(pl_ship_shots, 11)
		draw_friendly_shots(drone_shots, 12)
	elseif trading_mode then
		draw_passing_stars()
		if trading_phase == 4 then
			draw_textbox()
		else
			if talk_to_void_creature then
				draw_black_hole_background()
			end
			draw_trader_station()
			draw_drone()
			draw_ship()
			if talk_to_void_creature then
				draw_black_hole_foreground()
			end
		end
	end
end
-->8
-- global variables
tme = 0 -- here to track times with time()

level = 1
show_battle_stats = true
animation_counter = 0
long_animation_counter = 0
x_left_boundry = 5
x_right_boundry = 120
y_up_boundry = 0
y_down_boundry = 97

initial_draw = true
play_sfx = true

speed_buff_time = 4.0
shot_speed_buff_time = 4.0

max_pl_dr_weapons = 5
max_drones = 6
max_pl_extra_damage = 6

battle_mode = false
travel_to_battle_mode = false
travel_after_battle_mode = false
converstaion_mode = false
trading_mode = false
death_mode = false

travel_after_battle_phase = 0
jump_wobble = false
jump_to_hyperspce = false
arrive_in_hyperspace = false
show_trader_station_far = false
show_trader_station_near = false

trading_phase = 0
talk_to_void_creature = false
skip_void = false

current_planet = 1
planets = {
	{80, 0},
	{0, 32},
	{32, 32},
	{64, 32},
	{96, 32},
	{0, 64},
}
current_small_planet = 1

-- number 7 is void creatues portal
small_planets = {
	{112, 0},
	{112, 16},
	{32, 64},
	{48, 64},
	{32, 80},
	{48, 80},
	{64, 72},
}

-- arrays

explosions = {}
hitmarkers = {}
-->8
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
	waiting_indicator_woble = 0
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
		
		sspr(char_trader, 8, 8, 8, 88, 48, 8*4, 8*4)
		sspr(char_trader, 16, 8, 8, 88, 80, 8*4, 8*4)
	elseif conv_partner == 2 then
		sspr(small_planets[7][1], small_planets[7][2], 16, 16, 59, 44, 32, 32)
		sspr(char_void, 8, 8, 8, 88, 48, 8*4, 8*4)
		sspr(char_void, 16, 8, 8, 88, 80, 8*4, 8*4)
	end

	-- drawing characters
	sspr(char_player, 8, 8, 8, 8, 48, 8*4, 8*4)
	sspr(char_player, 16, 8, 8, 8, 80, 8*4, 8*4)

	-- fix transparent main character mouth
	rect(20, 74, 23, 75, 0)
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
	if jump_wobble and animation_counter % 3 == 0 then
		x_rand = flr(rnd(3)) - 1;
		y_rand = flr(rnd(3)) - 1;
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
		x_rand = flr(rnd(3)) - 1;
		y_rand = flr(rnd(3)) - 1;
		spr(drone_sprite, drone_x + x_rand, drone_y + y_rand)
		spr(249 + drone_shields, drone_x + 9 + x_rand, drone_y + y_rand, 1, 1, true, false)
	else
		spr(drone_sprite, drone_x, drone_y)
		spr(249 + drone_shields, drone_x + 9, drone_y, 1, 1, true, false)
	end
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

function store_item(item)
	if get_free_storage() > 0 then
		sfx(6)
		add(pl_items_stored, item[3])
		del(floating_items, item)
	end
end

function drop_items_when_drone_dies()
	for i=#pl_items_stored, pl_ship_storage+1, -1 do
		add_floating_item(pl_items_stored[i], drone_x - 6*(i-pl_ship_storage-1) , drone_y - 4 + rnd(8))
		deli(pl_items_stored, i)
	end
end

function get_free_storage()
	return pl_ship_storage + drone_storage - #pl_items_stored
end

function get_max_storage()
	return pl_ship_storage + drone_storage
end
-->8
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
pl_ship_shields=0--sris 250-255
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

function set_pl_ship(tier)
	pl_ship_sprite=tier-1
	htbx = get_ship_htbx_skp_pxl_width(tier)
	pl_ship_hitbox_skip_pixel = htbx[1]
	pl_ship_hitbox_width = htbx[2]
	pl_ship_damage=2*tier
	pl_ship_base_damage=pl_ship_damage
	pl_ship_life=3*tier
	pl_ship_max_life=pl_ship_life
	pl_ship_shields=flr(tier/2)
	pl_ship_max_shield=pl_ship_shields
	pl_ship_weapons=flr(tier/4)+1
	pl_ship_shot_speed=tier/3+1
	pl_ship_speed=1+tier*0.2
	pl_ship_default_shot_speed=tier/3+1
	pl_ship_default_speed=1
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
	if btn(0) then
		if pl_ship_x > x_left_boundry then
			pl_ship_x -= pl_ship_speed
		end
	end
	if btn(1) then
		if pl_ship_x < x_right_boundry then
			pl_ship_x += pl_ship_speed
		end
	end
	if btn(2) then
		if pl_ship_y > y_up_boundry then
			pl_ship_y -= pl_ship_speed
		end
	end
	if btn(3) then
		if pl_ship_y < y_down_boundry then
			pl_ship_y += pl_ship_speed
		end
	end
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
	if animation_counter == 10 or animation_counter == 20 then
	 	pl_ship_sprite += 16
	end
	if pl_ship_sprite > 37 then
	 	pl_ship_sprite -= 3*16
	end
end

-->8
-- player drones

drone_tier = 0
drone_x = 0
drone_y = 0
drone_offset_y = 0
drone_offset_x = 0
drone_hitbox_skip_pixel = 8
drone_hitbox_width = 0
drone_sprite = 48
drone_damage = 00
drone_weapons = 0
drone_life = 0
drone_shields = 0
drone_storage = 0
drone_shots = {}
drone_available = false

function set_pl_drone(tier)
	-- get attack drone
	if tier >= 0 and tier <= 6 then
 	drone_sprite = 48 + tier
 	htbx = get_drone_htbx_skp_pxl_width(tier)
	drone_hitbox_skip_pixel = htbx[1]
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
	drone_hitbox_skip_pixel = htbx[1]
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
	
	if animation_counter <= 10 then
		drone_y = pl_ship_y-8 - drone_offset_y
	elseif animation_counter > 10 then
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
	drop_items_when_drone_dies()
	
	drone_hitbox_skip_pixel = 8
	drone_hitbox_width = 0
	drone_sprite = 48
	drone_damage = 00
	drone_weapons = 0
	drone_life = 0
	drone_shields = 0
	drone_storage = 0
	drone_shots = {}
	drone_available = false
	drone_tier = 0
end
-->8
-- enemys

enemys_max_y = 0
enemys = {}
enemy_shots = {}
enemy_shot_cooldown = 0

-- max level 20
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
	droped_item = drop_item()
	if droped_item > 0 then
		add_floating_item(droped_item, enemy[1], enemy[2])
	end
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
						death_mode = true
						battle_mode = false
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


function floating_items_colides_player()
		hit_x_drone = false
		hit_y_drone = false

	for item in all(floating_items) do
		hit_x_ship = item[1] <= pl_ship_x+8 and item[1] >= pl_ship_x or item[1]+8 <= pl_ship_x+8 and item[1]+8 >= pl_ship_x
		hit_y_ship = item[2] <= pl_ship_y+8 and item[2] >= pl_ship_y or item[2]+8 <= pl_ship_y+8 and item[2]+8 >= pl_ship_y

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
-- items

floating_items = {}

-- buff
speed_buff = 184
s_speed_buff = "speed buff"
shot_speed_buff = 185
s_shot_speed_buff = "shot speed buff"
life_up = 170
s_life_up = "life up"
shield_up = 189 -- can only be bought
s_shield_up = "shield up"

-- stat increases
attack_damage_inc = 186
s_attack_damage_inc = "damage upgrade"
drone_inc = 158
s_drone_inc = "drone upgrade"
weapons_inc = 174
s_weapons_inc = "weapon upgrade"

-- trading items
parts_crate = 154
s_parts_crate = "parts crate"
scrap = 155
s_scrap = "scrap"
void_crystal = 157
s_void_crystal = "void crystal"
gold = 171
s_gold = "gold"
copper = 188
s_copper = "copper"
platinum = 172
s_platinum = "platinum"
void_fragment = 173
s_void_fragment = "void fragment"
cobalt = 187
s_cobalt = "cobalt"

function add_floating_item(item_type, x, y)
	if item_type > 0 then
		item = {}
		item[1] = x
		item[2] = y
		-- sprite and id
		item[3] = item_type
		add(floating_items, item)
	end
end

function interpret_item(item)
	if item[3] == speed_buff then
		if pl_ship_speed_buff_time == 0 then
			sfx(9)
			pl_ship_speed *= 2
			pl_ship_speed_buff_time = time()
			del(floating_items, item)
		end
	elseif item[3] == shot_speed_buff then
		if pl_ship_shot_speed_buff_time == 0 then
			sfx(4)
			pl_ship_shot_speed *= 2
			pl_ship_shot_speed_buff_time = time()
			del(floating_items, item)
		end
	elseif item[3] == life_up then
		if pl_ship_life < pl_ship_max_life then
			sfx(10)
			pl_ship_life += 1
			del(floating_items, item)
		end
	elseif item[3] == shield_up then
		if pl_ship_shields < pl_ship_max_shield then
			sfx(12)
			pl_ship_shields += 1
			del(floating_items, item)
		end
	elseif item[3] == attack_damage_inc then
		if pl_ship_damage-pl_ship_base_damage < max_pl_extra_damage then
			sfx(11)
			pl_ship_damage += 1
			del(floating_items, item)
		else
			store_item(item)
		end
	elseif item[3] == drone_inc then
		if drone_tier < max_drones then
			sfx(11)
			drone_tier+=1
			set_pl_drone(drone_tier)
			del(floating_items, item)
		else
			store_item(item)
		end
	elseif item[3] == weapons_inc then
		if pl_ship_weapons < max_pl_dr_weapons then
			sfx(11)
			pl_ship_weapons+=1
			del(floating_items, item)
		elseif drone_weapons < max_pl_dr_weapons then
			sfx(11)
			drone_weapons+=1
			del(floating_items, item)
		else
			store_item(item)
		end
	else
		store_item(item)
	end
end

function speed_buff_timer()
	if pl_ship_speed_buff_time > 0 then
		delta = time() - pl_ship_speed_buff_time
		if delta >= speed_buff_time then
			sfx(9, -2)
			pl_ship_speed = pl_ship_default_speed
			pl_ship_speed_buff_time = 0
		end
	end
end

function shot_speed_buff_timer()
	if pl_ship_shot_speed_buff_time > 0 then
		delta = time() - pl_ship_shot_speed_buff_time
		if delta >= shot_speed_buff_time then
			sfx(4, -2)
			pl_ship_shot_speed = pl_ship_default_shot_speed
			pl_ship_shot_speed_buff_time = 0
		end
	end
end

-- calculate drop (random chance)
function drop_item()
	num = rnd(1000)
	if num >= 995 then    --0.5%
		return void_crystal
	elseif num >=985 then --1%
		return drone_inc
	elseif num >=975 then --1%
		return weapons_inc
	elseif num >=965 then --1%
		return attack_damage_inc
	elseif num >=945 then --2%
		return void_fragment
	elseif num >=920 then --2,5%
		return platinum
	elseif num >=890 then --3%
		return life_up
	elseif num >=860 then --3%
		return cobalt
	elseif num >=825 then --3,5%
		return parts_crate
	elseif num >=785 then --4%
		return gold
	elseif num >=735 then --5%
		return speed_buff
	elseif num >=675 then --6%
		return copper
	elseif num >=605 then --7%
		return shot_speed_buff
	elseif num >=500 then --10,5%
		return scrap
	else --50%
		return -1
	end
end

function calculate_floating_items_drift()
	for item in all(floating_items) do
		item[1] -= 0.25

		if long_animation_counter == 50 then
			item[2] = item[2] - 1
		elseif long_animation_counter == 100 then
			item[2] = item[2] + 1
		end

		if item[1] < 0 then
			del(floating_items, item)
		end
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
stars = {} -- 1: x 2: y 3: speed
stars_hyperspeed = false

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
		if not stars_hyperspeed then
			line(star[1], star[2], star[1], star[2], 7)
			star[1] -= star[3]
			if star[1] < 0 or star[1] > 127 then
				del(stars, star)
			end
		else
			line(star[1], star[2], 128, star[2], 7)
			star[1] -= star[3]
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
explosions = {}
hitmarkers = {}
pl_ship_shots = {}
pl_ship_items_stored = {}
drone_shots = {}
enemys = {}
enemy_shots = {}
stars = {}
pl_items_stored = {}
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

function show_stored_items()
	bla = 0
	for i in all(pl_items_stored) do
		info("i" .. bla .. ": ", i, bla)
		bla+=7
	end
end
-->8
-- characters
char_player=56
char_trader=64
char_void=48
-->8
-- jump_animations
trader_station_x = 0
trader_station_x = 0
stop_trader_station_near = false

function jump_to_hyperspce_animation()
	pl_ship_x += 20
	drone_x += 20
end

function arrive_in_hyperspce_animation()
	pl_ship_x += 2

	if pl_ship_x >= 64 then
		pl_ship_x = 64
		arrive_in_hyperspace = false
	end
end

function draw_trader_station()
	if show_trader_station_far then
		sspr(planets[current_planet][1], planets[current_planet][2], 32, 32, trader_station_x + 20, 32, 16, 16)
		spr(228, trader_station_x, 24, 2, 2)
	end
	if show_trader_station_near then
		sspr(planets[current_planet][1], planets[current_planet][2], 32, 32, trader_station_x + 24, 40, 64, 64)
		sspr(32, 112, 16, 16, trader_station_x, 24, 64, 64)
	end
end

function draw_black_hole_background()
	sspr(small_planets[7][1], small_planets[7][2], 8, 16, black_hole_x, 48, 16, 32)
end

function draw_black_hole_foreground()
	rectfill(black_hole_x+16, 48, black_hole_x+41, 80, 0)
	sspr(small_planets[7][1]+8, small_planets[7][2], 8, 16, black_hole_x+16, 48, 16, 32)
end

function travel_from_battle_animation_script()
	if travel_after_battle_phase == 11 and time() - tme >= 30 then -- 30
		-- go inside
		travel_after_battle_phase = 0
		travel_after_battle_mode = false
		converstaion_mode = true
	elseif travel_after_battle_phase == 10 and time() - tme >= 28 then -- 28
		-- land
		travel_after_battle_phase = 11
		stop_trader_station_near = true
	elseif travel_after_battle_phase == 9 and time() - tme >= 23 then -- 23
		-- approach landing from near
		travel_after_battle_phase = 10
		trader_station_x = 130
		show_trader_station_far = false
		show_trader_station_near = true
		stop_trader_station_near = false
		all_stars_speed_ctrl(0.2)
	elseif travel_after_battle_phase == 8 and time() - tme >= 17 then -- 17
		-- approach landing from far
		travel_after_battle_phase = 9
		trader_station_x = 130
		show_trader_station_far = true
		pl_ship_speed /= 0.2
		all_stars_speed_ctrl(1)
		sfx(20)
		sfx(18)
	elseif travel_after_battle_phase == 7 and time() - tme >= 16.5 then -- 16.5
		-- jump out of hyperspace
		travel_after_battle_phase = 8
		all_stars_speed_ctrl(5)
	elseif travel_after_battle_phase == 6 and time() - tme >= 11.5 then -- 11.5
		-- flying through hyperspace
		travel_after_battle_phase = 7
		stars_hyperspeed = false
		jump_to_hyperspce = false
		stars = {}
		init_passing_stars()
		all_stars_speed_ctrl(20)
		pl_ship_x = 0
		pl_ship_y = 64
		arrive_in_hyperspace = true
		sfx(16)
		sfx(19)
	elseif travel_after_battle_phase == 5 and time() - tme >= 11 then -- 11
		-- jumping into hyperspace
		travel_after_battle_phase = 6
		jump_wobble = false
		jump_to_hyperspce = true
		all_stars_speed_ctrl(50)
		sfx(15)
	elseif travel_after_battle_phase == 4 and time() - tme >= 10 then -- 10
		-- approaching hyperspace
		travel_after_battle_phase = 5
		stars_hyperspeed = true
		all_stars_speed_ctrl(50)
	elseif travel_after_battle_phase == 3 and time() - tme >= 6 then -- 6
		-- engaging thrusters
		travel_after_battle_phase = 4
		jump_wobble = true
		battle_mode = false
		show_battle_stats = false
		pl_ship_speed *= 0.2
		all_stars_speed_ctrl(0.2)
		sfx(14)
	elseif travel_after_battle_phase == 2 and time() - tme >= 2 then -- 2
		-- loading batteries
		travel_after_battle_phase = 3
		all_stars_speed_ctrl(0.4)
		sfx(13)
	elseif travel_after_battle_phase == 1 and time() - tme >= 1 then -- 1
		-- slow down stars further
		travel_after_battle_phase = 2
		all_stars_speed_ctrl(0.6)
	elseif travel_after_battle_phase == 0 and time() - tme >= 0 then -- 0
		-- slow down stars
		travel_after_battle_phase = 1
		all_stars_speed_ctrl(0.8)
	end
end
-->8
-- converstaion
pause_on_text=false
conv_partner=1 -- 1: trader, 2 void-creature
conv_text_1="hello there!"
conv_text_2=""
conv_text_3=""
conv_text_4=""

function advance_textbox()
	if pause_on_text and btn(4) then
		pause_on_text = false
	end
end

function trader_converstaion()
	if level <= 1 then
		conv_text_1 = "oh, a new face..."
		conv_text_2 = "welcome on my trading station!"
		conv_text_3 = "wanna have a look at my wares?"
		conv_text_4 = "or perhaps sell some goods?"
	elseif level < 5 then
		conv_text_1 = "see who it is again!"
		conv_text_2 = "i have restocked my wares"
		conv_text_3 = "while you were out fighting."
		conv_text_4 = "take a look!"
	elseif level < 10 then
		conv_text_1 = "nice you've maded it here!"
		conv_text_2 = "make sure you stock up on"
		conv_text_3 = "these drones."
		conv_text_4 = "it's dangerous to go alone..."
	elseif level < 15 then
		conv_text_1 = "my best customer!"
		conv_text_2 = "come in, come in!"
		conv_text_3 = "looking forward to all that"
		conv_text_4 = "gold and cobalt of yours."
	elseif level < 20 then
		conv_text_1 = "hello, fellow merchant,"
		conv_text_2 = "quite the ship you've got!'"
		conv_text_3 = "time to make it even better."
		conv_text_4 = "your credits are welcome."
	elseif level >= 20 then
		conv_text_1 = "hello my friend!"
		conv_text_2 = "you are pretty capable"
		conv_text_3 = "to make it this far."
		conv_text_4 = "prepare for the final battle!"
	end
end

function send_to_void_creature()

end

-->8
-- trading
black_hole_x = 0

function trading_script()
	if trading_phase == 5 and time() - tme >= 30 then -- 30
		all_stars_speed_ctrl(5)
		trading_phase = 6
	elseif trading_phase == 4 and not pause_on_text then
		-- send back to trading station
		skip_void = true
		trading_phase = 0
	elseif trading_phase == 3 and time() - tme >= 12  then -- 12 then
		pause_on_text = true
		trading_phase = 4
	elseif trading_phase == 2 and time() - tme >= 10.5 then -- 10.5
		trading_phase = 3
		conv_partner = 2
		conv_text_1 = "missing text"
		conv_text_4 = "I will send you back..."
	elseif trading_phase == 1 and time() - tme >= 5 then -- 5
		all_stars_speed_ctrl(1)
		trading_phase = 2
	elseif trading_phase == 0 then
		all_stars_speed_ctrl(0.2)
		-- trade
		-- ...

		show_trader_station_near = true
		pl_ship_x = 64
		pl_ship_y = 64
		-- leaving to the void creature
		if level % 5 == 0 and not skip_void then
			tme = time()
			talk_to_void_creature = true
			black_hole_x = 200
			trading_phase = 1
			trader_station_x = -24
		else
			tme = time()
			skip_void = false
			trading_phase = 5
			level += 1
			trader_station_x = -24
			talk_to_void_creature = false
		end
	end
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
00dd00000dddd00005d550009055500da5566660a88955dc06d111d055d444660eeee400000000000aaaaaaaaaaaaaaa9aa9aa9aaaaaaaa0333333333c333333
05556d009a5566d0a98d56500985c6009895cccd0d566dcc061818d00555dddd88882220000000000aaaaaaaaaaaaaaa9aaaaa999aaaaaa00333333ccc333330
9895ccd0095ddccd0aa9dcc50895c600a985cccd0d566dcc06d111d004bb9bb00bbb330000000000aaaaaaaaaaa9999a9aaaaaaa9aaaaaaa033333cccc333330
05556d00a85566d0989d5650a055500da5566660998955dc06dd11dd8444990006db6d0000000000aaaaaaaaaaa9aaaa9aaaaaaaaaaaaaaa0033333333333300
00dd00000dddd00005d55000005d00d0005ddd000a66655d066dddd1249055a09dd3dd4000000000aaaa9aaaaaaaaaaaaaaa99aaaaa99aaa0003333333333000
00000000005d0000000500005500dd000055500005d55dd00066dd112299aaa00994440000000000aaaa9aa99aaaaaaaaaaa9aaaaaaa9aaa0000033333300000
0000000000000000000000005500dd000055500005d55dd00606d111022288800077600000000000aaaaaaaa9aaaaaaaaaaa9aaaaaaa9aaa00000cccccc00000
00000000005d000000050000005d00d0005ddd000966655d006dd111092888a00288820000000000aaaaaaaa99aaaa9aaaaaaaaaaaaaaaaa000cccccccccc000
00dd00000dddd00005d550009055500d95566660989955dc0060d11090388b0a7826886000000000aaaaaaaaa99aaa999aaaaaaaaaaaaaaa00cccccccccccc00
05556d00895566d0a89d56500995c600a895cccd0d566dcc06000d1190333b097222220600000000aaaa9aaaaa99aaaaaaaaaaaaaaaaaaaa0cccccccccccccc0
aa85ccd0095ddccd09a9dcc50895c6009995cccd0d566dcc006010105533bb5507292206000000000aaa9aaaaaaaaaaaaaaa9aaaaaaaaaa00cccccccccccccc0
05556d00a85566d0a98d5650a055500da5566660a88955dc000001005049a40502755206000000000aaa9aaaaaaaaaaaaa999aaa9aaaaaa0cccccccccccccccc
00dd00000dddd00005d55000005d00d0005ddd000966655d000d000000dddd0000252055000000000aaa99aaaaaaaaaaa99aaaa99aaaaaa0cccccccaa66ccccc
00000000005d0000000500005500dd000055500005d55dd00600000000d00d00002920050000000000aaaaaaaaaaaaaaaaaaaa99aaaaaa00cccccca55a6acccc
0000000000000000000dd000000dd0000000000000d000000000000000000000000000000000000000aaaaaaa9aaaaaaaaaaaa9aaaaaaa00ccccccca66666acc
000000000000000000950000009500000000000005dd000000000050000000000000000000000000000aaaaaaa9aaaaaaaaaaaaaaaaaa000cccccccccca6cccc
0000000000000000000dd000000dd00000000d00a95000d000005d000000000000000000000000000000aaaaaaa99aaaaaaa9999aaaa0000cccccccccccccccc
0000000000000dd000000000000000dd00005dd005dd05dd0a5ddddd00000000000000000000000000000aaaaaaa9aaaaaa9aaaaaaa000000cccccccccccccc0
000000000000950000000dd00dd00950000a950000d0a95000955600000000000000000000000000000000aaaaaaaaaaaaaaaaaaaa0000000cccccccccccccc0
0000000000000dd000009500950000dd00005dd0000005dd0a5ddddd0000000000000000000000000000000aaaaaaaaaaaaaaaaaa000000000cccccccccccc00
000000000000000000000dd00dd0000000000d00000000d000005d00000000000000000000000000000000000aaaaaaaaaaaaaa000000000000cccccccccc000
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000aaaaaaaa00000000000000000cccccc00000
000000000000bbbbbbbb000000000000000000000000cccccccc00000000000000000000000099999999000000000000000000000000dddddddd000000000000
000000000bbbbbbbbbbbbbb000000000000000000cccccccccccccc00000000000000000099999999999999000000000000000000dddddddddddddd000000000
0000000bbbbbb33bbbbbbbbbb000000000000007ccccccccccccccccc0000000000000055999999999999999900000000000000dddddddddddddddddd0000000
000000bbbbb3bbbbbbbbbbbbbb000000000000777cccccccccccccccc300000000000095555999999999999999000000000000dddddddddddddddddddd000000
00000bbbbb33bbbb333333bbbbb00000000007777ccccccccccccccc333000000000099999559999999999999990000000000d6dddddddddd666ddddddd00000
0000bbbbbbbbbbbbbbbbbbbbbbbb0000000077c7cc3cc33ccccc3333333300000000999999999999999955599999000000006666dddddddd6666dddddddd0000
000bbbbbbbbbbbbb33bbbbbbbbbbb0000007c77ccc3c33c3ccc3333333333000000999999999999999995555999990000006666ddddddddd66666dddddddd000
00bbbbbbbbbbb333bbbbbbbbbbbbbb0000337c7ccccc3c3333333333333333000099999999999999999995555999990000d6666ddddddd6666666ddddddddd00
00bbbbbbbbbbbbbbbbbbbbbbbbbbbb000033cccccc3333333333333333333c000099999999999999999999955599990000666ddddddd666dddd6dddddddddd00
0bbbbb3333bbbbbbbbbb33bbbbb3bbb003333c3cc33333333333333c333cccc0099999999999999999999999955999900ddddddddd666dddddddddddddddddd0
0bbbbbbbb333bbbbbbbbbbbbbbb33bb00333333cc333333333c33333333cccc0099999999555999999999999999999900dddddddd6666dddddddddddddddddd0
0bbbbbbbbbbbbbbbbbbbbbb33bbb3bb00333333ccc33333333c3333333333c30095999999555999999999999999999900ddddddd66666dddddddddddddddddd0
bbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbc33333cccc33cc3cc333333333333c3c95599999555999999999999999999999dddddddd66666ddddddddd666ddddddd
bbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb333333ccccccc33ccc333333333333cc55999995559999999999999999999999ddddddddd6666ddddddddd6666dddddd
bbbbbb3bbbbbbbbbb3bbbbbbb3bbbbbb33333cccccc3ccccc3c333333333cccc59999995599999999955999999995999ddddddddd6666dddddddddd666dddddd
bbbbbb3bbbbbbb3333bbbbbbbbbbbbbbc33cc3cccc333333cc3c333333cccccc99999995599999955555999999995999ddddddddd6666ddddddddddd666ddddd
bbbbbb3bbb3bbbbbbbbbbbbbbbbbbbbbcc33ccccc3333333333c333333333ccc99999995999999955559999999955999ddddddddd66666dddddddddd6666dddd
bbbbbb3bb33bbbbbbbbbbb33bbbbbbbbcccc3cccc333333333ccc3333c33cccc99999999999999999559999999959999ddddddd666666666ddddddddd666dddd
bbbbbb3bb3bbbbbbbbbbb33bbbbbbbbbccccc333cc333333333ccc33ccc3cc3c99999999999999999999999999959999dddddddd666666666ddddddddd66dddd
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccc33333ccc3333333cccc3cccccccc99999999999999999999999999559999ddddddddddd6666666dddddddd66dddd
0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00ccc333333ccc333333ccccccc3cc330099999999999999999999999555999900dddddddddddd66666ddddddddddddd0
0bbbbbbbbbbbbbbbbbbbbbbb33bbbbb00cccc33333ccc33333ccccccccc3c3c0099999999999555999999995599999900dddddddddddddd6666dddddddddddd0
0bbbbbbbbbb33bbbbbbbbbb33bbbbbb00ccccc333ccccc3333c3cccccccc3cc0099999999999555599999999999999900ddddddddddddddd6666ddddddddddd0
00bbbbbbbbbb33bbbbbbbb33bbbbbb0000cccc33cccccc3333c3cccccccccc000099999999995555599999999999990000ddddddd6dddddddddddddddddddd00
00bbbbbb3bbbb333bbbbbbbbbbbbbb0000cccc33ccccccc33ccccccccccccc000099599999999995599999999999990000dddddd66666ddddddddddd6ddddd00
000bbbbb33bbbbbbbbbbbbbbbbbbb000000ccc3cccccccccccccccccccc3300000095999999999955599999999999000000ddddd666666ddddddddd66dddd000
0000bbbbb3bbbbbbbbbbbbbbbbbb00000000ccccccccccccccccccccc3330000000059999999999995559999999900000000ddddddddddddddddd6666ddd0000
00000bbbbbbbbbbbbb3bbbbbbbb0000000000ccccccccccc777ccccc333000000000099999999999999999999990000000000ddddddddddddd666666ddd00000
000000bbbbbbbbbb333bbbbbbb000000000000cccccccc777777ccccc300000000000099999999999999999999000000000000ddddddddddd666666ddd000000
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
022222eeee22222eeee2222228822220666566566566566611111dd111111111000222eeee222010056666500006000000999000008780000d666d0000000000
022222eee222222eee22222222222220066566566655666001111d11111111102022eeecceee220e05665550005560000090880008887800067dd60000000000
22222eee222222eee222222222222222066655666666666001111d11111d1110002eeccccccee200055566500005560000a00800008880000695760000000000
22222eee222222eee2222222882222220066666656666600001111111ddd1100022ecc1111cce220056666500056060000aaa80000080000067dd60000000000
22222eee222222ee22222288882222820006666565666000000111111111100002eec110011cee200d5555d00000000000000000000000000d666d0000000000
222222ee222222ee22222888822222880000066656600000000001111110000002ecc100001cce21000000000000000000000000000000000000000000000000
2222222e222222e22222888822222228000005585550000000000eeeeee0000002ecc100001cce20000000000000000000000000000000000000000000000000
22882222222222e222288822222222280005558555555000000ee8eeeeeee000d2eec110011cee20000000000000000000000000000000000000000000000000
2288822222222222222882222ee22222005558988555850000eee88eeeeeee00022ecc1111cce22e008080000009a000000670000005d0000d666d0000000000
2228822222222222222222222ee2222205555585585885500eeeee8888eeeee0002eeccccccee200087888000099aa00006677000055dd000675760000000000
022888888888222222222222eee2222005585585555885500eeeeeeee88eeee00022eeecceee220208888800009aaa0000677700005ddd00065bb60000000000
02222888888222222222222eee2222205558555555888855eeeeee8eee8eeeeee00222eeee22200000888000000aa00000077000000dd0000675760000000000
02222222222222222222222ee2222220558855555899a855eeee8e8eee8ee8ee02000222222000c0000800000000000000000000000000000d666d0000000000
002222222222222222222eeee22222005899855558999885eee88e88ee8ee8ee000100e0c00d2000000000000000000000000000000000000000000000000000
002222222eeeeee222eeeeee2222220058998855589a9888eee8eee8eeeee8ee000000000000e200000000000000000000000000000000000000000000000000
00022222222eeeeeeeeeeee2222220005588558885888855ee88eee88eeeeeee03b3b00000000e20000000000000000000000000000000000000000000000000
00002222222eeeeeeeeeee22222200005588558855585855ee8eeeee8eeee8ee003b3b000000e2000a0a77000001c0000004900006dddd600000000000000000
0000022222222222222222222220000005855589855585500eeeeeeeee8888e00003b3b00e2000000a9aaa7000111c000044490056cc77660000000000000000
0000002222222222222222222200000005555558555855500eee8eeee88eeee0003b3b0000e2000009499aa000111c000044490055cccc560000000000000000
000000022222222222222ee220000000005555855555550000ee888eeeeeee0003b3b0000e200e2009099900000110000004400005dddd500000000000000000
000000000222222222eeee80000000000005558555555000000eeeeeeeeee00000000000000000e2000000000000000000000000000000000000000000000000
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
11111111111111115566666666666655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16166166616616615660000000000665000006000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000
166166166616616167000c0000000076000606000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007700700000000077000dddd00060600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007007000000000007055555550060600000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000070c0000000000007566667775ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000007566666675555555000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000007511111115666777500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000007055555556666667500000000000000000000000000000000000000000000000000000000000000000000000c0000007c
000000000000000070000000000000070056d544444444450000000000000000000000000000000000000000000000000000000c0000000c0000007c000007cc
0000000000000000700000000000000700566d555555555000000000000000000000000000000000000000c0000000c0000000c0000000c0000000c0000007c0
00000000000000007000000000000c070056666666dd5000000000000000000000000000000000000000000000000000000000c000000cc0000007c000007cc0
00000000000000007000000000007007000555555555000000000000000000000000000000000000000000000000000000000000000000c000000cc000007cc0
000000000000000060000000000c0006000000ddddd0000000000000000000000000000000000000000000c0000000c0000000c0000000c0000000c0000007c0
00000000000000006600000000000066000000060600000000000000000000000000000000000000000000000000000c0000000c000000cc000000cc000007cc
000000000000000066666666666666660000000006000000000000000000000000000000000000000000000000000000000000000000000c0000000c0000007c
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
34200020307103271033710377103a71037710327102e710307103271033710377103a71037710337103271030710327103771030710327103771030710327103071032710377103a7103c7103a7103771035710
000a00001d3232c333283331a3231031310313103030a303103031030310303103031030310303103030030300303003030030300303003030030300303003030030300303003030130300302003020030208300
000c0005203342032420314223041a3041b3041b30400004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002d753207031d7030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002b33528305004050740524b0524b0524b0524b0524b0524b052f10524b0524b0524b0524b0524b0524b0524b051c0051b00526b0526b0526b0526b0526b0526b0526b0526b0528b0528b0528b052ab05
001000002935329353293332931329303293030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c200020187401874018740187401874018740187401874014740147401474014740147401474014740147400f7400f7400f7400f7400f7400f7400f7400f7401174011740117401174011740117401174011740
001000040163003630026300163017700177001770018700187001870018700147001470015700157001570015700157001570015700157001570015700157001570015700157001470026000000000000000000
001000001a340213402634020300263002b7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001f25022250272502b25030200000002b20000000000001f20022200272002b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000001074012740177401f7401f7201f71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f000004730047300473005730057300573006730067400674007740077400774008740087400875009750097500a7500a7500b7500b7500c7600c7600d7600d7600e7600f7601077011770127701377014770
4810000000620006200062001630026300363004640056400665006650066500766007660096700a6700a6700a6700b6700c6700c6700d6700e6701067011670126701367014670156701767018670196701b670
001000002937329373293732935329323003030830300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
001400000775107751077510775107751077510775107751077510775107751077510775107751077510775107751077510775107751077510775107751077510775107751077510775107751077510775107751
001000003fa7621a061da061aa0615606116060e6060c6060c6060670604706037060170600706000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006
902400001b6711967118671176711567114671136711167110671106710f6710e6710d6610b6610a6610966108661076510665105651046510364103641026410164101631016310162100621006110061100611
aa1400002067120671206712067120671206712067120671206712067120671206712067120671206712067120671206712067120671206712067120671206712067120671206712067120671206712067120671
001000002237322353213531e3331e3031e3031e3031e3031e3030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
0010000006a760aa061da061aa0615606116060e6060c6060c6060670604706037060170600706000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000018e5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 02084344
00 10134344


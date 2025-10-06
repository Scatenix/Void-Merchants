pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- void merchants
-- fight, travel, trade!

-- license: 
-- all rights reserved.
-- copyright (c) 2025 scatenix (https://github.com/scatenix)

-- this software, including the game and all assets, is provided for personal use only.
-- you may download and play the game, but you may not copy, modify, distribute,
-- or use it for any other purpose without the express written permission of the copyright holder.

-- the software is provided "as is", without warranty of any kind, express or
-- implied, including but not limited to the warranties of merchantability,
-- fitness for a particular purpose and noninfringement. in no event shall the
-- authors or copyright holders be liable for any claim, damages or other
-- liability, whether in an action of contract, tort or otherwise, arising from,
-- out of or in connection with the software or the use or other dealings in
-- the software.

GAME_VERSION = "v9.4.2"

-- This file is the main file

-- SFX
-- 0 explosion
-- 1 big explosion
-- 2 music part 1
-- 3 hit enemy
-- 4 increased shooting speed sound
-- 5 shooting sound
-- 6 collect item sound
-- 7 hit player
-- 8 music part 2
-- 9 speed increase sound
-- 10 life pickup
-- 11 ship upgrade
-- 12 shield increase
-- 13 prepare for jump
-- 14 starting thrusters for jump
-- 15 jump
-- 16 hyper space
-- 17 sell / money pickup
-- 18 land
-- 19 hyper space thrusters
-- 20 step out of hyperspace
-- 21 buy
-- 22 spawn in enemies
-- 23 cannot perform action (used at trading)

-- needed to save and load the game (saving at trader, loading at titlescreen)
cartdata("void-merchants_4e40baa22f0e407277e79304514550b9e952ccef")

function _init()
	music(0)

	init_passing_stars()

	-- by default, only the titlescreen_mode should be true
	titlescreen_mode = true
	battle_mode = false
	travel_to_battle_mode = false
	travel_after_battle_mode = false
	converstaion_mode = false
	trading_mode = false
	death_mode = false

	init_battle = true
	init_titlescreen = true
	wait_after_titlescreen = false

	level = 1
	pl_credits = 200
	negative_score = 0
	set_pl_ship(1)
	pl_ship_weapons = 1
	set_pl_drone(0)

	stars_hide = false

	current_planet = flr(rnd(6)) + 1
	current_small_planet = flr(rnd(6)) + 1

	-- for game restart
	stars = {} -- 1: x 2: y 3: speed
	enemies = {}
	explosions = {}
	hitmarkers = {}
	pl_ship_shots = {}
	pl_ship_items_stored = {}
	drone_shots = {}
	enemy_shots = {}
	pl_items_stored = {}
	floating_items = {}
	money_pickups = {} -- amount, x, y, animation_frames_remainung
	trading_phase = 0
end

function _update()
	if travel_after_battle_mode then
		ship_ctrl()
		drone_ctrl()
		ship_and_drone_shoot()
		ship_burner_calculation()
		enemy_shots_hit_friendly(pl_ship_x, pl_ship_y, pl_ship_hitbox_skip_pixel, pl_ship_hitbox_width, 1)
		enemy_shots_hit_friendly(drone_x, drone_y, drone_hitbox_skip_pixel, drone_hitbox_width, 2)
		calculate_floating_items_drift()
		floating_items_colides_player()
		speed_buff_timer()
		shot_speed_buff_timer()

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
				if pl_ship_x > 0.14 then
					pl_ship_x -= 0.15
				end
			end
		end
		travel_from_battle_animation_script()
	elseif titlescreen_mode then
		if init_titlescreen then
			init_titlescreen = false
			
			-- set ship and drone
			pl_ship_x = 20
			pl_ship_y = 90
			
			add_enemy(flr(rnd(7)) + 14)
			-- set x, y, life, shield, speed, wobble_state
			enemies[1][1] = 100
			enemies[1][2] = 89
			enemies[1][7] = 1
			enemies[1][8] = 0
			prevent_enemy_moving_on_x = true
		end
		drone_ctrl()
		ship_and_drone_shoot()
		friendly_shots_hit_enemy(pl_ship_shots, pl_ship_damage, 1)
		ship_burner_calculation()
		generate_void_noise(40, 50, 50, 40, 15)

		if save_game_exists() and btnp(4) and #pl_ship_shots <= 0 and #enemies > 0 then
			load_game()
		end

		-- Give the player some time before enemies spawn
		if #enemies <= 0 then
			ship_ctrl()
			if not wait_after_titlescreen then
				tme = time()
				wait_after_titlescreen = true
			end
		end
		if wait_after_titlescreen and time() - tme >= 1.5 then
			battle_mode = true
			prevent_enemy_moving_on_x = false
			titlescreen_mode = false
			wait_after_titlescreen = false
		end
	elseif battle_mode then
		if init_battle then
			all_stars_speed_ctrl(1)
			min_enemies_on_level = 10 + flr(level * 1.5)
			initial_battle_draw = true
			init_battle = false
			tme = time()
			spawn_enemy_wave()
		end

		-- spawn new enemy wave every 20 seconds if there are still enemies. else after 5
		-- I think this can lead to crashes if to many enemies are created at once
		if #enemies > 0 then
			interval = 23
		else
			interval -= 0.3
		end
		if time() - tme >= flr(interval) then
			spawn_enemy_wave()
			tme += interval
		end

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

		if not travel_after_battle_mode and min_enemies_on_level <= 0 and #enemies <= 0 then
			tme = time()
			travel_after_battle_mode = true
			current_planet = flr(rnd(6)) + 1
		end
	elseif converstaion_mode then
		if not pause_on_text then
			converstaion_mode = false
			trading_mode = true
		end
		if conv_partner == 2 then
			generate_void_noise(0, 0, 128, 128, 50)
		end
		advance_textbox()
	elseif trading_mode then
		ship_burner_calculation()
		drone_ctrl()

		if trading_phase == 1 then
			trader_station_x -= 0.5
		elseif trading_phase == 2 then
			black_hole_x -= 1
			pl_ship_x += 0.1
		elseif trading_phase == 4 then
			advance_textbox()
		elseif trading_phase == 5 then
			trader_station_x -= 0.5
			ship_ctrl()
			ship_and_drone_shoot()
		end

		trading_script()
	end

	animation_counters()
end

-- frame counted animation counters. Easier to handle than time() based variables.
function animation_counters()
	-- animation_counter -> used for animations with short runtime
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

function _draw()
	clear_screen()
	
	if death_mode then
		print("your ship was destroyed!", 15, 56, 8)
		print("press 🅾️ to play again!", 16, 72, 7)
		draw_explosions()
		if btnp(4) then
			_init()
		end
	elseif titlescreen_mode then
		draw_passing_stars()
		draw_titlescreen()
		draw_enemies()
		draw_ship()
		draw_drone()
		draw_friendly_shots(pl_ship_shots, 11)
		draw_friendly_shots(drone_shots, 12)
		draw_enemy_shots()
		draw_hitmarkers()
		draw_explosions()
		draw_void_noise()
	elseif battle_mode then
		if initial_battle_draw == true then
			initial_battle_draw = false
			show_level = true
			show_level_frames_left = 100
			if level == 1 then
				show_level_frames_left = 250
			end
		end

		draw_passing_stars()

		if show_level then
			print("level " ..level, 52, 12, 10)

			-- tutorial on the first level
			if level == 1 then
				print("⬆️⬅️⬇️➡️ to move", 34, 20, 6)
				print("hold ❎ to shoot", 34, 28, 6)
				print("🅾️ to interact", 38, 36, 6)
			end
			show_level_frames_left -= 1
		end
		if show_level_frames_left <= 0 then
			show_level = false
		end

		draw_battle_stats()
		draw_floating_items()
		draw_enemies()
		draw_ship()
		draw_drone()

		draw_friendly_shots(pl_ship_shots, 11)
		draw_friendly_shots(drone_shots, 12)
		draw_enemy_shots()

		draw_hitmarkers()
		draw_explosions()
		draw_money_pickups()
	elseif converstaion_mode then
		draw_passing_stars()
		draw_textbox()
		draw_money_pickups()
	elseif travel_after_battle_mode then
		draw_passing_stars()
		draw_floating_items()
		draw_trader_station()
		draw_drone()
		draw_ship()
		draw_friendly_shots(pl_ship_shots, 11)
		draw_friendly_shots(drone_shots, 12)
		draw_money_pickups()
	elseif trading_mode then
		draw_passing_stars()
		if trading_phase == 0 then
			draw_tradescreen()
			draw_battle_stats()
		else
			if trading_phase == 4 then
				draw_textbox()
			else
				if talk_to_void_creature then
					draw_black_hole_background()
				end
				draw_trader_station()
				draw_drone()
				draw_ship()
				if trading_phase == 5 then
					draw_friendly_shots(pl_ship_shots, 11)
					draw_friendly_shots(drone_shots, 12)
				end
				if talk_to_void_creature then
					draw_black_hole_foreground()
				end
			end
		end
	end

	----- debug section
	-- show_stored_items()
	-- print("memory: "..stat(0).." KiB", 0, 0, 7)
	-- print("pico cpu: " ..stat(1), 0, 8, 7)
	-- print("sys cpu: " ..stat(2), 0, 16, 7)
end
-->8
-- global variables
tme = 0 -- here to track times with time()

show_level = false
show_level_frames_left = 0

animation_counter = 0
long_animation_counter = 0
x_left_boundry = 0
x_right_boundry = 120
y_up_boundry = 0
y_down_boundry = 97

initial_battle_draw = true

max_pl_weapons = 1
max_dr_weapons = 0
max_drones = 6
max_pl_extra_damage = 10

travel_after_battle_phase = 0
jump_wobble = false
jump_to_hyperspce = false
arrive_in_hyperspace = false
show_trader_station_far = false
show_trader_station_near = false

trading_phase = 0
talk_to_void_creature = false
skip_void = false

money_pickup_animation_frames = 50

planets = {
	{80, 0},
	{0, 32},
	{32, 32},
	{64, 32},
	{96, 32},
	{0, 64},
}

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

-->8
-- draw functions
noise_dots = {}

function draw_money_pickups()
	for mp in all(money_pickups) do
		x = mid(0, mp[2] - 5, 90)
		y = max(flr(mp[3]) - 15, 3)
		spr(credit[1], x - 3, y - 2)
		print(" " ..pl_credits.. " +" ..mp[1], x, y, 3)
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
	print(" " .. pl_ship_life, 15, 110, 8)

	print("sh:", 41, 110, 7)
	print(" " .. pl_ship_shields, 52, 110, 12)

	print("dr:", 78, 110, 7)
	print(" " .. drone_life, 89, 110, 8)

	local draw_drone_shield_offset_y
	if drone_life < 4 then
		draw_drone_shield_offset_y = 89 + drone_life * 8
	elseif drone_life < 10 then
		draw_drone_shield_offset_y = 97
	else
		draw_drone_shield_offset_y = 101
	end

	if drone_shields > 0 then
		print("+", draw_drone_shield_offset_y, 110, 12)
		print(drone_shields, draw_drone_shield_offset_y + 4, 110, 12)
	end

	print("stg:", 4, 119, 7)
	print(get_free_storage(), 19, 119, 13)

	print("dmg:", 28, 119, 7)
	print(pl_ship_damage+drone_damage, 43, 119, 9)
	
	print("wps:", 52, 119, 7)
	print(pl_ship_weapons+drone_weapons, 67, 119, 5)
	
	print("sp:", 76, 119, 7)
	print(format_one_decimal(pl_ship_speed), 87, 119, 11)
	
	print("sts:", 100, 119, 7)
	print(format_one_decimal(pl_ship_shot_speed), 115, 119, 14)
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
-- player

function add_credits(credits)
	pl_credits += credits
	if pl_credits > 9999 then
		pl_credits = 9999
	end
end

function store_item(item, price)
	if get_free_storage() > 0 then
		sfx(6)
		add(pl_items_stored, {item[3], price})
		del(floating_items, item)
	end
end

function drop_items_when_drone_dies()
	for i=#pl_items_stored, pl_ship_storage+1, -1 do
		add_floating_item(pl_items_stored[i][1], drone_x - 6*(i-pl_ship_storage-1) , drone_y - 4 + rnd(8), pl_items_stored[i][2])
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
pl_ship_life=5
pl_ship_max_life=0
pl_ship_shields=0
pl_ship_weapons=0
pl_ship_shot_speed=0 -- actual projectile speed and fire rate
pl_ship_speed=0 -- float
pl_ship_default_shot_speed=0
pl_ship_default_speed=0
pl_ship_storage=0
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
	pl_ship_damage = 2 * tier
	for i = 1, pl_ship_damage_upgrades do
		pl_ship_damage += flr(1 + i / 5)
	end
	pl_ship_life = 5 * tier
	pl_ship_max_life = pl_ship_life
	pl_ship_shields = flr(tier/2)
	pl_ship_max_shield = tier
	pl_ship_shot_speed = min(tier / 3 + 1, 2.5)
	pl_ship_speed = 1 + tier * 0.2
	pl_ship_default_shot_speed = min(tier / 3 + 1, 2.5)
	pl_ship_default_speed = 1 + tier * 0.2
	pl_ship_storage = mid(3, ceil(tier * 1.5), 8)
	max_pl_weapons = min(tier, 5)
end

-- {y start of ship on sprite, y width of ship}
function get_ship_htbx_skp_pxl_width(tier)
	if tier == 1 then
		return {2, 5}
	elseif tier == 2 or tier == 3 then
		return {1, 7}
	elseif tier == 4 or tier == 5 or tier == 6 then
		return {0, 8}
	end
end

-- shotmask is used to tell at which positions shots come out of the player ship, drone and enemy.
-- -1 means no shot, 0-8 is the y position of a shot
function get_shot_mask(weapons)
	local shot_mask = {}
	
	if weapons == 0 then
		shot_mask = {-1, -1, -1, -1, -1}
	end
	if weapons == 1 then
		shot_mask = {-1, -1, 4, -1, -1}
	end
		if weapons == 2 then
		shot_mask = {-1, -1, 2, 6, -1}
	end
	if weapons == 3 then
		shot_mask = {-1, 2, 4, 6, -1}
	end
	if weapons == 4 then
		shot_mask = {0, 2, 4, 6, -1}
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
		sfx(5)

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
					local shot = {drone_x + 10, drone_y + shm}
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

function ship_burner_calculation()
	if animation_counter % 10 == 0 then
	 	pl_ship_sprite += 16
	end
	if pl_ship_sprite > 37 then
	 	pl_ship_sprite -= 48
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
drone_damage = 0
drone_weapons = 0
drone_life = 0
drone_max_life = 0
drone_shields = 0
drone_max_shields = 0
drone_storage = 0
drone_available = false
-- 0: attack; 1: cargo
drone_type_attack = true

function set_pl_drone(tier)
	if tier == 1 and drone_available then
		drone_weapons = 1
	end

	drone_tier = tier
	if tier == 0 then
		drone_available = false
		drone_sprite = 48
		drone_storage = 0
		drone_weapons = 0
		drone_damage = 0
		drone_shields = 0
		max_dr_weapons = 0
	-- get attack drone
	elseif tier >= 0 and tier <= 6 and drone_type_attack then
		drone_sprite = 48 + tier
		htbx = get_drone_htbx_skp_pxl_width(tier)
		drone_hitbox_skip_pixel = htbx[1]
		drone_hitbox_width = htbx[2]
		drone_damage = tier + 1
		drone_life = 4 * tier
		drone_max_life = 4 * tier
		drone_shields = tier
		drone_max_shields = tier
		drone_storage = ceil(tier * 0.5)
		drone_available = true
		max_dr_weapons = min(tier, 5)
	-- get storage drone
	elseif tier >= 0 and tier <= 3 and not drone_type_attack then
		drone_sprite = 5 + tier
		htbx = get_drone_htbx_skp_pxl_width(tier)
		drone_hitbox_skip_pixel = htbx[1]
		drone_hitbox_width = htbx[2]
		drone_damage = 0
		drone_life = 12 * tier
		drone_max_life = 12 * tier
		drone_shields = tier * 2
		drone_max_shields = tier * 2
		drone_storage = tier * 2
		drone_available = true
		drone_weapons = 0
		max_dr_weapons = 0
	end
end

-- {y start of drone on sprite, y width of drone}
function get_drone_htbx_skp_pxl_width(tier)
	if not drone_type_attack and tier == 1 then
		return {3, 4}
	elseif tier == 1 then
 		return {3, 3}
	elseif tier == 2 then
		return {1, 6}
	elseif tier == 3 or tier == 5 or tier == 6 then
		return {1, 7}
	elseif tier == 4 then
		return {2, 5}
	end
end

function drone_ctrl()
	if pl_ship_y < 7 then
		drone_offset_y = 1.5 * (pl_ship_y - 7)
		drone_offset_x = flr(drone_offset_y / 1.5)
		if drone_offset_x < -5 then
	  		drone_offset_x = 0 - pl_ship_y * 2
		end
	else
		drone_offset_y = 0
		drone_offset_x = 0
	end
	
	-- 11 is the distance to the last possible pixel of all drones to the ship back
	if pl_ship_x <= x_left_boundry + 11 then
		drone_offset_x = x_left_boundry + 11 - pl_ship_x
	end

	drone_x = pl_ship_x-11+drone_offset_x
	
	if animation_counter <= 10 then
		drone_y = pl_ship_y-4 - drone_offset_y
	elseif animation_counter > 10 then
	 	drone_y = pl_ship_y-5 - drone_offset_y
	end
end

function kill_drone()
	add(explosions, {drone_x, drone_y, 139})
	drop_items_when_drone_dies()
	set_pl_drone(0)
end
-->8
-- enemies

min_enemies_on_level = 0
enemy_shot_cooldown = 0
prevent_enemy_moving_on_x = false

-- max level 20
-- try_avoid_placing_behind: Try to not place an enemy behind another enemy.
--							 Places behind anyways if not avoidable because of to many enemies.
function add_enemy(lvl, try_avoid_placing_behind)
	local y = flr(rnd(96))
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
			if y > 96 then
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
	enemy[6] = ceil(lvl / 5)
	-- life
	enemy[7] = calc_enemy_life(lvl)
	-- shields
	enemy[8] = flr(lvl/3)
	if enemy[8] > 5 then
		enemy[8] = 5
	end
	-- weapons
	enemy[9] = ceil(lvl / 5)
	-- shot_speed
	enemy[10] = 1 + 0.065 * lvl
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
		return {2, 6, 8, 24, 28, 30}
	elseif lvl >= 19 and lvl <= 20 then
		return {2, 8, 14, 24, 28, 30, 48, 54}
	end
end

function spawn_enemy_wave()
	if min_enemies_on_level > 0 then
		sfx(22)
		-- have always at least 2 enemies with up to 3 more (random). 1 more enemy every 5 levels
		local enemy_number_this_wave = 2 + flr(rnd(3)) + flr(level * 0.2)
		min_enemies_on_level -= enemy_number_this_wave

		for i = 0, enemy_number_this_wave, 1 do
			local enemy_level = max(1, flr(rnd(5)) + (level - 4))
			add_enemy(enemy_level, true)
		end
	end
end

function calc_enemy_life(lvl)
	return lvl * 3 + 1
end

-- {y start of enemy on sprite, y width of enemy}
function get_enemy_htbx_skp_pxl_width(lvl)
	if lvl == 1 or 3 or 11 then
 		return {0, 7}
	elseif lvl == 2 or 8 or 9 or 10 or 12 or 14 or 20 then
		return {0, 8}
	elseif lvl == 4 or 5 or 6 then
		return {2, 5}
	elseif lvl == 7 or 13 or 15 or 16 or 17 or 19 then
		return {1, 7}
	elseif lvl == 18 then
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
			sfx(5)
	
			for shm in all(shot_mask) do
				if shm != -1 then
					local shot = {enemy[1] -1, enemy[2] + shm, enemy[10], enemy[6]}
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
	if not titlescreen_mode then
		local droped_item = drop_item()
		if droped_item[1] > 0 then
			add_floating_item(droped_item[1], enemy[1], enemy[2], droped_item[2])
		end
	end
end

-->8
--collision

-- shots --> [1] = x; [2] = y
function friendly_shots_hit_enemy(shot_array, damage_from, ship1_drone2)
	for shot in all(shot_array) do
		for enemy in all(enemies) do
			local hit_x
			if enemy[7] > 0 then
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
					sfx(0)
					enemy_drop_item(enemy)
					del(enemies, enemy)
				end

				create_hitmarker(shot[1], shot[2], ship1_drone2)
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

				create_hitmarker(shot[1], shot[2], 3)
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
-- items

-- buffs are at 154 to 157
-- upgrades are at 158 to 170
-- credits are at 171 to 172
-- trading goods are at 173 to 189

-- buff {sprite, price, name}
speed_buff = {154, 0, "speed buff"}
shot_speed_buff = {155, 0, "shot speed buff"}
life_up = {156, 0, "life up"}
shield_up = {157, 50, "shield up"}

-- stat increases {sprite, price, name}
attack_damage_inc = {170, 50, "damage upgrade"}
drone_inc = {159, 100, "drone upgrade"}
weapons_inc = {158, 50, "weapon upgrade"}

-- trading items {sprite, price, name}
credit = {171, 5, "credit"}
scrap = {173, 10, "scrap"}
copper = {174, 20, "copper"}
gold = {184, 30, "gold"}
parts_crate = {185, 50, "parts crate"}
cobalt = {186, 75, "cobalt"}
platinum = {187, 100, "platinum"}
void_fragment = {188, 150, "void fragment"}
super_credit = {172, 100, "super credit"}
void_crystal = {189, 250, "void crystal"}

function add_floating_item(item_type, x, y, price)
	if item_type > 0 then
		local item = {}
		item[1] = x
		item[2] = y
		-- sprite and id
		item[3] = item_type
		item[4] = price
		add(floating_items, item)
	end
end

function interpret_item(item)
	if item[3] == speed_buff[1] then
		if pl_ship_speed_buff_time == 0 then
			sfx(9)
			pl_ship_speed *= 1.5
			pl_ship_speed_buff_time = 120
			del(floating_items, item)
		end
	elseif item[3] == shot_speed_buff[1] then
		if pl_ship_shot_speed_buff_time == 0 then
			sfx(4)
			pl_ship_shot_speed *= 2
			pl_ship_shot_speed_buff_time = 120
			del(floating_items, item)
		end
	elseif item[3] == life_up[1] then
		if pl_ship_life < pl_ship_max_life then
			sfx(10)
			pl_ship_life += 1
			del(floating_items, item)
		end
	elseif item[3] == shield_up[1] then
		if pl_ship_shields < pl_ship_max_shield then
			sfx(12)
			pl_ship_shields += 1
			del(floating_items, item)
		elseif drone_available and drone_shields < drone_max_shields then
			sfx(12)
			drone_shields += 1
			del(floating_items, item)
		end
	elseif item[3] == attack_damage_inc[1] then
		if pl_ship_damage_upgrades < max_pl_extra_damage then
			sfx(11)
			pl_ship_damage_upgrades += 1
			pl_ship_damage += flr(1 + (pl_ship_damage_upgrades) / 5)
			del(floating_items, item)
		else
			store_item(item, attack_damage_inc[2])
		end
	elseif item[3] == drone_inc[1] then
		if drone_tier < max_drones then
			sfx(11)
			drone_available = true
			set_pl_drone(drone_tier + 1)
			del(floating_items, item)
		else
			store_item(item, drone_inc[2])
		end
	elseif item[3] == weapons_inc[1] then
		if pl_ship_weapons < max_pl_weapons then
			sfx(11)
			pl_ship_weapons+=1
			del(floating_items, item)
		elseif drone_weapons < max_dr_weapons then
			sfx(11)
			drone_weapons+=1
			del(floating_items, item)
		else
			store_item(item, weapons_inc[2])
		end
	elseif item[3] == credit[1] then
		sfx(17)
		add_credits(credit[2])
		add_money_pickup(credit[2])
		
		del(floating_items, item)
	elseif item[3] == super_credit[1] then
		sfx(17)
		add_credits(super_credit[2])
		add_money_pickup(super_credit[2])
		del(floating_items, item)
	else
		store_item(item, item[4])
	end
end

function add_money_pickup(money)
	add(money_pickups, {money, pl_ship_x, pl_ship_y, money_pickup_animation_frames})
end

function speed_buff_timer()
	if pl_ship_speed_buff_time > 0 then
			pl_ship_speed_buff_time -= 1
	else
		pl_ship_speed = pl_ship_default_speed
		sfx(9, -2)
	end
end

function shot_speed_buff_timer()
	if pl_ship_shot_speed_buff_time > 0 then
		pl_ship_shot_speed_buff_time -= 1
	else
		sfx(4, -2)
		pl_ship_shot_speed = pl_ship_default_shot_speed
	end
end

-- calculate drop (random chance)
function drop_item()
	local num = rnd(1000)
	if num >= 995 then    --0.5%
		return void_crystal
	elseif num >= 985 then --1%
		return super_credit
	elseif num >=975 then --1%
		return drone_inc
	elseif num >=965 then --1%
		return weapons_inc
	elseif num >=955 then --1%
		return attack_damage_inc
	elseif num >=935 then --2%
		return void_fragment
	elseif num >=915 then --2%
		return shield_up
	elseif num >=890 then --2,5%
		return platinum
	elseif num >=860 then --3%
		return life_up
	elseif num >=830 then --3%
		return cobalt
	elseif num >=795 then --3,5%
		return parts_crate
	elseif num >=755 then --4%
		return gold
	elseif num >=705 then --5%
		return speed_buff
	elseif num >=645 then --6%
		return copper
	elseif num >=605 then --4%
		return shot_speed_buff
	elseif num >=500 then --10.5%
		return scrap
	elseif num >=400 then --10%
		return credit
	else --40%
		return {-1, 0, "nothing"} -- no drop
	end
end

-- floating item speed is linked to the star_speed_multiplier!
function calculate_floating_items_drift()
	for item in all(floating_items) do
		if travel_after_battle_phase == 5 then
			item[1] -= 5
		else
			item[1] -= 0.25 * star_speed_multiplier
		end

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
stars_hyperspeed = false
star_base_speed = 1

function init_passing_stars()
	set_stars_max_y()
	for i = 1, max_stars do
		star = {flr(rnd(127)), flr(rnd(stars_max_y)), flr(rnd(max_star_speed-min_star_speed) + min_star_speed) * star_base_speed} 
		add(stars, star)
	end
end

function set_stars_max_y()
	if battle_mode then
		stars_max_y = 105
	else
		stars_max_y = 127
	end
end

function draw_passing_stars()
	if star_speed_multiplier > 0 then
	 	stars_start_x = 127
	else
	 	stars_start_x = 0
	end

 	if stars_counter >= stars_counter_threshold and max_stars > #stars then
		set_stars_max_y()
		local star = {stars_start_x, flr(rnd(stars_max_y)), flr(rnd(max_star_speed-min_star_speed) + min_star_speed) * star_speed_multiplier}
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

	if stars_hide then
		-- just paint black over then to avoid ugly star init
		rectfill(0, 0, 128, 128, 0)
	end
end

function all_stars_speed_ctrl(speed_multiplier)
	for star in all(stars) do
		star[3] = star_base_speed * speed_multiplier
	end
	star_speed_multiplier = speed_multiplier
end
-->8
-- data_ops

saved = false

function save_game_exists()
	if dget(0) > 0 then
		return true
	end
	return false
end

function reset_save_game()
	for i=0, 64 do
		dset(i, 0)
	end
end

function save_game()
	reset_save_game()
	dset(0, level)
	dset(1, pl_credits)
	dset(2, pl_ship_weapons)
	dset(3, pl_ship_tier)
	dset(4, pl_ship_damage_upgrades)
	dset(5, pl_ship_life)
	dset(6, pl_ship_shields)
	dset(7, drone_tier)
	dset(8, drone_life)
	dset(9, drone_shields)
	dset(10, drone_weapons)
	dset(11, max_drones)
	if drone_type_attack then dset(12, 1) end
	dset(13, negative_score)

	-- for loop for stored items + sprite, saved to slot 20-60 (max stg: 14 * 2 + buffer)
	j = 20
	for item in all(pl_items_stored) do
		dset(j, item[1])
		dset(j+1, item[2])
		j += 2
	end
	saved = true
	sfx(11)
end

function load_game()
	enemies = {}
	titlescreen_mode = false
	prevent_enemy_moving_on_x = false
	trading_mode = true

	level = dget(0)
	pl_credits = dget(1)
	pl_ship_weapons = dget(2)
	pl_ship_tier = dget(3)
	pl_ship_damage_upgrades = dget(4)
	set_pl_ship(pl_ship_tier)
	pl_ship_life = dget(5)
	pl_ship_shields = dget(6)
	max_drones = dget(11)
	drone_tier = dget(7)
	drone_type_attack = dget(12) == 1
	set_pl_drone(drone_tier)
	drone_life = dget(8)
	drone_shields = dget(9)
	drone_weapons = dget(10)
	negative_score = dget(13) - 100

	-- for loop for stored items + sprite, saved to slot 20-60 (max stg: 14 * 2 + buffer)
	for i = 20, 60, 2 do
		if dget(i) ~= 0 then
			add(pl_items_stored, {dget(i), dget(i+1)})
		end
	end

	-- doing this to save negative_score permanently
	save_game()

	sfx(11)
end
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
		conv_partner = 1
		trader_converstaion()
		travel_after_battle_phase = 0
		travel_after_battle_mode = false
		converstaion_mode = true
		pause_on_text = true
	elseif travel_after_battle_phase == 10 and time() - tme >= 28 then -- 28
		-- land
		travel_after_battle_phase = 11
		stop_trader_station_near = true
		all_stars_speed_ctrl(0)
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
		pl_ship_default_speed = temp_pl_ship_default_speed
		pl_ship_speed = temp_pl_ship_default_speed
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
		pl_ship_shot_speed_buff_time = 0
		pl_ship_speed_buff_time = 0
		travel_after_battle_phase = 6
		jump_wobble = false
		jump_to_hyperspce = true
		all_stars_speed_ctrl(10)
		floating_items = {}
		sfx(15)
	elseif travel_after_battle_phase == 4 and time() - tme >= 10 then -- 10
		-- approaching hyperspace
		pl_ship_shot_speed_buff_time = 0
		pl_ship_speed_buff_time = 0
		travel_after_battle_phase = 5
		stars_hyperspeed = true
		all_stars_speed_ctrl(1)
	elseif travel_after_battle_phase == 3 and time() - tme >= 6 then -- 6
		-- engaging thrusters
		pl_ship_shot_speed_buff_time = 0
		pl_ship_speed_buff_time = 0
		travel_after_battle_phase = 4
		jump_wobble = true
		battle_mode = false
		temp_pl_ship_default_speed = pl_ship_default_speed
		pl_ship_default_speed *= 0.2
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
		conv_text_2 = "it's dangerous to go alone..."
		conv_text_3 = "make sure you stock up on"
		conv_text_4 = "these drones."
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
		conv_text_2 = "you must be pretty capable!"
		conv_text_3 = "congratulations!"
		conv_text_4 = "let's trade a last time..."
		price = calc_player_goods_price(true)
		price += calc_player_upgrades_price(true)
		add(money_pickups, {price, 25, 50, 150})
		sfx(17)
	end
end

function void_creature_converstaion()
	if level == 5 then
		conv_text_1 = "i have been watching you."
		conv_text_2 = "you are making progress."
		conv_text_3 = "very well... continue..."
		conv_text_4 = "reversing time for you."
	elseif level == 10 then
		conv_text_1 = "you are changing destiny."
		conv_text_2 = "i did not expect that."
		conv_text_3 = "but i am... intrigued."
		conv_text_4 = "let us see where this goes."
	elseif level == 15 then
		conv_text_1 = "you are quite strong..."
		conv_text_2 = "curious..."
		conv_text_3 = "rise and shine, little pilot."
		conv_text_4 = "rise and shine..."
	elseif level == 20 then
		conv_text_1 = "you beat my game. good..."
		conv_text_2 = "i deem you... sufficient."
		conv_text_3 = "your score sums up to " .. max(0, pl_credits - negative_score)
		conv_text_4 = "let us return to the title."
	end
end

-->8
-- trading
black_hole_x = 0
trade_finished = false
trade_cursor_pos = 0
selling_upgrades_multiplier = 0.8
price_per_ship_hull_point = 5
price_per_drone_hull_point = 10
price_increase_per_weapon = 50
price_increase_per_drone = 100
price_increase_per_weapon_dmg = 25
price_per_ship_shield = 25
price_per_drone_shield = 50
price_increase_per_ship_tier = 500

function trading_script()
	if trading_phase == 5 and time() - tme >= 5 then -- 30
		all_stars_speed_ctrl(1)
		
		trading_mode = false
		battle_mode = true
		init_battle = true
		show_trader_station_near = false
		show_trader_station_far = false
		trading_phase = 0
		trade_cursor_pos = 0
		trade_finished = false
	elseif trading_phase == 4 and not pause_on_text then
		if level % 20 == 0 then
			_init()
		else
			-- send back to trading station
			skip_void = true
			stars_hide = false
			trading_phase = 0
		end
	elseif trading_phase == 3 and time() - tme >= 11.5  then -- 12 then
		pause_on_text = true
		converstaion_mode = true
		stars_hide = true
		trading_phase = 4
	elseif trading_phase == 2 and time() - tme >= 10 then -- 10.5
		void_creature_converstaion()
		trading_phase = 3
		conv_partner = 2
	elseif trading_phase == 1 and time() - tme >= 5 then -- 5
		all_stars_speed_ctrl(0.2)
		trading_phase = 2
	elseif trading_phase == 0 then
		if not trade_finished and level != 20 then
			stars_hide = true
			trade()
		else
			-- without this, shots shot before entering the trader are frozen and later displayed again when leaving
			pl_ship_shots = {}
			drone_shots = {}

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
end

function draw_tradescreen()
	-- corners
	spr(137, 0, -6, 1, 1, true)
	spr(137, 0, 98, 1, 1, true, true)
	spr(137, 120, -6, 1, 1)
	spr(137, 120, 98, 1, 1, false, true)

	-- horizontal bars
	for i = 2, 122, 8 do
		spr(136, i, -6)
		spr(136, i, 98, 1, 1, false, true)
	end

	-- vertical bars
	for i = 2, 96, 8 do
		spr(138, -1, i)
		spr(138, 126, i)
	end

	spr(credit[1], 98, 2)
	print(" " ..pl_credits, 104, 4, 10)
	spr(parts_crate[1], 98, 10)
	print(" " ..#pl_items_stored, 104, 12, 13)

	if calc_player_goods_price(false) > 0 then
		print("sell goods", 10, 4, 7)
		print("(" ..calc_player_goods_price(false).. ")", 51, 4, 10)
	else
		print("sell goods", 10, 4, 5)
	end

	if calc_player_upgrades_price(false) > 0 then
		print("sell upgrades", 10, 12, 7)
		print("(" ..calc_player_upgrades_price(false).. ")", 63, 12, 10)
	else
		print("sell upgrades", 10, 12, 5)
	end

	if pl_ship_life < pl_ship_max_life then
		print("repair ship hull ", 10, 20, 7)
		print("(" ..(pl_ship_max_life-pl_ship_life)*price_per_ship_hull_point.. ")", 75, 20, 10)
	else
		if pl_ship_tier < 6 then
			print("upgrade ship ", 10, 20, 7)
			print("(" ..pl_ship_tier*price_increase_per_ship_tier.. ")", 59, 20, 10)
		else
			print("upgrade ship ", 10, 20, 5)
		end
	end

	if drone_available and drone_life < drone_max_life then
		print("repair drones", 10, 28, 7)
		print("(" ..(drone_max_life-drone_life)*price_per_drone_hull_point.. ")", 63, 28, 10)
	else
		print("repair drones", 10, 28, 5)
	end

	if pl_ship_shields < pl_ship_max_shield then
		print("restore ship shield", 10, 36, 7)
		print("(" ..(pl_ship_max_shield-pl_ship_shields).. " * " .. price_per_ship_shield.. ")", 87, 36, 10)
	else
		print("restore ship shield", 10, 36, 5)
	end

	if drone_available and drone_shields < drone_max_shields then
		print("restore drone shield", 10, 44, 7)
		print("(" ..(drone_max_shields-drone_shields).. " * " .. price_per_drone_shield.. ")", 91, 44, 10)
	else
		print("restore drone shield", 10, 44, 5)
	end

	if get_number_of_stored_upgrades(false) > 0 then
		print("install stored upgrades", 10, 52, 7)
		print("(" ..get_number_of_stored_upgrades(false).. ")", 103, 52, 10)
	else
		print("install stored upgrades", 10, 52, 5)
	end

	if pl_ship_damage_upgrades < max_pl_extra_damage then
		print("install stronger weapons", 10, 60, 7)
		print("(" ..attack_damage_inc[2]+price_increase_per_weapon_dmg*pl_ship_damage_upgrades.. ")", 107, 60, 10)
	else
		print("install stronger weapons", 10, 60, 5)
	end

	if pl_ship_weapons < max_pl_weapons or drone_weapons < max_dr_weapons then
		print("install new weapon", 10, 68, 7)
		print("(" ..weapons_inc[2]+price_increase_per_weapon*(pl_ship_weapons+drone_weapons).. ")", 83, 68, 10)
	else
		print("install new weapon", 10, 68, 5)
	end

	if drone_tier < max_drones then
		if drone_type_attack then
			print("buy attack drone", 10, 76, 7)
			print("(" ..drone_inc[2]+price_increase_per_drone*drone_tier.. ")", 75, 76, 10)
		else
			print("buy cargo drone", 10, 76, 7)
			print("(" ..drone_inc[2]+price_increase_per_drone*drone_tier.. ")", 71, 76, 10)
		end
	else
		print("buy drone", 10, 76, 5)
	end

	if drone_type_attack then
		print("rebuild drones to cargo", 10, 84, 7)
	else
		print("rebuild drones to attack", 10, 84, 7)
	end

	print("leave", 10, 92, 9)
	if saved then
		print ("saved game!", 81, 92, 11)
	else
		print ("❎ to save", 84, 92, 12)
	end

	print("🅾️", 2, 4 + 8*trade_cursor_pos, 13)
end

function trade()
	if btnp(2) then
		if trade_cursor_pos > 0 then
			trade_cursor_pos -= 1
		else
			trade_cursor_pos = 11
		end
	end
	if btnp(3) then
		if trade_cursor_pos < 11 then
			trade_cursor_pos += 1
		else
			trade_cursor_pos = 0
		end
	end
	if btnp(5) and not saved then -- save game
		save_game()
	end
	if btnp(4) then
		if saved then
			saved = false
		end
		if trade_cursor_pos == 0 then -- sell all goods
			local price = calc_player_goods_price(true)
			if price == 0 then
				sfx(23)
			end
		elseif trade_cursor_pos == 1 then -- sell all upgrades
			price = calc_player_upgrades_price(true)
			if price == 0 then
				sfx(23)
			end
		elseif trade_cursor_pos == 2 then -- repair ship hull or upgrade ship
			if pl_ship_life < pl_ship_max_life then
				local price = (pl_ship_max_life-pl_ship_life)*price_per_ship_hull_point
				if pl_ship_max_life-pl_ship_life > 0 and pl_credits >= price then
					pl_ship_life = pl_ship_max_life
					pl_credits -= price
					sfx(10)
				else
					sfx(23)
				end
			else
				local price = pl_ship_tier*price_increase_per_ship_tier
				if pl_ship_tier < 6 and pl_credits >= price then
					pl_ship_tier += 1
					set_pl_ship(pl_ship_tier)
					pl_credits -= price
					sfx(12)
				else
					sfx(23)
				end
			end
		elseif trade_cursor_pos == 3 then -- repair drones
			local price = (drone_max_life-drone_life)*price_per_drone_hull_point
			if drone_available and drone_max_life-drone_life > 0 and pl_credits >= price then
				drone_life = drone_max_life
				pl_credits -= price
				sfx(10)
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 4 then -- restore ship shield point
			if pl_ship_shields < pl_ship_max_shield and pl_credits >= price_per_ship_shield then
				pl_ship_shields += 1
				pl_credits -= price_per_ship_shield
				sfx(12)
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 5 then -- restore drone shield point
			if drone_available and drone_shields < drone_max_shields and pl_credits >= price_per_drone_shield then
				drone_shields += 1
				pl_credits -= price_per_drone_shield
				sfx(12)
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 6 then -- install stored upgrades
			local upgrades = get_number_of_stored_upgrades(true)
			if upgrades == 0 then
				sfx(23)
			else
				sfx(11)
			end
		elseif trade_cursor_pos == 7 then -- install stronger weapons
			local price = attack_damage_inc[2]+price_increase_per_weapon_dmg*pl_ship_damage_upgrades
			if pl_ship_damage_upgrades < max_pl_extra_damage and pl_credits >= price then
				sfx(21)
				pl_ship_damage_upgrades += 1
				pl_ship_damage += flr(1 + (pl_ship_damage_upgrades) / 5)
				pl_credits -= price
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 8 then -- install new weapon
			local price = weapons_inc[2]+price_increase_per_weapon*(pl_ship_weapons+drone_weapons)
			if pl_ship_weapons < max_pl_weapons and pl_credits >= price then
				sfx(21)
				pl_ship_weapons += 1
				pl_credits -= price
			elseif drone_weapons < max_dr_weapons and pl_credits >= price then
				sfx(21)
				drone_weapons += 1
				pl_credits -= price
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 9 then -- buy drone
			price = drone_inc[2]+price_increase_per_drone*drone_tier
			if drone_tier < max_drones and pl_credits >= price then
				sfx(21)
				drone_available = true
				set_pl_drone(drone_tier + 1)
				pl_credits -= price
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 10 then -- convert drones
			dl = drone_life
			ds = drone_shields
			if drone_type_attack then
				max_drones = 3
				drone_type_attack = false
				set_pl_drone(min(3, drone_tier))
			else
				max_drones = 6
				drone_type_attack = true
				drone_weapons = 1
				set_pl_drone(drone_tier)
			end
			sfx(12)
			drone_life = min(dl, drone_life)
			drone_shields = min(ds, drone_shields)
		elseif trade_cursor_pos == 11 then -- leave
			trade_finished = true
			all_stars_speed_ctrl(0.2)
			stars_hide = false
			sfx(22)
		end
	end
end

-- if sell = true, sell items directly
function calc_player_goods_price(sell)
	local price = 0
	for item in all(pl_items_stored) do
		if item[1] > 172 then
			price += ceil(item[2] * (1 + (level - 1) / 28))
			if sell then
				sfx(17)
				del(pl_items_stored, item)
			end
		end
	end
	if sell then
		add_credits(price)
	end
	return price
end

-- if sell = true, sell items directly
function calc_player_upgrades_price(sell)
	local price = 0
	for item in all(pl_items_stored) do
		if item[1] < 171 then
			price += ceil(item[2] * selling_upgrades_multiplier)
			if sell then
				sfx(17)
				del(pl_items_stored, item)
			end
		end
	end
	if sell then
		add_credits(price)
	end
	return price
end

-- if equip is true, try to equip upgrades directly
function get_number_of_stored_upgrades(equip)
	local count = 0
	for item in all(pl_items_stored) do
		if item[1] >= 158 and item[1] <= 170 then 
			local skip = false
			if (item[1] == drone_inc[1] and drone_tier >= max_drones)
				or (item[1] == weapons_inc[1] and pl_ship_weapons >= max_pl_weapons and drone_weapons >= max_dr_weapons)
				or (item[1] == attack_damage_inc[1] and pl_ship_damage_upgrades >= max_pl_extra_damage)
				then
				skip = true
			end
			if not skip then
				count += 1
				if equip then
					interpret_item({0, 0, item[1]})
					del(pl_items_stored, item)
				end
			end
		end
	end
	return count
end

-->8
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

	sspr(48, 8, 8, 16, 69, 40, 8, 16)
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


__gfx__
0000000000000000000000005500dd000055500005d55dd000000000000000000000000000000000000000000000aaaaaaaa00000000000000000bbbbbb00000
00000000005d000000050000005d00d0005ddd000a66655d000000000005d550005dd55000000000000000000aaaaaaaaaaaaaa000000000000bbbbbbbbbb000
00dd00000dddd00005d55000a055500d95566660a99855dc0000000000566cc005d6ccc0000000000000000aaaaaaaaaaaaaaaaaa000000000bbbbbbbbbbbb00
05556d00a95566d0a98d56500985c600a985c77d0d566dc7000566c00056ddd00d66ddd000000000000000aaaaaaaaaaaaaaaaaaaa0000000bbbcccbbbbbbb30
a985ccd0085ddccd0a98dcc50985c600a985cccd0d566dcc000d556000566d5005d66d500000000000000aaaaaaaa999aaaaaaaaaaa000000bbcccbbbbbbbb30
05556d00a95566d0a98d5650a055500d95566660a99855dc089dd550098dd500985dd550000000000000aaaaaaa99aaaaa999aaaaaaa0000bbcccbbbbbbcbb33
00dd00000dddd00005d55000005d00d0005ddd000a66655d0000d000000d000000d5500000000000000aaaaaaa9aaaaaaaaaaaa99aaaa000bbccbbbbbbbcc133
00000000005d0000000500005500dd000055500005d55dd00000000000000000005000000000000000aaa9aaaaaaaaaaaa9aaaaa99aaaa00bbbbbbbbbbbbb133
0000000000000000000000005500dd000055500005d55dd00006d00000555d00055511000000000000aaa9aa99aaaaaaaa99aaaaaaaaaa00bbbbbcbbbbbbb333
00000000005d000000050000005d00d0005ddd000966655d006ddd005055d60005555100000000000aaaaaaa9aaaaaaaaaa9aaaaaaaaaaa0bbbbbbbbbbbb3333
00dd00000dddd00005d550009055500da5566660a88955dc06d111d055dddd6607777600000000000aaaaaaaaaaaaaaa9aa9aa9aaaaaaaa0bbbbbbbbbcb33333
05556d00985566d0a98d56500985c6009895c77d0d566dc7061818d00555dddd55555110000000000aaaaaaaaaaaaaaa9aaaaa999aaaaaa00bbbbbbcc1333330
9895ccd0095ddccd0aa9dcc50895c600a985cccd0d566dcc06d111d004cc9cc00bbb330000000000aaaaaaaaaaa9999a9aaaaaaa9aaaaaaa0bbbbb1111333330
05556d00a95566d0989d5650a055500da5566660998955dc06dd11dd844499900cdb7a0000000000aaaaaaaaaaa9aaaa9aaaaaaaaaaaaaaa0033333333333300
00dd00000dddd00005d55000005d00d0005ddd000a66655d066dddd1249055a09dd3aa4000000000aaaa9aaaaaaaaaaaaaaa99aaaaa99aaa0003333333333000
00000000005d0000000500005500dd000055500005d55dd00066dd112299aaa00994449000000000aaaa9aa99aaaaaaaaaaa9aaaaaaa9aaa0000033333300000
0000000000000000000000005500dd000055500005d55dd00606d111022288800077609000000000aaaaaaaa9aaaaaaaaaaa9aaaaaaa9aaa00000cccccc00000
00000000005d000000050000005d00d0005ddd000966655d006dd111092888a0057c690000000000aaaaaaaa99aaaa9aaaaaaaaaaaaaaaaa000ccccc6cccc000
00dd00000dddd00005d550009055500d95566660989955dc0060d11090188c0a755c556000000000aaaaaaaaa99aaa999aaaaaaaaaaaaaaa00ccccc6accccc00
05556d00895566d0a89d56500995c600a895c77d0d566dc706000d1190111c09755c550600000000aaaa9aaaaa99aaaaaaaaaaaaaaaaaaaa0ccccc655acccc10
8995ccd0095ddccd09a9dcc50895c6009995cccd0d566dcc006010105511cc5507515544000000000aaa9aaaaaaaaaaaaaaa9aaaaaaaaaa00ccccccaaccccc10
05556d00995566d0899d5650a055500da5566660a88955dc000001005049a405057a4404000000000aaa9aaaaaaaaaaaaa999aaa9aaaaaa0ccccccccccccc111
00dd00000dddd00005d55000005d00d0005ddd000966655d000d000000dddd00004950a9000000000aaa99aaaaaaaaaaa99aaaa99aaaaaa0ccaacccaa66cc111
00000000005d0000000500005500dd000055500005d55dd00600000000d00d00445550090000000000aaaaaaaaaaaaaaaaaaaa99aaaaaa00c655cca55a691111
0000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaa9aaaaaaaaaaaa9aaaaaaa00caacccca66555911
0000000000000000000dd000000dd0000000000000d0000000000050000000000000000000000000000aaaaaaa9aaaaaaaaaaaaaaaaaa000cccccccccc951111
0000000000000000009500000095000000000d0005dd000000005d000000000000000000000000000000aaaaaaa99aaaaaaa9999aaaa0000cccccccccc111111
0000000000000dd0000dd000000dd00000005dd0a95000d00a5ddddd00000000000000000000000000000aaaaaaa9aaaaaa9aaaaaaa000000cccccccc1111110
000000000000950000000dd0000000dd000a950005dd05dd00955600000000000000000000000000000000aaaaaaaaaaaaaaaaaaaa0000000ccccc1111111110
0000000000000dd0000095000dd0095000005dd000d0a9500a5ddddd0000000000000000000000000000000aaaaaaaaaaaaaaaaaa00000000011111111111100
000000000000000000000dd0950000dd00000d00000005dd00005d00000000000000000000000000000000000aaaaaaaaaaaaaa0000000000001111111111000
0000000000000000000000000dd0000000000000000000d000000050000000000000000000000000000000000000aaaaaaaa0000000000000000011111100000
000000000000bbbbbbbb000000000000000000000000cccccccc00000000000000000000000099999999000000000000000000000000dddddddd000000000000
000000000bbbbbbbbbbbbbb000000000000000000cccccccccccccc00000000000000000099999999999999000000000000000000dddddddddddddd000000000
0000000bbbbbb33bbbbbbbbbb000000000000007ccccccccccccccccc0000000000000055999999999999999900000000000000dddddddddddddddddd0000000
000000bbbbb3bbbbbbbbbbbbbb000000000000777ccccccccccccccccb00000000000095555999999999999999000000000000dddddddddddddddddddd000000
00000bbbbb33bbbb333333bbbbb00000000007777cccccccccccccccbbb000000000099999559999999999999990000000000d6dddddddddd666ddddddd00000
0000bbbbbbbbbbbbbbbbbbbbbbb30000000077c7ccbccbbcccccbbbbbbb300000000999999999999999955599999000000006666dddddddd6666ddddddd10000
000bbbbbbbbbbbbb33bbbbbbbbb330000007c77cccbcbbcbcccbbbbbbbb33000000999999999999999995555999990000006666ddddddddd66666dddddd11000
00bbbbbbbbbbb333bbbbbbbbbbb3330000bb7c7cccccbcbbbbbbbbbbbbb333000099999999999999999995555999990000d6666ddddddd6666666dddddd11100
00bbbbbbbbbbbbbbbbbbbbbbbbb3330000bbccccccbbbbbbbbbbbbbbbbb331000099999999999999999999955599990000666ddddddd666dddd6ddddddd11100
0bbbbb3333bbbbbbbbbb33bbbbb533300bbbbcbccbbbbbbbbbbbbbbcbbb11110099999999999999999999999955999900ddddddddd666dddddddddddddd11110
0bbbbbbbb333bbbbbbbbbbbbbb3553300bbbbbbccbbbbbbbbbcbbbbbbb311110099999999555999999999999999999900dddddddd6666ddddddddddddd111110
0bbbbbbbbbbbbbbbbbbbbb33bb3353300bbbbbbcccbbbbbbbbcbbbbbbb333130095999999555999999999999999999900ddddddd66666ddddddddddddd111110
bbbbbbbbbbbbbbbbbbbbbb3bbb333333cbbbbbccccbbccbccbbbbbbbbb33313195599999555999999999999999999999dddddddd66666ddddddddd666d111111
bbbbbbbbbbbbbbbbbbbbb33bbb333333bbbbbbcccccccbbcccbbbbbbbb33331155999995559999999999999999999999ddddddddd6666ddddddddd6665111111
bbbbbb3bbbbbbbbbb3bbbbbbbb333333bbbbbccccccbcccccbcbbbbbb333111159999995599999999955999999995999ddddddddd6666dddddddddd665111111
bbbbbb3bbbbbbb3333bbbbbbb3333333cbbccbccccbbbbbbccbcbbbbb311111199999995599999955555999999995999ddddddddd6666ddddddddddd65511111
bbbbbb3bbb3bbbbbbbbbbbbbb3333333ccbbcccccbbbbbbbbbbcbbbbb333311199999995999999955559999999955999ddddddddd66666dddddddddd65551111
bbbbbb3bb33bbbbbbbbbbbbbb3333333ccccbccccbbbbbbbbbcccbbb3133111199999999999999999559999999959999ddddddd666666666dddddddd15551111
bbbbbb3bb3bbbbbbbbbbbbbbb3333333cccccbbbccbbbbbbbbbcccbb1113113199999999999999999999999999959999dddddddd666666666ddddddd11551111
bbbbbbbbbbbbbbbbbbbb33bb33333333ccccbbbbbcccbbbbbbbccccb1111111199999999999999999999999999559999ddddddddddd6666666dddddd11551111
0bbbbbbbbbbbbbbbbbb33bbb333333300cccbbbbbbcccbbbbbbcccc111311330099999999999999999999999555999900dddddddddddd66666ddddd111111110
0bbbbbb3bbbbbbbbbbbbbbb3553333300ccccbbbbbcccbbbbbcccc1111131310099999999999555999999995599999900dddddddddddddd6666dddd111111110
0bbbbbb33bb33bbbbbbbbb35533333300cccccbbbcccccbbbbcbc11111113110099999999999555599999999999999900ddddddddddddddd6666dd1111111110
00bbbbbb3bbb33bbbbbb33553333330000ccccbbccccccbbbbcb1111111111000099999999995555599999999999990000ddddddd6dddddddddd111111111100
00bbbbbb3bbbbbbbb33333333333330000ccccbbcccccccbb1111111111111000099599999999995599999999999990000dddddd66666dddd111111151111100
000bbbbbbbb333333333333333333000000cccbccc111111111111111113300000095999999999955599999999999000000ddddd655555111111111551111000
00003333353333333333333333330000000011111111111111111111133300000000599999999999955599999999000000001111111111111111155551110000
00000333333333333353333333300000000001111111111155511111333000000000099999999999999999999990000000000111111111111155555511100000
00000033333333335553333333000000000000111111115555551111130000000000009999999999999999999900000000000011111111111555555111000000
00000003333333333333333330000000000000011111555555555111100000000000000999999999999999999000000000000001111111111511111110000000
00000000033333333333333000000000000000000115555555555510000000000000000009999999999999900000000000000000011111111111111000000000
00000000000033333333000000000000000000000000555555550000000000000000000000009999999900000000000000000000000011111111000000000000
00000000000022222222000000000000000006666660000000000dddddd0000000000000000000000600000000000000000a000000aa0aa00999099009000080
000000000222222222222220000000000006666666666000000dddd6dddd1000000000000000000006000000000a000000a9a0a00a99a9a0a988889a00980098
00000002222222222288822220000000006666666666660000dddd66dddd110000000000000000000600000000a99a000a999a00a999989a9898888989000000
0000002222222222222888882200000006666566655666d00dddddddd6dd11100000000000000000060000000a9899a00a98889aa98889899888898000000009
0000022222222222222228888220000006665656566566d00dddd6ddd666d11000000000000000000600000000a989a000a989900a99889a0888888900000000
0000222222222222222222888821000066666566566566dddddd6ddddddd111100000000000000000600000000099a000a9999a0a99898909089898a99000098
000222222222e222222222288821100066666666655666d5dddd6ddddddd1111666666660000006606000000000aa000000aaa00aa99999a9a98889980900009
002222222eeee22222eeee22888111006666666666666d5ddddddddddd66111100000000000000060600000000000000000000000aaa09a009a909a009009080
00222222eeee22222eeee222888111006666666666556dd5dd666dddd66d1d110020100d00e0200c000000000000e20000000000000000000000000000000000
0222222eeee22222eeee2222888111106666556665665dddddddddddddd11d11d00002222220000003b3b00000000e2000000000000000000000000000000000
022222eeee22222eeee222222881111066656656656d5dddddddd66ddd111111000222eeee222010003b3b000000e2000080800006dddd600d666d000d666d00
022222eee222222eee22222222211110066566566655ddd00dddd6ddd11111102022eeecceee220e0003b3b00e2000000878880056cc776606757600067dd600
22222eee222222eee222222222111111066655ddddddddd00dddd6d1111d1110002eeccccccee200003b3b0000e200000888880055cccc56065bb60006957600
22222eee222222eee22222228811111100dddddd5ddddd00001111111ddd1100022ecc1111cce22003b3b0000e200e200088800005dddd5006757600067dd600
22222eee222222ee2222228888111181000dddd5d5ddd000000111111111100002eec110011cee2000000000000000e200080000000000000d666d000d666d00
222222ee222222ee222228888211118800000ddd5dd00000000001111110000002ecc100001cce210000000000000e2000000000000000000000000000000000
2222222e222222e2222288882211111800000dd8ddd0000000000eeeeee0000002ecc100001cce20000000000000000000000000000000000000000000000000
22882222222222e22228882221111118000ddd8dddddd000000ee8eeeeeee000d2eec110011cee20000000000000000000000000000000000000000000000000
2288822222222222222882222ee1111100ddd8988ddd850000eee88eeeeeee00022ecc1111cce22e0a0a77000000000000999000000600000004900000067000
2228822222222222222222222ee111110ddddd8dd8d885500eeeee8888eeee20002eeccccccee2000a9aaa70000aaa0000908800005560000044490000667700
022888888888222222222222eee111100dd8dd8dddd885500eeeeeeee88eee200022eeecceee220209499aa0000a990000a00800000556000044490000677700
02222888888222222222222eee111110ddd8dddddd888855eeeeee8eee8eee22e00222eeee222000090999000006660000aaa800005606000004400000077000
02222222222222222222221ee1111110dd88ddddd899a855eeee8e8eee8ee82202000222222000c0000000000000000000000000000000000000000000000000
002222222222222222221eeee1111100d8998dddd8999885eee88e88ee8ee822000100e0c00d2000000000000000000000000000000000000000000000000000
002222222eeeeee221eeeeee11111100d89988ddd89a9888eee8eee8eeee28220000000000000000000000000000000000c0000000c000000000000000000000
00022222221eeeeeeeeeeee111111000dd88dd888d888855ee88eee88eee2222000000000d5555d0000000000000000000000000010201000000000000000000
00001111111eeeeeeeeeee1111110000dd88dd88ddd85855ee8eeeee8ee228220009a000056666500001c00000067000000e0100002e20c00000000000000000
000001111111111111111111111000000d8ddd898d5585500eeeeeeeee8888200099aa000566555000111c0000667700c022e0000222e2000000000000000000
000000111111111111111111110000000dddddd8555855500eee8ee228822220009aaa000555665000111c000067770000022e00c02220000000000000000000
000000011111111111111ee11000000000555585555555000022888222222200000aa000056666500001100000077000012e0e00010200100000000000000000
000000000111111111eeee800000000000055585555550000002222222222000000000000d5555d00000000000000000000010c0000c00000000000000000000
0000000000001111188800000000000000000555555000000000022222200000000000000000000000000000000000000c000000000001000000000000000000
00000000000000000000000000000000000000000000000c0000007c00000000006000000006000000dd0000000000000000000000000000000000000000d000
0000000000000000000000000000000c0000000c0000007c000007cc000000000859a00000859a000859a000000000000000000000000000000050000005d000
00000000000000c0000000c0000000c0000000c0000000c0000007c000008800006000000006000000dd000000055000000550000000d0000005550000ddd500
000000000000000000000000000000c000000cc0000007c000007cc0000089800000000000000600000000000055000000555500055dd9a00055dd9a085d559a
00000000000000000000000000000000000000c000000cc000007cc000008998000060000000859a0000dd0008dd59a00880d9a000885d00088d0000085d559a
00000000000000c0000000c0000000c0000000c0000000c0000007c000008980000859a006000600000859a00055000000555500055dd9a00055dd9a00ddd500
00000000000000000000000c0000000c000000cc000000cc000007cc0000880000006000859a00000000dd0000055000000550000000d000000555000005d000
000000000000000000000000000000000000000c0000000c0000007c00000000000000000600000000000000000000000000000000000000000050000000d000
0dd000000000dd000020000000020000002200000000200000000000000000000000000000000000000000000000022009900000990000000000000000000000
d00dd000000ddddd0859a00000859a000829a0000002d0000000050002550000022500000000d22200055dd000dd22209aa90009aa9000000000000000000000
00000d000055d550002000000002000000220000002d550000002205002520000022500000222200002255000225d20009a90009a90000000000000000000000
08dd559a0856659a00000000000002000000000008d259a00022555000255200000225000885dd9a0825d29a8822559a09a90009a90000000000000000000000
08dd559a0856659a000020000000859a0000220008d259a00885229a0882259a0000829a0885dd9a088229a08822559a009a909a900000000000000000000000
00000d000055d550000859a002000200000829a0002d5500002255500025520000022500002222000825d29a0225d200009a909a909900009000990000000000
d00dd000000ddddd00002000859a0000000022000002d0000000220500252000002250000000d2220022550000dd22200009a9a909aa9009a909aa9000000000
0dd000000000dd00000000000200000000000000000020000000050002550000022500000000000000055dd0000002200009a9a99a00a909a909a0a900000000
5566666666666655556666666666665500000000000000000000000220000000ff2f1ffdffef2ffc000000000000000000009a909a00a909a909a0a900000000
5660000000000665566000000000066500000600000060000000022222200000dffff222222fffff000000000000000000009a9009aa9009a909aa9000000000
67000c000000007667000c00000000760006060000006000000222eeee222000fff222eeee222f1f000000000000000000000900009900009000990000000000
77007000000000777700700000000077000dddd0006060000022eeecceee22002f22eeecceee22fe000000000d000d0ddd0dd00ddd0d0d00000d00d0ddd00dd0
700700000000000770070000000000070555555500606000002eeccccccee200ff2eeccccccee2ff000000000dd0dd0d000d0d0d000d0d00000dd0d00d00d000
70c000000000000770c0000000000007566667775ddddd00022ecc1111cce220f22ecc1111cce22f000000000d0d0d0ddd0dd00d000ddd00000d0dd00d000d00
70000000000000077000000000000007566666675555555002eec110011cee20f2eec110011cee2f000000000d000d0d000d0d0d000d0d00000d00d00d0000d0
70000000000000077000000000000007511111115666777522ecc100001cce22f2ecc100001cce21000000000d000d0ddd0d0d0ddd0d0d00000d00d00d00dd00
70000000000000077000000000000007055555556666667522ecc100001cce22f2ecc100001cce2f000000000000000011111111111111111111111111111111
700000000000000770000000000000070056d5444444444502eec110011cee20d2eec110011cee2f000000000000000016166166616616611616616661661661
7000000000000007700000000000000700566d5555555550022ecc1111cce220f22ecc1111cce22e000000000000000016616616661661611661661666166161
7000000000000c077000000000000c070056666666dd5000002eeccccccee200ff2eeccccccee2ff000000000000000000000000000000000000000000000000
7000000000007007700000000000700700055555555500000022eeecceee2200ff22eeecceee22f2000000000000000000000000000000000000000000000000
60000000000c000660000000000c0006000000ddddd00000000222eeee222000eff222eeee222fff000000000000000000000000000000000000000000000000
6600000000000066660000000000006600000006060000000000022222200000f2fff222222fffcf000000000000000000000000000000000000000000000000
6666666666666666666666666666666600000000060000000000000220000000fff1ffefcffd2fff000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000066000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000066000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660066000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660066000000000000660000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000
00000000000dddddddd0000006600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dddddddd0000006600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005555555555555500006600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005555555555555500006670660007000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000
00000556666666677777755dddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000556666666677777755dddddddddd00000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000
00000556666666666667755555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000556666666666667755555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000551111111111111155666666777777550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000551111111111111155666666777777550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005555555555555566666666666677550000099990000000000999900000000000000000000000000000000000000000000000000000000000000000000
00000005555555555555566666666666677550000099990000000000999900000000000000000000000000000000000000000000000000000000000000000000
0000000005566dd554444444444444444445500099aaaa9900000099aaaa99000000000000000000000000000000000000000666666000000000000000000000
0000000005566dd554444444444444444445500099aaaa9900000099aaaa99000000000000000000000000000000000000066666666660000000000000000000
000000000556666dd555555555555555555000000099aa9900000099aa9900000000000000000000000000000000000000666666666666000000000000000000
000000000556666dd555555555555555555000000099aa9900000099aa9900000700000000000000000000000000000006666566655666600000000000000000
0000000005566666666666666dddd550000000000099aa9900000099aa9900000000000000000000000000000000000006665656566566600000000000000000
0000000005566666666666666dddd550000000000099aa9900000099aa9900000000000000000000000000000000000066666566566566660000000000000000
0000000000055555555555555555500000000000000099aa990099aa990000000000000000000000000000000000000066666666655666650000000000000000
0000000000055555555555555555500000000000000099aa990099aa990000000000000000000000000000000000000066666666666666560000000000000000
00000000000000000dddddddddd0000000000000000099aa990099aa990099990000000099000000999900000000000066666666665566650000000000000000
00000000000000000dddddddddd0000000000000000099aa990099aa990099990000000099000000999900000000000066665566656656660000000000000000
000000000000000000066006600000000000000000000099aa99aa990099aaaa99000099aa990099aaaa99000000000066656656656656660000000000000000
000000000000000000066076600000000000000000000099aa99aa990099aaaa99000099aa990099aaaa99000000000006656656665566600000000000000000
000000000000000000000006600000000000000000000099aa99aa9999aa0000aa990099aa990099aa00aa990000000006665566666666600000000000000000
000000000000000000000006600000000000000000000099aa99aa9999aa0000aa990099aa990099aa00aa990000000000666666566666000000000000000000
00000000000000000000000000000000000000000000000099aa990099aa0000aa990099aa990099aa00aa990000000000066665656660000000000000000000
00000000000000000000000000000000000000000000000099aa990099aa0000aa990099aa990099aa00aa990000000000000666566000000000000000000000
00000000000000000000000000000000000000000000000099aa99000099aaaa99000099aa990099aaaa99000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000099aa99000099aaaa99000099aa990099aaaa99000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000990000000099990000000099000000999900000000000000000000000000000000000000000000
00000000000000000000000000000070000000000000000000990000000099990000000099000000999900000000000000000000000000000000000000000000
00000000000000000000000000dd000000dd00dddddd00dddd0000dddddd00dd00dd00dddddd00dd0000dd00dddddd0000dddd00000000000000000000000000
00000000000000000000000000dd000000dd00dddddd00dddd0000dddddd00dd00dd00dddddd00dd0000dd00dddddd0000dddd00000000000000000000000000
00000000000000000000000000dddd00dddd00dd000000dd00dd00dd000000dd00dd00dd00dd00dddd00dd0000dd0000dd000000000000000000000000000000
00000000000000000000000000dddd00dddd00dd000000dd00dd00dd000000dd00dd00dd00dd00dddd00dd0000dd0000dd000000000000000000000000000000
00000000000000000000000000dd00dd00dd00dddddd00dddd0000dd000000dddddd00dddddd00dd00dddd0000dd000000dd0000000000000000000000000000
00000000000000000000000000dd00dd00dd00dddddd00dddd0000dd000000dddddd00dddddd00dd00dddd0000dd000000dd0000000000000000000000000000
00000000000000000000000000dd000000dd00dd000000dd00dd00dd000000dd00dd00dd00dd00dd0000dd0000dd00000000dd00000000000000000000000000
00000000000000000000000000dd000000dd00dd000000dd00dd00dd000000dd00dd00dd00dd00dd0000dd0000dd00000000dd00000000000000000000070000
00000000000000000000000000dd000000dd00dddddd00dd00dd00dddddd00dd00dd00dd00dd00dd0000dd0000dd0000dddd0700000000000000000000000000
00000000000000000000000000dd000000dd00dddddd00dd00dd00dddddd00dd00dd00dd00dd00dd0000dd0000dd0000dddd0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000
00000000000000000000000000000000000000000000000000002200110000dd0000ee00220000cc000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000002200110000dd0000ee00220000cc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd000000002222222222220000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd000000002222222222220000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000222222eeeeeeee222222001100000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000222222eeeeeeee222222001100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000022002222eeeeeecccceeeeee222200ee000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000022002222eeeeeecccceeeeee222200ee000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000022eeeecccccccccccceeee220000000000000000000000000000000000000000000000000000
000000000000070000000000000000000000000000000000000022eeeecccccccccccceeee220000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000002222eecccc11111111ccccee222200000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000002222eecccc11111111ccccee222200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022eeeecc111100001111cceeee2200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022eeeecc111100001111cceeee2200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022eecccc110000000011ccccee2211000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022eecccc110000000011ccccee2211000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022eecccc110000000011ccccee2200000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022eecccc110000000011ccccee2200000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd22eeeecc111100001111cceeee2200000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd22eeeecc111100001111cceeee2200000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000002222eecccc11111111ccccee2222ee000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000002222eecccc11111111ccccee2222ee000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000022eeeecccccccccccceeee220000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000022eeeecccccccccccceeee220000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000002222eeeeeecccceeeeee22220022000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000002222eeeeeecccceeeeee22220022000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ee0000222222eeeeeeee222222000000000000000000000000000000000000000000000000000000
000000000000000007000000000000000000000000000000ee0000222222eeeeeeee222222000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022000000222222222222000000cc00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000022000000222222222222000000cc00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000110000ee00cc0000dd22000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000110000ee00cc0000dd22000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000dd0000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a99a0000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a9899a000000000000000000000
0000000000000000000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000a989a000000000000000000000
0000000000000000000005556d000000000000000000000000000000000000000000000000000000000000000000000b000000099a0000000000000000000000
00000000000000000000a985ccd0000000000000000000000000000000000000000000000000000000000000000000b0b000000aa00000000000000000000000
0000000000000000000005556d000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000000000000000
0000000000000000000000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000500001f353226531e3531d65318353166531434311643123430f6430b343086230732303623043230261302313006130131300613003130230302303033030230301303013030030300302003020130201300
0010000037620266201c65015650116500e6500c6500a650086500565003650026500065000640006400064000630006300063000620006200062000610006100061000610006000060000600006000060000600
34200020307103271033710377103a71037710327102e710307103271033710377103a71037710337103271030710327103771030710327103771030710327103071032710377103a7103c7103a7103771035710
001000001835318333183131830329303293030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000800002c3532a353293332931329303293030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000d4530d453213031e3031e3031e3031e3031e3031e3030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000500001f30322603226032260322603226032260322603226032260322603226032260322603226032260322603226032260322603226032260322603226032260322603226032260322602226022260222600
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


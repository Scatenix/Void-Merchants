__lua__1
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
-- 17 sell / money pickup
-- 18 land
-- 19 hyper space thrusters
-- 20 step out of hyperspace
-- 21 buy
-- 22 spawn in enemies
-- 23 cannot perform action (used at trading)

-- needed to save and load the game (saving at trader, loading at titlescreen)
-- this is a hash of this cartridge at some point. should be pretty unique
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
				pl_ship_x -= 0.15
			end
		end
		travel_from_battle_animation_script()
	elseif titlescreen_mode then
		if init_titlescreen then
			init_titlescreen = false
			
			-- set ship and drone
			pl_ship_x = 20
			pl_ship_y = 96
			
			add_enemy(flr(rnd(7)) + 14)
			-- set x, y, life, shield, speed, wobble_state
			enemies[1][1] = 100
			enemies[1][2] = 96
			enemies[1][7] = 1
			enemies[1][8] = 0
			enemies[1][11] = 1
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

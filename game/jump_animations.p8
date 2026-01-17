__lua__12
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
		music(0)
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
		-- music(2)
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
		music(2)
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

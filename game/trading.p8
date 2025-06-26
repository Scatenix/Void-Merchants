__lua__18
-- trading
black_hole_x = 0

function trading_script()
	if trading_phase == 5 and time() - tme >= 5 then -- 30
		all_stars_speed_ctrl(1)
		trading_mode = false
		battle_mode = true
		init_battle = true
		show_trader_station_near = false
		show_trader_station_far = false
		trading_phase = 0
	elseif trading_phase == 4 and not pause_on_text then
		-- send back to trading station
		skip_void = true
		stars_hide = false
		trading_phase = 0
	elseif trading_phase == 3 and time() - tme >= 11.5  then -- 12 then
		pause_on_text = true
		stars_hide = true
		trading_phase = 4
	elseif trading_phase == 2 and time() - tme >= 10 then -- 10.5
		trading_phase = 3
		conv_partner = 2
		conv_text_1 = "missing text"
		conv_text_2 = ""
		cong_text_3 = ""
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


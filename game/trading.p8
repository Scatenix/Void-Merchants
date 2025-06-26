__lua__18
-- trading
black_hole_x = 0
trade_finished = false
trade_cursor_pos = 0
selling_upgrades_multiplier = 0.8
price_per_ship_hull_point = 5

function trading_script()
	if trading_phase == 5 and time() - tme >= 5 then -- 30
		all_stars_speed_ctrl(1)
		trading_mode = false
		battle_mode = true
		init_battle = true
		show_trader_station_near = false
		show_trader_station_far = false
		trading_phase = 0
		trade_finished = false
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
		if not trade_finished then
		-- trade
		-- ...
		-- trade_finished = true
			trade()
			show_battle_stats = true
		else
			show_battle_stats = false
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

	-- extra dots for vertical bars
	-- line(0, 7, 0, 7, 6)
	-- line(127, 7, 127, 7, 6)
	
	print("leave", 10, 4, 9)
	spr(credit[1], 98, 2)
	print(" " ..pl_credits, 104, 4, 10)
	spr(parts_crate[1], 98, 10)
	print(" " ..#pl_items_stored, 104, 12, 13)
	print("sell your goods", 10, 12, 7)
	print("(" ..calc_player_goods_price(false).. ")", 71, 12, 10)

	print("sell your upgrades", 10, 20, 7)
	print("(" ..calc_player_upgrades_price(false).. ")", 83, 20, 10)

	print("repair ship hull ", 10, 28, 7)
	print("(" ..(pl_ship_max_life-pl_ship_life)*price_per_ship_hull_point.. ")", 75, 28, 10)
	
	print("repair drones", 10, 36, 7)
	print("restore ship shield point", 10, 44, 7)
	print("restore drone shield point", 10, 52, 7)
	print("install stored upgrades", 10, 60, 7)
	print("install stronger weapons", 10, 68, 7)
	print("install new weapon", 10, 76, 7)
	print("buy drone", 10, 84, 7)
	if drone_type == 0 then
		print("convert drones to cargo", 10, 92, 7)
	elseif drone_type == 1 then
		print("convert drones to attack", 10, 92, 7)
	end

	print("❎", 2, 4 + 8*trade_cursor_pos, 13)
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
	if btnp(5) then
		if trade_cursor_pos == 0 then -- leave
			trade_finished = true
		elseif trade_cursor_pos == 1 then -- sell all goods
			local price = calc_player_goods_price(true)
			if price == 0 then
				sfx(23)
			end
		elseif trade_cursor_pos == 2 then -- sell all upgrades
			price = calc_player_upgrades_price(true)
			if price == 0 then
				sfx(23)
			end
		elseif trade_cursor_pos == 3 then -- repair ship hull
			local price = (pl_ship_max_life-pl_ship_life)*price_per_ship_hull_point
			if pl_ship_max_life-pl_ship_life > 0 and pl_credits >= price then
				pl_ship_life = pl_ship_max_life
				pl_credits -= price
				sfx(10)
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 4 then -- repair drones
		elseif trade_cursor_pos == 5 then -- restore ship shield point
		elseif trade_cursor_pos == 6 then -- restore drone shield point
		elseif trade_cursor_pos == 7 then -- install stored upgrades
		elseif trade_cursor_pos == 8 then -- install stronger weapons
		elseif trade_cursor_pos == 9 then -- install new weapon
		elseif trade_cursor_pos == 10 then -- buy drone
		elseif trade_cursor_pos == 11 then -- convert drones
		end
	end
end

-- if sell = true, sell items directly
function calc_player_goods_price(sell)
	local price = 0
	for item in all(pl_items_stored) do
		if item[1] >= 173 then
			price += item[2]
			if sell then
				sfx(17)
				del(pl_items_stored, item)
			end
		end
	end
	if sell then
		pl_credits += price
	end
	return price
end

-- if sell = true, sell items directly
function calc_player_upgrades_price(sell)
	local price = 0
	for item in all(pl_items_stored) do
		if item[1] >= 158 and item[1] <= 170 then 
			price += ceil(item[2] * selling_upgrades_multiplier)
			if sell then
				sfx(17)
				del(pl_items_stored, item)
			end
		end
	end
	if sell then
		pl_credits += price
	end
	return price
end

-->8

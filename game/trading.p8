__lua__17
-- trading
black_hole_x = 0
trade_finished = false
trade_cursor_pos = 0
selling_upgrades_multiplier = 0.8
price_per_ship_hull_point = 5
price_per_drone_hull_point = 10
price_increase_per_weapon = 50
price_increase_per_drone = 100
price_increase_per_weapon_dmg = 50
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
		if not trade_finished then
			stars_hide = true
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

	if drone_life < drone_max_life then
		print("repair drones", 10, 28, 7)
		print("(" ..(drone_max_life-drone_life)*price_per_drone_hull_point.. ")", 63, 28, 10)
	else
		print("repair drones", 10, 28, 5)
	end

	if pl_ship_shields < pl_ship_max_shield then
		print("restore ship shield", 10, 36, 7)
		print("(" ..(pl_ship_max_shield-pl_ship_shields)*price_per_ship_shield.. ")", 87, 36, 10)
	else
		print("restore ship shield", 10, 36, 5)
	end

	if drone_shields < drone_max_shields then
		print("restore drone shield", 10, 44, 7)
		print("(" ..(drone_max_shields-drone_shields)*price_per_drone_shield.. ")", 91, 44, 10)
	else
		print("restore drone shield", 10, 44, 5)
	end

	if get_number_of_stored_upgrades(false) > 0 then
		print("install stored upgrades", 10, 52, 7)
		print("(" ..get_number_of_stored_upgrades(false).. ")", 103, 52, 10)
	else
		print("install stored upgrades", 10, 52, 5)
	end

	if pl_ship_damage-pl_ship_base_damage < max_pl_extra_damage then
		print("install stronger weapons", 10, 60, 7)
		print("(" ..attack_damage_inc[2]+price_increase_per_weapon_dmg*pl_ship_damage.. ")", 107, 60, 10)
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
	if btnp(4) then
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
			if drone_max_life-drone_life > 0 and pl_credits >= price then
				drone_life = drone_max_life
				pl_credits -= price
				sfx(10)
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 4 then -- restore ship shield point
			price = (pl_ship_max_shield-pl_ship_shields)*price_per_ship_shield
			if pl_ship_shields < pl_ship_max_shield and pl_credits >= price then
				pl_ship_shields += 1
				sfx(12)
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 5 then -- restore drone shield point
			price = (drone_max_shields-drone_shields)*price_per_drone_shield
			if drone_shields < drone_max_shields and pl_credits >= price then
				drone_shields += 1
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
			local price = attack_damage_inc[2]+price_increase_per_weapon_dmg*pl_ship_damage
			if pl_ship_damage-pl_ship_base_damage < max_pl_extra_damage and pl_credits >= price then
				sfx(11)
				pl_ship_damage += 1
				pl_ship_damage_upgrades += 1
				pl_credits -= price
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 8 then -- install new weapon
			local price = weapons_inc[2]+price_increase_per_weapon*(pl_ship_weapons+drone_weapons)
			if pl_ship_weapons < max_pl_weapons and pl_credits >= price then
				sfx(11)
				pl_ship_weapons += 1
				pl_credits -= price
			elseif drone_weapons < max_dr_weapons and pl_credits >= price then
				sfx(11)
				drone_weapons += 1
				pl_credits -= price
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 9 then -- buy drone
			price = drone_inc[2]+price_increase_per_drone*drone_tier
			if drone_tier < max_drones and pl_credits >= price then
				sfx(11)
				drone_tier+=1
				drone_available = true
				set_pl_drone(drone_tier)
				pl_credits -= price
			else
				sfx(23)
			end
		elseif trade_cursor_pos == 10 then -- convert drones
			dl = drone_life
			ds = drone_shields
			if drone_type_attack then
				max_drones = 3
				drone_tier = min(3, drone_tier)
				drone_type_attack = not drone_type_attack
				set_pl_drone(drone_tier)
			else
				max_drones = 6
				drone_type_attack = not drone_type_attack
				set_pl_drone(drone_tier)
			end
			sfx(12)
			drone_life = dl
			drone_shields = ds
		elseif trade_cursor_pos == 11 then -- leave
			trade_finished = true
			all_stars_speed_ctrl(0.2)
			stars_hide = false
		end
	end
end

-- if sell = true, sell items directly
function calc_player_goods_price(sell)
	local price = 0
	for item in all(pl_items_stored) do
		if item[1] > 172 then
			price += item[2]
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
				or (item[1] == attack_damage_inc[1] and pl_ship_damage-pl_ship_base_damage >= max_pl_extra_damage)
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

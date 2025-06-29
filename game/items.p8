__lua__9
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

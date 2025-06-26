__lua__9
-- items

floating_items = {}

-- buffs are at 154 to 157
-- upgrades are at 158 to 170
-- credits are at 171 to 172
-- trading goods are at 173 to 189

-- buff {sprite, price, name}
speed_buff = {154, 0, "speed buff"}
shot_speed_buff = {155, 0, "shot speed buff"}
life_up = {156, 0, "life up"}
shield_up = {157, 50, "shield up"} -- can only be bought

-- stat increases {sprite, price, name}
attack_damage_inc = {158, 50, "damage upgrade"}
drone_inc = {159, 100, "drone upgrade"}
weapons_inc = {170, 50, "weapon upgrade"}

-- trading items {sprite, price, name}
credit = {171, 1, "credit"}
scrap = {173, 10, "scrap"}
copper = {174, 20, "copper"}
gold = {184, 40, "gold"}
parts_crate = {185, 50, "parts crate"}
cobalt = {186, 65, "cobalt"}
platinum = {187, 80, "platinum"}
void_fragment = {188, 100, "void fragment"}
super_credit = {172, 100, "super credit"}
void_crystal = {189, 200, "void crystal"}

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
			pl_ship_speed *= 2
			pl_ship_speed_buff_time = time()
			del(floating_items, item)
		end
	elseif item[3] == shot_speed_buff[1] then
		if pl_ship_shot_speed_buff_time == 0 then
			sfx(4)
			pl_ship_shot_speed *= 2
			pl_ship_shot_speed_buff_time = time()
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
		end
	elseif item[3] == attack_damage_inc[1] then
		if pl_ship_damage-pl_ship_base_damage < max_pl_extra_damage then
			sfx(11)
			pl_ship_damage += 1
			del(floating_items, item)
		else
			store_item(item, attack_damage_inc[2])
		end
	elseif item[3] == drone_inc[1] then
		if drone_tier < max_drones then
			sfx(11)
			drone_tier+=1
			set_pl_drone(drone_tier)
			del(floating_items, item)
		else
			store_item(item, drone_inc[2])
		end
	elseif item[3] == weapons_inc[1] then
		if pl_ship_weapons < max_pl_dr_weapons then
			sfx(11)
			pl_ship_weapons+=1
			del(floating_items, item)
		elseif drone_weapons < max_pl_dr_weapons then
			sfx(11)
			drone_weapons+=1
			del(floating_items, item)
		else
			store_item(item, drone_inc[2])
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
		store_item(item, super_credit[2])
	end
end

function add_money_pickup(money)
	add(money_pickups, {credit[2], pl_ship_x, pl_ship_y, money_pickup_animation_frames})
end

function speed_buff_timer()
	if pl_ship_speed_buff_time > 0 then
		local delta = time() - pl_ship_speed_buff_time
		if delta >= speed_buff_time then
			sfx(9, -2)
			pl_ship_speed = pl_ship_default_speed
			pl_ship_speed_buff_time = 0
		end
	end
end

function shot_speed_buff_timer()
	if pl_ship_shot_speed_buff_time > 0 then
		local delta = time() - pl_ship_shot_speed_buff_time
		if delta >= shot_speed_buff_time then
			sfx(4, -2)
			pl_ship_shot_speed = pl_ship_default_shot_speed
			pl_ship_shot_speed_buff_time = 0
		end
	end
end

function reset_buffs()
	sfx(9, -2)
	sfx(4, -2)
	pl_ship_speed = pl_ship_default_speed
	pl_ship_speed_buff_time = 0
	pl_ship_shot_speed = pl_ship_default_shot_speed
	pl_ship_shot_speed_buff_time = 0
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
	elseif num >=910 then --2,5%
		return platinum
	elseif num >=880 then --3%
		return life_up
	elseif num >=850 then --3%
		return cobalt
	elseif num >=815 then --3,5%
		return parts_crate
	elseif num >=775 then --4%
		return gold
	elseif num >=725 then --5%
		return speed_buff
	elseif num >=665 then --6%
		return copper
	elseif num >=595 then --7%
		return shot_speed_buff
	elseif num >=490 then --10,5%
		return scrap
	elseif num >=390 then --10%
		return credit
	else --39%
		return {-1, 0, "nothing"} -- no drop
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

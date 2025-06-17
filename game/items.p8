__lua__9
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

__lua__9
-- items

floating_items = {}

-- buff
speed_buff = 184
shot_speed_buff = 185
life_up = 170

-- stat increases
attack_damage_inc = 186
drone_inc = 159

-- trading items
crate = 154
scrap = 155
void_crystal = 157
gold = 1
copper = 1
platinum = 1
void_fragment = 1
cobalt = 1

function add_floating_item(item_type, x, y)
	item = {}
	item[1] = x
	item[2] = y
	-- sprite and id
	item[3] = item_type
	add(floating_items, item) 
end

function interpret_item(item_type)
	if item_type == speed_buff then
		pl_ship_speed *= 2
	elseif item_type == shot_speed_buff then




	end
end

function calculate_floating_items_drift()
	for item in all(floating_items) do
		item[1] -= 0.25

		if long_adhs_counter == 50 then
			item[2] = item[2] - 1
		elseif long_adhs_counter == 100 then
			item[2] = item[2] + 1
		end
	end
end

function draw_floating_items()
	for item in all(floating_items) do
		spr(item[3], item[1], item[2])	
	end
end
-->8

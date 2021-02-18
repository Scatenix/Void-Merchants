__lua__9
-- items

floating_items = {}

speed_buff = 184
shot_speed_buff = 185

function add_floating_item(item_type, x, y)
	item = {}
	item[1] = x
	item[2] = y
	-- sprite and id
	item[3] = item_type
	-- item wobble
	item[4] = 1
	add(floating_items, item) 
end

function calculate_floating_items_drift()
	for item in all(floating_items) do
		item[1] -= 0.25
		item[2] -= item[4]
		item[4] = item[4]*-1
	end
end

function draw_floating_items()
	for item in all(floating_items) do
		spr(item[3], item[1], item[2])	
	end
end
-->8

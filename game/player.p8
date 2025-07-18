__lua__4
-- player

function add_credits(credits)
	pl_credits += credits
	if pl_credits > 9999 then
		pl_credits = 9999
	end
end

function store_item(item, price)
	if get_free_storage() > 0 then
		sfx(6)
		add(pl_items_stored, {item[3], price})
		del(floating_items, item)
	end
end

function drop_items_when_drone_dies()
	for i=#pl_items_stored, pl_ship_storage+1, -1 do
		add_floating_item(pl_items_stored[i][1], drone_x - 6*(i-pl_ship_storage-1) , drone_y - 4 + rnd(8), pl_items_stored[i][2])
		deli(pl_items_stored, i)
	end
end

function get_free_storage()
	return pl_ship_storage + drone_storage - #pl_items_stored
end

function get_max_storage()
	return pl_ship_storage + drone_storage
end
-->8

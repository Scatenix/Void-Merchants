__lua__6
-- player drones

drone_tier = 0
drone_x = 0
drone_y = 0
drone_offset_y = 0
drone_offset_x = 0
drone_hitbox_skip_pixel = 8
drone_hitbox_width = 0
drone_sprite = 48
drone_damage = 0
drone_weapons = 0
drone_life = 0
drone_max_life = 0
drone_shields = 0
drone_max_shields = 0
drone_storage = 0
drone_available = false
-- 0: attack; 1: cargo
drone_type_attack = true

function set_pl_drone(tier)
	if tier == 1 and drone_available then
		drone_weapons = 1
	end

	drone_tier = tier
	if tier == 0 then
		drone_available = false
		drone_sprite = 48
		drone_storage = 0
		drone_weapons = 0
		drone_damage = 0
		drone_shields = 0
		max_dr_weapons = 0
	-- get attack drone
	elseif tier >= 0 and tier <= 6 and drone_type_attack then
		drone_sprite = 48 + tier
		htbx = get_drone_htbx_skp_pxl_width(tier)
		drone_hitbox_skip_pixel = htbx[1]
		drone_hitbox_width = htbx[2]
		drone_damage = tier + 1
		drone_life = 4 * tier
		drone_max_life = 4 * tier
		drone_shields = tier
		drone_max_shields = tier
		drone_storage = tier
		drone_available = true
		max_dr_weapons = min(tier, 5)
	-- get storage drone
	elseif tier >= 0 and tier <= 3 and not drone_type_attack then
		drone_sprite = 5 + tier
		htbx = get_drone_htbx_skp_pxl_width(tier)
		drone_hitbox_skip_pixel = htbx[1]
		drone_hitbox_width = htbx[2]
		drone_damage = 0
		drone_life = 12 * tier
		drone_max_life = 12 * tier
		drone_shields = tier * 2
		drone_max_shields = tier * 2
		drone_storage = tier * 3
		drone_available = true
		drone_weapons = 0
		max_dr_weapons = 0
	end
end

-- {y start of drone on sprite, y width of drone}
function get_drone_htbx_skp_pxl_width(tier)
	if not drone_type_attack and tier == 1 then
		return {3, 4}
	elseif tier == 1 then
 		return {3, 3}
	elseif tier == 2 then
		return {1, 6}
	elseif tier == 3 or tier == 5 or tier == 6 then
		return {1, 7}
	elseif tier == 4 then
		return {2, 5}
	end
end

function drone_ctrl()
	if pl_ship_y < 7 then
		drone_offset_y = 1.5 * (pl_ship_y - 7)
		drone_offset_x = flr(drone_offset_y / 1.5)
		if drone_offset_x < -5 then
	  		drone_offset_x = 0 - pl_ship_y * 2
		end
	else
		drone_offset_y = 0
		drone_offset_x = 0
	end
	
	-- 11 is the distance to the last possible pixel of all drones to the ship back
	if pl_ship_x <= x_left_boundry + 11 then
		drone_offset_x = x_left_boundry + 11 - pl_ship_x
	end

	drone_x = pl_ship_x-11+drone_offset_x
	
	if animation_counter <= 10 then
		drone_y = pl_ship_y-4 - drone_offset_y
	elseif animation_counter > 10 then
	 	drone_y = pl_ship_y-5 - drone_offset_y
	end
end

function get_drone_life_as_string()
	local drone_life_string = ""
	if drone_life < 4 then
		for i = 1, drone_life do
			drone_life_string = drone_life_string .. "♥"
		end
	else
		drone_life_string = " " .. drone_life
	end
	return drone_life_string
end

function kill_drone()
	drop_items_when_drone_dies()
	set_pl_drone(0)
end
-->8

__lua__12
-- data_ops

saved = false

function save_game_exists()
	if dget(0) > 0 then
		return true
	end
	return false
end

function reset_save_game()
	for i=0, 64 do
		dset(i, 0)
	end
end

function save_game()
	reset_save_game()
	dset(0, level)
	dset(1, pl_credits)
	dset(2, pl_ship_weapons)
	dset(3, pl_ship_tier)
	dset(4, pl_ship_damage_upgrades)
	dset(5, pl_ship_life)
	dset(6, pl_ship_shields)
	dset(7, drone_tier)
	dset(8, drone_life)
	dset(9, drone_shields)
	dset(10, drone_weapons)
	dset(11, max_drones)
	if drone_type_attack then dset(12, 1) end
	dset(13, negative_score)

	-- for loop for stored items + sprite, saved to slot 20-60 (max stg: 14 * 2 + buffer)
	j = 20
	for item in all(pl_items_stored) do
		dset(j, item[1])
		dset(j+1, item[2])
		j += 2
	end
	saved = true
	sfx(11)
end

function load_game()
	enemies = {}
	titlescreen_mode = false
	prevent_enemy_moving_on_x = false
	trading_mode = true

	level = dget(0)
	pl_credits = dget(1)
	pl_ship_weapons = dget(2)
	pl_ship_tier = dget(3)
	pl_ship_damage_upgrades = dget(4)
	set_pl_ship(pl_ship_tier)
	pl_ship_life = dget(5)
	pl_ship_shields = dget(6)
	max_drones = dget(11)
	drone_tier = dget(7)
	drone_type_attack = dget(12) == 1
	set_pl_drone(drone_tier)
	drone_life = dget(8)
	drone_shields = dget(9)
	drone_weapons = dget(10)
	negative_score = dget(13) - 100

	-- for loop for stored items + sprite, saved to slot 20-60 (max stg: 14 * 2 + buffer)
	for i = 20, 60, 2 do
		if dget(i) ~= 0 then
			add(pl_items_stored, {dget(i), dget(i+1)})
		end
	end

	-- doing this to save negative_score permanently
	save_game()

	sfx(11)
end
-->8

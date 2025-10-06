__lua__10
-- common

function clear_screen()
 	rectfill(0, 0, 128, 128, 0)
end

function create_hitmarker(posx, posy, ship_drone_enemy)
	add(hitmarkers, {posx, posy, 0, ship_drone_enemy})
end
-->8

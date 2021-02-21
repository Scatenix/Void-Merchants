__lua__1
-- main
-- shift + h = ♥

function _init()
	clear_screen()
	
	if show_battle_stats == true then
		stars_max_y = 105
		enemys_max_y = 96
 	else
		stars_max_y = 127
		enemys_max_y = 119
 	end
	
	add_enemy(1)
	add_enemy(1)
	
	
	set_pl_ship(6)
 	add_pl_drone(4)
end



-------------------------------



function _update()
	ship_ctrl()
	drone_ctrl()
	ship_and_drone_shoot()
	friendly_shots_hit_enemy(pl_ship_shots, pl_ship_damage, 1)
	friendly_shots_hit_enemy(drone_shots, drone_damage, 2)
	enemy_shots_hit_friendly(pl_ship_x, pl_ship_y, pl_ship_hitbox_skip_pixle, pl_ship_hitbox_width, 1)
	enemy_shots_hit_friendly(drone_x, drone_y, drone_hitbox_skip_pixle, drone_hitbox_width, 2)
	enemy_shoot()
	ship_burner_calculation()
	calculate_floating_items_drift()
	floating_items_colides_player()

	-- adhs_counter -> used for animations
	if adhs_counter == 21 then
 		adhs_counter = 0
 	end
	adhs_counter+=1

	-- long_adhs_counter -> used for animations with longer runtime
	if long_adhs_counter == 101 then
		long_adhs_counter = 0
	end
	long_adhs_counter+=1
end




-------------------------------




function _draw()
	clear_screen()

	----- debug section
	
--	debug_coords()
--	info(enemy_shot_cooldown)
	
	----------------
	
	if death_screen == true then
		print("you died :c\nwanna play again? :)\nrestart the game!", 30, 30, 10)
	else
		if initial_draw == true then
			init_passing_stars()
			initial_draw = false
		end
		
		draw_passing_stars()
		
		if show_battle_stats then
		 	draw_battle_stats()
		end
	
		draw_floating_items()
		draw_enemys()
		draw_ship()
		draw_drone()
	
		draw_friendly_shots(pl_ship_shots, 11)
		draw_friendly_shots(drone_shots, 12)
		draw_enemy_shots()
		
		draw_hitmarkers()
		draw_explosions()
	end
end


-->8

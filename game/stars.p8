__lua__7
-- stars

star_speed_multiplier = 1
max_stars = 25
min_star_speed = 1
max_star_speed = 5
stars_counter_threshold = 2
stars_counter = 0
stars_max_y = 0
stars = {}

function init_passing_stars()
	for i = 1, max_stars do
		star = {flr(rnd(127)), flr(rnd(stars_max_y)), flr(rnd(max_star_speed-min_star_speed) + min_star_speed) * star_speed_multiplier} 
		add(stars, star)
	end
end

function draw_passing_stars()
	if star_speed_multiplier > 0 then
	 	stars_start_x = 127
	else
	 	stars_start_x = 0
	end

 	if stars_counter >= stars_counter_threshold and max_stars > #stars then
		star = {stars_start_x, flr(rnd(stars_max_y)), flr(rnd(max_star_speed-min_star_speed) + min_star_speed) * star_speed_multiplier}
		add(stars, star)
  		stars_counter = 0
 	end
 	stars_counter += 1
 
	for star in all(stars) do
		-- draw star
		line(star[1], star[2], star[1], star[2], 7)
		star[1] -= star[3]
		if star[1] < 0 or star[1] > 127 then
			del(stars, star)
		end
	end
end

function all_stars_speed_ctrl(speed_multiplier)
	for star in all(stars) do
		star[3] = star[3] * speed_multiplier
	end
	star_speed_multiplier = speed_multiplier
end
-->8

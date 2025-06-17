__lua__2
-- global variables
tme = 0 -- here to track times with time()

level = 1
init_battle = false
show_battle_stats = false
animation_counter = 0
medium_animation_counter = 0
long_animation_counter = 0
x_left_boundry = 2
x_right_boundry = 120
y_up_boundry = 0
y_down_boundry = 97

initial_draw = true
play_sfx = true

speed_buff_time = 4.0
shot_speed_buff_time = 4.0

max_pl_dr_weapons = 5
max_drones = 6
max_pl_extra_damage = 6

battle_mode = false
travel_to_battle_mode = false
travel_after_battle_mode = false
converstaion_mode = false
trading_mode = false
death_mode = false

travel_after_battle_phase = 0
jump_wobble = false
jump_to_hyperspce = false
arrive_in_hyperspace = false
show_trader_station_far = false
show_trader_station_near = false

trading_phase = 0
talk_to_void_creature = false
skip_void = false

current_planet = 1
planets = {
	{80, 0},
	{0, 32},
	{32, 32},
	{64, 32},
	{96, 32},
	{0, 64},
}
current_small_planet = 1

-- number 7 is void creatues portal
small_planets = {
	{112, 0},
	{112, 16},
	{32, 64},
	{48, 64},
	{32, 80},
	{48, 80},
	{64, 72},
}

-- arrays

explosions = {}
hitmarkers = {}
-->8

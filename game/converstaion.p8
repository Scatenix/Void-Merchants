__lua__14
-- converstaion
pause_on_text=false
conv_partner=1 -- 1: trader, 2 void-creature

function advance_textbox()
	if pause_on_text and btn(4) then
		pause_on_text = false
	end
end

function trader_converstaion()
	if level <= 1 then
		conv_text_1 = "oh, a new face..."
		conv_text_2 = "welcome on my trading station!"
		conv_text_3 = "wanna have a look at my wares?"
		conv_text_4 = "or perhaps sell some goods?"
	elseif level < 5 then
		conv_text_1 = "see who it is again!"
		conv_text_2 = "i have restocked my wares"
		conv_text_3 = "while you were out fighting."
		conv_text_4 = "take a look!"
	elseif level < 10 then
		conv_text_1 = "nice you've maded it here!"
		conv_text_2 = "it's dangerous to go alone..."
		conv_text_3 = "make sure you stock up on"
		conv_text_4 = "these drones."
	elseif level < 15 then
		conv_text_1 = "my best customer!"
		conv_text_2 = "come in, come in!"
		conv_text_3 = "looking forward to all that"
		conv_text_4 = "gold and cobalt of yours."
	elseif level < 20 then
		conv_text_1 = "hello, fellow merchant,"
		conv_text_2 = "quite the ship you've got!'"
		conv_text_3 = "time to make it even better."
		conv_text_4 = "your credits are welcome."
	elseif level >= 20 then
		conv_text_1 = "hello my friend!"
		conv_text_2 = "you must be pretty capable!"
		conv_text_3 = "congratulations!"
		conv_text_4 = "let's trade a last time..."
		price = calc_player_goods_price(true)
		price += calc_player_upgrades_price(true)
		add(money_pickups, {price, 25, 50, 150})
		sfx(17)
	end
end

function void_creature_converstaion()
	if level == 5 then
		conv_text_1 = "i have been watching you."
		conv_text_2 = "you are making progress."
		conv_text_3 = "very well... continue..."
		conv_text_4 = "reversing time for you."
	elseif level == 10 then
		conv_text_1 = "you are changing destiny."
		conv_text_2 = "i did not expect that."
		conv_text_3 = "but i am... intrigued."
		conv_text_4 = "let us see where this goes."
	elseif level == 15 then
		conv_text_1 = "you are quite strong..."
		conv_text_2 = "curious..."
		conv_text_3 = "rise and shine, little pilot."
		conv_text_4 = "rise and shine..."
	elseif level == 20 then
		conv_text_1 = "you beat my game. good..."
		conv_text_2 = "i deem you... sufficient."
		conv_text_3 = "your score sums up to " .. max(0, pl_credits - negative_score)
		conv_text_4 = "let us return to the title."
	end
end

-->8

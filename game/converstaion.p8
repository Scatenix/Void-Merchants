__lua__17
-- converstaion
pause_on_text=false
conv_partner=1 -- 1: trader, 2 void-creature
conv_text_1="hello there!"
conv_text_2=""
conv_text_3=""
conv_text_4=""

function advance_textbox()
	if pause_on_text and btn(5) then
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
		conv_text_2 = "make sure you stock up on"
		conv_text_3 = "these drones."
		conv_text_4 = "it's dangerous to go alone..."
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
		conv_text_2 = "you are pretty capable"
		conv_text_3 = "to make it this far."
		conv_text_4 = "prepare for the final battle!"
	end
end

function send_to_void_creature()

end

-->8

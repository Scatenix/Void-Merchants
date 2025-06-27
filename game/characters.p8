__lua__14
-- characters
char_player=56
char_trader=64
char_void=48

noise_dots = {}
-- Draws some randomly appearing particles with the same colors as the black hole
function generate_void_noise(x1, y1, wx2, wy2, amount)
	local colors = {1, 2, 12, 13, 14}
	if animation_counter == 1 then
		noise_dots = {}
		for i=1, amount do
			local x = flr(rnd(wx2)) + x1
			local y = flr(rnd(wy2)) + y1
			local color = colors[flr(rnd(5)) + 1]
			add(noise_dots, {x, y, color})
		end
	end
end
-->8

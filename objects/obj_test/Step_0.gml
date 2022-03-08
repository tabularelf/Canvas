if (keyboard_check_released(vk_space)) {
	surf.Cache();	
}

if (keyboard_check(vk_control)) {
	surf.Start();
	var _offset = (current_time / 1000);
	draw_rectangle_colour(32,32,412,412, make_colour_hsv(_offset  mod 256, 255, 255), make_colour_hsv(_offset * 20  mod 256, 255, 255), make_colour_hsv(_offset * 30  mod 256, 255, 255), make_colour_hsv(_offset * 40  mod 256, 255, 255), false);
}

__prevStatus = surf.GetStatus();
if (surf.GetStatus() == CanvasStatus.IN_USE) {
	surf.Finish();	
}
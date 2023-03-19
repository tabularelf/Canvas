if (keyboard_check_released(vk_space)) {
	surf.Cache();	
}

if (keyboard_check(vk_control)) {
	surf.Start();
	var _offset = (current_time / 1000);
	draw_rectangle_colour(32,32,412,412, make_colour_hsv(_offset  mod 256, 255, 255), make_colour_hsv(_offset * 20  mod 256, 255, 255), make_colour_hsv(_offset * 30  mod 256, 255, 255), make_colour_hsv(_offset * 40  mod 256, 255, 255), false);
}

if (keyboard_check_released(ord("E"))) {
	if (buffer_exists(myBuffer)) {
		buffer_delete(myBuffer);
	}
	myBuffer = surf.GetBufferContents(true);
}

if (keyboard_check_released(ord("W"))) {
	surf.Resize(1024, 1024);	
	surf.Start();
	draw_rectangle_colour(32,32,surf.GetWidth(),surf.GetHeight(), c_red, c_green, c_blue, c_yellow, false);
	surf.Finish();
}

if (keyboard_check_released(ord("Q"))) {
	surf.SetBufferContents(myBuffer, 0, true);
}

if (keyboard_check_released(ord("V"))) {
	surf.CopySurfacePart(application_surface, 0, 0, 0, 0, 256, 256, true, true);	
}

if (keyboard_check_released(ord("G"))) {
	surf.Clear();
}

/*if (keyboard_check_released(ord("O"))) {
	//surf.SaveAsImage("boo.png");	
	var _buff = buffer_load("buffertest.raw");
	surf.SetBufferContents(_buff, 0, true);
	buffer_delete(_buff);
}*/


__prevStatus = surf.GetStatus();
if (surf.GetStatus() == CanvasStatus.IN_USE) {
	surf.Finish();	
}
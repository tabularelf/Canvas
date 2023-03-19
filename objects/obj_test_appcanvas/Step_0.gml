//if (keyboard_check(vk_control)) {
//	canvas.Resize(window_mouse_get_x(), window_mouse_get_y());	
//}

if (keyboard_check_released(vk_space)) {
	canvas.UpdateCache();
	canvas.Cache();	
}

if (keyboard_check_released(ord("E"))) {
	if (buffer_exists(myBuffer)) {
		buffer_delete(myBuffer);
	}
	myBuffer = canvas.GetBufferContents(true);
}

if (keyboard_check_released(ord("W"))) {
	canvas.Resize(1024, 1024);	
	canvas.Start();
	draw_rectangle_colour(32,32,canvas.GetWidth(),canvas.GetHeight(), c_red, c_green, c_blue, c_yellow, false);
	canvas.Finish();
}

if (keyboard_check_released(ord("Q"))) {
	canvas.SetBufferContents(myBuffer);
}

if (keyboard_check_released(ord("V"))) {
	canvas.CopySurfacePart(application_surface, 0, 0, 0, 0, 256, 256, true, true);	
}

if (keyboard_check_released(ord("G"))) {
	canvas.Clear();
}


__prevStatus = canvas.GetStatus();
if (canvas.GetStatus() == CanvasStatus.IN_USE) {
	canvas.Finish();	
}
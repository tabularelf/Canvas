if (keyboard_check(vk_control)) {
	canvas.Start();
	var _offset = (current_time / 1000);
	draw_rectangle_colour(32,32,412,412, make_colour_hsv(_offset  mod 256, 255, 255), make_colour_hsv(_offset * 20  mod 256, 255, 255), make_colour_hsv(_offset * 30  mod 256, 255, 255), make_colour_hsv(_offset * 40  mod 256, 255, 255), false);
	canvas.Finish();
}

//if keyboard_check(vk_space) {
//	if (tempCanvas == undefined) {
//		tempCanvas = CanvasGetAppSurf(true);
//	}
//	tempCanvas.Draw(0, 0);
//} else {
	canvas.Draw(0, 0);	
//}
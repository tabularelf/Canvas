if keyboard_check(vk_space) {
	if (tempCanvas == undefined) {
		tempCanvas = CanvasGetAppSurf(true);
	}
	tempCanvas.Draw(0, 0);
} else {
	canvas.Draw(0, 0);	
}
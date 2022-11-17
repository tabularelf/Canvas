/*
    Get a new Canvas instance containing the currently rendered application surface.
	
	Depending on the moment when you invoke this (EndDraw, EndDrawGui, ...) it will hold different content.
*/

/// @function		GetAppCanvas()
function GetAppCanvas() {
	return new Canvas(
		surface_get_width(application_surface), 
		surface_get_height(application_surface), true)
		.CopySurface(application_surface, 0, 0);
}

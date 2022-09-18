show_debug_overlay(true);
background = layer_background_get_id("Background");
surf = new Canvas(512, 512).WriteToCache(false);
surf.Start();
draw_rectangle_colour(32, 32,surf.GetWidth(),surf.GetHeight(), c_red, c_green, c_blue, c_yellow, false);
surf.Finish();
__prevStatus = 0;
myBuffer = -1;
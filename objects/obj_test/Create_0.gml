show_debug_overlay(true);
surf = new Canvas(512, 512);
surf.Start();
draw_rectangle_colour(32,32,412,412, c_red, c_green, c_blue, c_yellow, false);
surf.Finish();
__prevStatus = 0;
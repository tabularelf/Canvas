show_debug_overlay(true);
surf = new Canvas(512, 512);
surf.Start();
draw_set_alpha(1);
draw_rectangle_colour(32, 32,surf.GetWidth(),surf.GetHeight(), c_red, c_lime, c_blue, c_yellow, false);
draw_set_alpha(1);
surf.Finish();
__prevStatus = 0;
myBuffer = -1;
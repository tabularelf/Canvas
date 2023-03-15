show_debug_overlay(true);
surf = new Canvas(512, 512, false, surface_rg8unorm);
surf.Start();
draw_set_alpha(1);
draw_rectangle_colour(0, 0,surf.GetWidth(),surf.GetHeight(), c_red, c_red, c_red, c_red, false);
draw_set_alpha(1);
surf.Finish();
__prevStatus = 0;
myBuffer = -1;

surf2 = new Canvas(512, 512, false);
surf2.Start();
draw_set_alpha(1);
draw_rectangle_colour(0, 0,surf.GetWidth(),surf.GetHeight(), c_red, c_lime, c_blue, c_yellow, false);
draw_set_alpha(1);
surf2.Finish();
count = 0;

surf.CopyCanvas(surf2, 0, 0, false);
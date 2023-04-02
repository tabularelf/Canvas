var _col = surf.GetFormat() == surface_rgba8unorm ? surf.GetPixel(mouse_x, mouse_y) : 0;
var _col2 = surf.GetPixelArray(mouse_x, mouse_y);
var _bufferSize = surf.GetSize();
var _string = @"Cache Canvas: Space
Update Surface: Control
Resize Surface: W
Get Surface Cache Contents: E (Space for Cached)
Set Surface Cache Contents: Q" + "\nPixel: " + string(mouse_x) + " : " + string(mouse_y) + " : " + string(_col) + " : " + string(_col2);
_string += "\nBufferSize: " + string(_bufferSize);

draw_set_colour(_col != 0 ? _col : c_white);
draw_text(8,8, _string);
# Getting Started

## What is Canvas?

Canvas is in it's simplest description, a non-volatile surface constructor. Canvas achieves this by creating surfaces for you, but also maintains a buffer copy of your surface.
The benefit from this is that you do not need to redraw or recreate the underlying surface each time, as this is premanaged for you. The buffer copy contains a backup of the entire surface per `.Finish()` call (unless auto writing to cache is disabled via `.SetWriteToCache()`) or per `.UpdateCache()` call.

## Installing
1. Download Canvas's .yymp from [releases!](https://github.com/tabularelf/Canvas/releases)
2. With your GameMaker Project, drag the .yymp (or at the top goto Tools -> Import Local Package)
3. Press "Add All" and press "Import".

## Updating to a new version

1. Delete Canvas's folder (with all scripts inside.)
2. Follow the steps through [Installing](#installing), but with the latest version.

## Using Canvas

To begin using Canvas, you first want to initialize a new Canvas. Canvas has two main arguments, as well as two optional arguments.<br>
(See [`Canvas()`](canvas.md#canvas?id=canvaswidth-height-forceinit-surfaceformat) for more.)<br>

We start off by assigning a new Canvas instance to a variable called `surf`, defining it's `width` and `height` to use.
```gml
surf = new Canvas(512, 512);
```
We then take that new Canvas instance, and begin populating it with draw data.
```gml
var _width = surf.GetWidth();
var _height = surf.GetHeight();

surf.Start();
draw_rectangle_colour(0, 0,_width, _height, c_red, c_lime, c_blue, c_yellow, false);
surf.Finish();
```
Now this Canvas instance has written to both the surface and the buffer, any time the surface is lost, calling one of the many Canvas methods that interface with the surface, will refresh the surface from the buffer cache. We can now draw the surface from here.
```gml
surf.Draw(0, 0);
```
To free the Canvas from memory at any time, you would just call `.Free()` to free the surface and buffer contents. 
```gml
surf.Free();
```
The Canvas struct itself will then be garbage collected once dereferenced, or can be reused.
Otherwise, Canvas also contains it's own garbage collector, that works a very small amount inbetween frames, and frees up Canvas instances that have lost all references.
# Canvas v1.1.2
A surface that you can modify & keep the contents, even when the surface should've had been lost, for GameMaker Studio 2.3+!

Join my Discord! https://discord.gg/ThW5exp6r4

Example on usage:
```gml
// Create Event
surf = new Canvas(512, 512);
surf.Start();
var width = surf.GetWidth();
var height = surf.GetHeight();
draw_rectangle_colour(32, 32, width, height, c_red, c_green, c_blue, c_yellow, false);
surf.Finish();

// Draw Event
draw_surface(surf.GetSurfaceID(), 0, 0);
```

# Methods

## `.Start()`<br>
Similar to `surface_set_target()`, but also does some additional preparations to ensure that it can fetch the previous surface data first/initialize the surface.

## `.Finish()`<br>
Similar to `surface_reset_target()`, but also updates the internal cache.

## `.Free()`<br>
Frees the underlying surface and buffers.

## `.CheckSurface()`<br>
Checks up on the surface. This isn't normally needed to be called prior to calling `.GetSurfaceID()`, as this is done for you.

## `.Resize(width, height)`<br>
Sets the width and height of the Canvas.<br>
Note: This will also free the surface/buffer context as they're now both invalid data.

## `.GetWidth()`
Returns the set surface width/height.

## `.GetSurfaceID()`<br>
Returns a surface ID. This should always be used before you do anything with the surface itself.

## `.GetBufferContents()`<br>
This returns the buffer contents that the surface has been saved onto (if any), with a small header format to determine if:<br>
- It's compressed
- The width
- The height

## `.SetBufferContents(buffer)`<br>
Sets the canvas to the buffer contents. If the width and height don't match from the buffer, it'll resize the Canvas for you.

## `.GetStatus()`<br>
Returns the current status code. Which you can then use the enum `CanvasStatus`

## `.Cache()`<br>
Compresses the buffer and frees the surface for you.

## `.Restore()`<br>
Decompresses the buffer and sets up the surface again.

## `.WriteToCache(bool)`<br>
Determines if `.Finish()` should update the cache for you or not.

## `.UpdateCache()`<br>
Updates the cache when called.

## `.FreeSurface()`<br>
Fres the surface only
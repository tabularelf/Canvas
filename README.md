# Canvas v1.2.1
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

## `.Start([index])`<br>
Similar to `surface_set_target()`, but also does some additional preparations to ensure that it can fetch the previous surface data first/initialize the surface.<br>
If an argument is provided for [index], this will invoke `surface_set_target_ext()` instead.

## `.Finish()`<br>
Similar to `surface_reset_target()`, but also updates the internal cache.

## `.Free()`<br>
Frees the underlying surface and buffers.

## `.CheckSurface()`<br>
Checks up on the surface. This isn't normally needed to be called prior to calling `.GetSurfaceID()`, as this is done for you.

## `.Resize(width, height, [keepData])`<br>
Sets the width and height of the Canvas. If `[keepData]` is set to true, it will also maintain the current data. <br>
Note: This will also free the surface/buffer context as they're now both invalid data.<br>
**Additional note**: `[keepData]` currently does not work properly on HTML5, so it has been forcedfully switched off.

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

## `.Flush()`<br>
Fres the surface only. Can be restored as usual.

## `.CopySurface(surfaceID, x, y, [forceResize], [updateCache])`<br>
Copies one surface to the Canvas surface, as per `surface_copy()`. <br>
If `[forceResize]` is set to `true` (default is `false`), it will also resize the surface/buffer prior to copying the surface as per `x + width`, `y + height`. <br>
If `[updateCache]` is set to `true` (default is the state of `.WriteToCache()`), it will update the cache.

## `.CopySurfacePart(surfaceID, x, y, xs, ys, ws, hs, [forceResize], [updateCache])`<br>
Same as above, except also takes in a few additional arguments for copying parts of a surface.

## `.GetTexture()`<br>
Gets the texture of the surface.

## `.GetPixel(x, y)`<br>
Gets colour data from a pixel from the buffer cache. 

## `.GetPixelArray(x, y)`<br>
Gets colour data from a pixel from the buffer cache, in the form of an array.

## `.Clear([clearSurface], [clearBuffer])`<br>
Clears data. Both arguments default to `true`.

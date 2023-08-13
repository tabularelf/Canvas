# Canvas

### `Canvas(width, height, [forceInit], [surfaceFormat])`

Returns: An instance of `Canvas`.

|Name|Datatype|Purpose|
|---|---|---|
|`width`|`Real`|Width of the Canvas.|
|`height`|`Real`|Height of the Canvas.|
|`forceInit`|`Bool`|Whether to forcefully init the Canvas or not. Defaults to `false`.|
|`surfaceFormat`|`SurfaceFormatType`|The surface format to use for the Canvas instance. Defaults to `surface_rgba8unorm`. See [`surface_create`](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Surfaces/surface_create.htm) for more.|

Constructor, creates a new instance of `Canvas` to be used for storing the contents of the surface.

### `.Start([targetID])`

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`TargetID`|`Real`|Sets the Canvas target, used for shaders primarily. Default is `-1`, which is for no target.|

Starts writing to the Canvas.

### `.Finish()`

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Finishes writing to the Canvas. If caching writing is enabled, it will also write the Canvas data to the Canvas instance's cache.

### `.Free()`

Returns: `N/A`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Frees the Canvas contents, allowing for discarding safely.

### `.Flush()`

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Frees the Canvas surface, flushing it from VRAM.

### `.Resize(width, height, [keepData])`

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`Width`|`Real`|Width that you'd like to resize the Canvas to.|
|`Height`|`Real`|Height that you'd like to resize the Canvas to.|
|`keepData`|`Boolean`|Whether to keep the existing surface data or not. Default is `false`.|

Sets the width and height of the Canvas. If `[keepData]` is set to `true`, it will also maintain the current data. If the width and height is the same as the Canvas width and height, then nothing happens.

?> `[keepData]` currently does not work properly on HTML5, so it has been forcedfully switched off.

### `.CopySurface(surfaceID, x, y, [forceResize], [updateCache])`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`surfaceID`|`Surface ID`| Surface ID that you want to copy from.|
|`x`|`Real`| X pos that you want to copy to.|
|`y`|`Real`| Y pos that you want to copy to.|
|`forceResize`|`Boolean`| Whether to forcefully resize the surface or not. Default is `false`.|
|`updateCache`|`Boolean`| Whether to forcefully update the cache or not. Default is state of cache writing as per `.SetWriteToCache()`.|

Copies one surface to the Canvas surface, as per `surface_copy()`. <br>
If `[forceResize]` is set to `true` (default is `false`), it will also resize the surface/buffer prior to copying the surface as per `x + width`, `y + height`. <br>
If `[updateCache]` is set to `true` (default is the state of `.WriteToCache()`), it will update the cache.

### `.CopySurfacePart(surfaceID, x, y, xs, ys, ws, hs, [forceResize], [updateCache])`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`surfaceID`|`Surface ID`| Surface ID that you want to copy from.|
|`x`|`Real`| X pos that you want to copy to.|
|`y`|`Real`| Y pos that you want to copy to.|
|`xs`|`Real`| X pos that you want to copy from source.|
|`ys`|`Real`| Y pos that you want to copy from source.|
|`ws`|`Real`| Width that you want to copy from source.|
|`hs`|`Real`| Height that you want to copy from source.|
|`forceResize`|`Boolean`| Whether to forcefully resize the surface or not. Default is `false`.|
|`updateCache`|`Boolean`| Whether to forcefully update the cache or not. Default is state of cache writing as per `.SetWriteToCache()`.|

Same as above, except also takes in a few additional arguments for copying parts of a surface.

### `.CopyCanvas(canvas, x, y, [forceResize], [updateCache])`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`canvas`|`Canvas Instance`| Canvas instance that you want to copy from.|
|`x`|`Real`| X pos that you want to copy to.|
|`y`|`Real`| Y pos that you want to copy to.|
|`forceResize`|`Boolean`| Whether to forcefully resize the surface or not. Default is `false`.|
|`updateCache`|`Boolean`| Whether to forcefully update the cache or not. Default is state of cache writing as per `.SetWriteToCache()`.|

Same as `.CopySurface()`, but copies a Canvas surface instead.

### `.CopyCanvasPart(canvas, x, y, xs, ys, ws, hs, [forceResize], [updateCache])`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`canvas`|`Canvas Instance`| Canvas instance that you want to copy from.|
|`x`|`Real`| X pos that you want to copy to.|
|`y`|`Real`| Y pos that you want to copy to.|
|`xs`|`Real`| X pos that you want to copy from source.|
|`ys`|`Real`| Y pos that you want to copy from source.|
|`ws`|`Real`| Width that you want to copy from source.|
|`hs`|`Real`| Height that you want to copy from source.|
|`forceResize`|`Boolean`| Whether to forcefully resize the surface or not. Default is `false`.|
|`updateCache`|`Boolean`| Whether to forcefully update the cache or not. Default is state of cache writing as per `.SetWriteToCache()`.|

Same as `.CopySurfacePart()`, but copies a Canvas surface instead.

### `.CheckSurface()`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

?> This method is deprecated and is currently being phased out slowly.<br>

Checks up on the surface. This isn't normally needed to be called in about every function, as this is automatically invoked.

### `.UpdateCache()`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Updates the cache when called.

### `.IsAvailable()`<br>

Returns: `Boolean`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns `true` if the Canvas has some kind of data, and isn't in use. Or `false`.

### `.Clear([colour], [alpha])`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`Colour`|`Real`| Sets the colour to clear with. Default is `c_black`.|
|`Alpha`|`Real`| Sets the alpha to clear with. Default is `0`.|

Clears the surface and buffer contents, overwriting it with the contents of the colour and alpha specified.

### `.Cache()`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Caches the buffer, freeing the surface.

### `.Restore()`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Restores the buffer from the cache and the surface.

### `.SaveAsImage(filename)`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`filename`|`String`|The name of the file to save as.|

Saves the current Canvas as a `png` file.
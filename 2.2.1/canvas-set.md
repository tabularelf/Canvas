### `.SetBufferContents(buffer)`<br>
Sets the canvas to the buffer contents. If the width and height don't match from the buffer, it'll resize the Canvas for you.

### `.SetWriteToCache(bool)`<br>
Determines if `.Finish()` should update the cache for you or not.

### `.SetDepthDisabled(DepthEnabled)`

Returns: `self`

|Name|Datatype|Purpose|
|---|---|---|
|`DepthDisabled`|`Boolean`|Whether depth is enabled or disabled for this Canvas instance.|

Sets whether the next surface that this Canvas instance creates should have depth enabled or disabled. This will refresh the Canvas's surface automatically.

### `.SetCallbackCacheUpdated(callback)`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`Callback`|`Function`|The callback for the Canvas instance to use.|

Sets a callback function to be used whenever the buffer cache is updated. The callback will be provided a single argument containing the Canvas instance that called the callback.

The following methods that will apply to this callback are:
- `.Clear`
- `.SetBufferContents`
- `.UpdateCache`

In addition, the following may be applied immediately after these functions, if buffer auto cache is on:
- `.Start/.Finish` (respectively)
- `.CopySurface`
- `.CopySurfacePart`
- `.CopyCanvas`
- `.CopyCanvasPart`

### `.SetCallbackSurfaceUpdated(callback)`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`Callback`|`Function`|The callback for the Canvas instance to use.|

Sets a callback function to be used whenever the surface is updated. The callback will be provided a single argument containing the Canvas instance that called the callback.

The following methods that will apply to this callback are:
- `.Start/.Finish` (respectively)
- `.CopySurface`
- `.CopySurfacePart`
- `.CopyCanvas`
- `.CopyCanvasPart`
- `.Clear`

### `.SetCallbackSurfaceRestored(callback)`<br>

Returns: `self`.

|Name|Datatype|Purpose|
|---|---|---|
|`Callback`|`Function`|The callback for the Canvas instance to use.|

Sets a callback function to be used whenever the surface is restored. The callback will be provided a single argument containing the Canvas instance that called the callback.

As this is specifically applied to when the underlying surface is restored, this can be restored by just about almost any method with Canvas. Whenever the surface is needed.
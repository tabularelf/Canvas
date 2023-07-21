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
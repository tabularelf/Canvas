### `.GetSize()`

Returns: `Real`

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns the Canvas size, made from the width, height and format used.

### `.GetBufferContents([forceCompress])`<br>

Returns: `Buffer`

|Name|Datatype|Purpose|
|---|---|---|
|`forceCompress`|`Boolean`|Whether the buffer should return compressed or not. (Default is `false`)|

This returns the buffer contents that the surface has been saved onto (if any), with a small header format:<br>
- Version
- Compressed
- Width
- Height

If `[forceCompress]` is set to `true` (default is `false`), it will give you a compressed version of the current contents, if it's not compressed.

### `.GetPixel(x, y)`<br>

Returns `Real`

|Name|Datatype|Purpose|
|---|---|---|
|`x`|`Real`|x position of surface.|
|`y`|`Real`|y position of surface.|

Gets colour data from a pixel from the buffer cache.

### `.GetPixelArray(x, y)`<br>

Returns `Array`

|Name|Datatype|Purpose|
|---|---|---|
|`x`|`Real`|x position of surface.|
|`y`|`Real`|y position of surface.|

Gets colour data from a pixel from the buffer cache, in the form of an array.

### `.GetSurfaceID()`

Returns: `Surface ID` or `-1`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns the Canvas surface ID, if there's any data.

### `.GetTexture()`<br>

Returns `Texture Pointer`

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Gets the texture pointer of the surface.

### `.GetWidth()`

Returns: `Real`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns the width of the Canvas.

### `.GetHeight()`

Returns: `Real`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns the height of the Canvas.

### `.GetStatus()`

Returns: `CanvasStatus Enum value`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns the status of the Canvas, which can be compared against one of the many enum values from `CanvasStatus`.

|Name|Purpose|
|---|---|
|`CanvasStatus.NO_DATA`|Canvas contains no data.|
|`CanvasStatus.IN_USE`|Canvas is currently being written to.|
|`CanvasStatus.HAS_DATA`|Canvas has data.|
|`CanvasStatus.HAS_DATA_CACHED`|Canvas has data but is cached in memory.|

### `.GetFormat()`

Returns: `Surface Format`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns the format that the Canvas is using, as the argument passed when creating a Canvas instance.

### `.GetDepthDisabled()`

Returns: `Boolean`.

|Name|Datatype|Purpose|
|---|---|---|
|`N/A`|||

Returns whether depth is disabled or not.
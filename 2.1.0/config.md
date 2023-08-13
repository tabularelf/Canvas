# Canvas Config

Canvas includes `__CanvasConfig` for applying specific behaviour across all instances of Canvas.

|Name|Default|Purpose|
|---|---|---|
|__CANVAS_AUTO_WRITE_TO_CACHE|`true`|Whether newly created Canvas instances should automatically write to cache upon calling `.Finish()`|
|`__CANVAS_SURFACE_DEPTH_MODE`|`0`|	The mode of operation for how Canvas surface depth is determined upon creation.<br>0: Depends on what surface_get_depth_disable() returns at the time<br>1: Forces surface depth disable to be false<br>2: Forces surface depth disable to be true|
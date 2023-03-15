function __CanvasSystem() {
	static _inst = new (function() constructor {
		refList = ds_list_create();
		GCList = ds_list_create();
		time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, method(self, __CanvasGC), [], -1));
		time_source_start(time_source_create(time_source_global, 15, time_source_units_frames, method(self, __CanvasCleanupQueue), [], -1));
	})();
	
	return _inst;
}
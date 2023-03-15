function __CanvasSystem() {
	static _inst = new (function() constructor {
		refList = ds_list_create();
		GCList = ds_list_create();
		time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, method(self, __CanvasGC), [], -1));
		time_source_start(time_source_create(time_source_global, 15, time_source_units_frames, method(self, __CanvasCleanupQueue), [], -1));
	})();
	
	return _inst;
}

#macro __CANVAS_CREDITS "@TabularElf - https://tabelf.link/"
#macro __CANVAS_VERSION "2.0.0"
#macro __CANVAS_ON_WEB (os_browser != browser_not_a_browser)
show_debug_message("Canvas " + __CANVAS_VERSION + " initalized! Created by " + __CANVAS_CREDITS);

#macro __CANVAS_HEADER_SIZE 7

// We have this set to 2 to handle older Canvas versions
#macro __CANVAS_HEADER_VERSION 2 

enum CanvasStatus {
	NO_DATA,
	IN_USE,
	HAS_DATA,
	HAS_DATA_CACHED
}
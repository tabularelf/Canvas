#macro CANVAS_CREDITS "TabularElf - https://tabelf.link/"
#macro CANVAS_VERSION "1.0.0"
show_debug_message("Canvas " + CANVAS_VERSION + " initalized! Created by " + CANVAS_CREDITS);

/// @func canvas
/// @param width
/// @param height
function canvas(_width, _height) constructor {
		width = _width;
		height = _height;
		surface = -1;
		buffer = -1;
		cacheBuffer = -1;
		isLoaded = false;
		
		static start = function() {
			if !(surface_exists(surface)) {
				if !(buffer_exists(buffer)) {
					__surfaceCreate();
					surface_set_target(surface);
					draw_clear_alpha(0, 0);
					surface_reset_target();
				} else {
					checkSurface();
				}
			}
			
			surface_set_target(surface);
		}
		
		static finish = function() {
			surface_reset_target();
			if !(buffer_exists(buffer)) {
				__init();
			}
			
			buffer_get_surface(buffer, surface, 0);
			isLoaded = true;
		}
		
		static __init = function() {
			if !(buffer_exists(buffer)) {
				if (buffer_exists(cacheBuffer)) {
					// Lets decompress it
					__restoreFromCache();
				} else {
					buffer = buffer_create(width * height * 4, buffer_fixed, 4);	
				}
			}
		}
		
		static free = function() {
			if (buffer_exists(buffer)) {
				buffer_delete(buffer);	
				buffer = -1;
			}
			
			if (buffer_exists(cacheBuffer)) {
				buffer_delete(cacheBuffer);	
				cacheBuffer = -1;
			}
			
			if (surface_exists(surface)) {
				surface_free(surface);	
				surface = -1;
			}
			
			isLoaded = false;
		}
		
		static checkSurface = function() {
			if (buffer_exists(buffer)) || (buffer_exists(cacheBuffer)) {
				if !(surface_exists(surface)) {
					__surfaceCreate();
					if (buffer_exists(cacheBuffer)) {
						restore();	
					}
					buffer_set_surface(buffer,surface,0);
				}
			}
		}
		
		static getSurfaceID = function() {
			checkSurface();
			return surface;
		}
		
		static getBufferID = function() {
			return (buffer_exists(cacheBuffer) ? cacheBuffer : (buffer_exists(buffer) ? buffer : -1));
		}
			
		static __surfaceCreate = function() {
			if !(surface_exists(surface)) {
				surface = surface_create(width, height);
			}
		}
		
		static cache = function() {
			if !(buffer_exists(cacheBuffer)) {
				if (buffer_exists(buffer)) {
					// Have to do this due to a bug with buffer_compress. 
					// Will change later once bugfix comes through.
					var _size = width*height*4;
					cacheBuffer = buffer_compress(buffer, 0, _size);
					
					// Remove main buffer
					buffer_delete(buffer);
					buffer = -1;
					
					// Remove surface
					if (surface_exists(surface)) {
						surface_free(surface);	
						surface = -1;
					}
				}
				isLoaded = false;
			}
		}
			
		static restore = function() {
			if !(buffer_exists(buffer)) && (buffer_exists(cacheBuffer)) {
				var _dbuff = buffer_decompress(cacheBuffer);
				if !(_dbuff < 0) {
					buffer = _dbuff;
					buffer_delete(cacheBuffer);
					cacheBuffer = -1;
					// Restore surface
					checkSurface();
					
					// It has loaded successfully!
					isLoaded = true;
				} else {
					show_error("Canvas: Something terrible has gone wrong with unloading cache data!\nReport it to TabularElf at once!", true);	
				}
			}
		}
}
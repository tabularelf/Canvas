#macro CANVAS_CREDITS "TabularElf - https://tabelf.link/"
#macro CANVAS_VERSION "1.0.0"
show_debug_message("Canvas " + CANVAS_VERSION + " initalized! Created by " + CANVAS_CREDITS);

enum CanvasStatus {
	NO_DATA,
	IN_USE,
	HAS_DATA,
	HAS_DATA_CACHED
}

/// @func Canvas
/// @param width
/// @param height
function Canvas(_width, _height) constructor {
		width = _width;
		height = _height;
		surface = -1;
		buffer = -1;
		cacheBuffer = -1;
		isLoaded = false;
		status = CanvasStatus.NO_DATA;
		
		static Start = function() {
			if !(surface_exists(surface)) {
				if !(buffer_exists(buffer)) {
					__surfaceCreate();
					surface_set_target(surface);
					draw_clear_alpha(0, 0);
					surface_reset_target();
				} else {
					CheckSurface();
				}
			}
			
			surface_set_target(surface);
			status = CanvasStatus.IN_USE;
		}
		
		static Finish = function() {
			surface_reset_target();
			if !(buffer_exists(buffer)) {
				__init();
			}
			
			buffer_get_surface(buffer, surface, 0);
			isLoaded = true;
			status = CanvasStatus.HAS_DATA;
		}
		
		static __init = function() {
			if !(buffer_exists(buffer)) {
				if (buffer_exists(cacheBuffer)) {
					// Lets decompress it
					Restore();
				} else {
					buffer = buffer_create(width * height * 4, buffer_fixed, 4);	
				}
			}
		}
		
		static Free = function() {
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
			status = CanvasStatus.NO_DATA;
		}
		
		static CheckSurface = function() {
			if (buffer_exists(buffer)) || (buffer_exists(cacheBuffer)) {
				if !(surface_exists(surface)) {
					__surfaceCreate();
					if (buffer_exists(cacheBuffer)) {
						Restore();	
					}
					buffer_set_surface(buffer,surface,0);
				}
			}
		}
		
		static GetSurfaceID = function() {
			CheckSurface();
			return surface;
		}
		
		static GetBufferContents = function() {
			var _bufferToCopy = (buffer_exists(cacheBuffer) ? cacheBuffer : (buffer_exists(buffer) ? buffer : -1));
			if (_bufferToCopy == -1) {
				return -1;	
			}
			
			// Send copied buffer as a result
			var _size = buffer_get_size(_bufferToCopy);
			var _buffer = buffer_create(_size, buffer_fixed, 1);
			buffer_copy(_bufferToCopy, 0, _size, _buffer, 0);
			return _buffer;
		}
			
		static __surfaceCreate = function() {
			if !(surface_exists(surface)) {
				surface = surface_create(width, height);
			}
		}
		
		static GetStatus = function() {
			return status;	
		}
		
		static Cache = function() {
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
			
			status = CanvasStatus.HAS_DATA_CACHED;
		}
			
		static Restore = function() {
			if !(buffer_exists(buffer)) && (buffer_exists(cacheBuffer)) {
				var _dbuff = buffer_decompress(cacheBuffer);
				if !(_dbuff < 0) {
					buffer = _dbuff;
					buffer_delete(cacheBuffer);
					cacheBuffer = -1;
					// Restore surface
					CheckSurface();
					
					// It has loaded successfully!
					isLoaded = true;
				} else {
					show_error("Canvas: Something terrible has gone wrong with unloading cache data!\nReport it to TabularElf at once!", true);	
				}
			}
			status = CanvasStatus.HAS_DATA;
		}
}
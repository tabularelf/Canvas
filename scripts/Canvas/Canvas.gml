#macro CANVAS_CREDITS "@TabularElf - https://tabelf.link/"
#macro CANVAS_VERSION "1.1.1"
show_debug_message("Canvas " + CANVAS_VERSION + " initalized! Created by " + CANVAS_CREDITS);

#macro __CANVAS_HEADER_SIZE 5

enum CanvasStatus {
	NO_DATA,
	IN_USE,
	HAS_DATA,
	HAS_DATA_CACHED
}

/// @func Canvas
/// @param {Real} _width
/// @param {Real} _height
function Canvas(_width, _height) constructor {
		__width = _width;
		__height = _height;
		__surface = -1;
		__buffer = -1;
		__cacheBuffer = -1;
		__status = CanvasStatus.NO_DATA;
		__writeToCache = true;
		
		static Start = function() {
			if !(surface_exists(__surface)) {
				if !(buffer_exists(__buffer)) {
					__surfaceCreate();
					surface_set_target(__surface);
					draw_clear_alpha(0, 0);
					surface_reset_target();
				} else {
					CheckSurface();
				}
			}
			
			surface_set_target(__surface);
			__status = CanvasStatus.IN_USE;
			return self;
		}
		
		static Finish = function() {
			surface_reset_target();
			if !(buffer_exists(__buffer)) {
				__init();
			}
			
			if (__writeToCache) {
				buffer_get_surface(__buffer, __surface, 0);
			}
			__status = CanvasStatus.HAS_DATA;
			return self;
		}
		
		static __init = function() {
			if !(buffer_exists(__buffer)) {
				if (buffer_exists(__cacheBuffer)) {
					// Lets decompress it
					Restore();
				} else {
					__buffer = buffer_create(__width * __height * 4, buffer_fixed, 4);	
				}
			}
		}
		
		static Free = function() {
			if (buffer_exists(__buffer)) {
				buffer_delete(__buffer);	
				/* Feather ignore once GM1043 */
				__buffer = -1;
			}
			
			if (buffer_exists(__cacheBuffer)) {
				buffer_delete(__cacheBuffer);	
				/* Feather ignore once GM1043 */
				__cacheBuffer = -1;
			}
			
			if (surface_exists(__surface)) {
				surface_free(__surface);	
				/* Feather ignore once GM1043 */
				__surface = -1;
			}
			
			__status = CanvasStatus.NO_DATA;
		}
		
		static CheckSurface = function() {
			if (buffer_exists(__buffer)) || (buffer_exists(__cacheBuffer)) {
				if !(surface_exists(__surface)) {
					__surfaceCreate();
					if (buffer_exists(__cacheBuffer)) {
						Restore();	
					}
					buffer_set_surface(__buffer,__surface, 0);
				}
			}
		}
		
		static Resize = function(_width, _height) {
			if (buffer_exists(__buffer)) {
				buffer_delete(__buffer);
			}
			
			if (buffer_exists(__cacheBuffer)) {
				buffer_delete(__cacheBuffer);
			}
			
			if (surface_exists(__surface)) {
				surface_free(__surface);	
			}
			
			__width = _width;
			__height = _height;
			__status = CanvasStatus.NO_DATA;
			
			return self;
		}
		
		static GetWidth = function() {
			return __width;	
		}
		
		static GetHeight = function() {
			return __height;	
		}
		
		static GetSurfaceID = function() {
			CheckSurface();
			return __surface;
		}
		
		static __refreshSurface = function() {
			surface_free(__surface);
			CheckSurface();
		}
		
		static GetBufferContents = function() {
			var _bufferToCopy = (buffer_exists(__cacheBuffer) ? __cacheBuffer : (buffer_exists(__buffer) ? __buffer : -1));
			if (_bufferToCopy == -1) {
				return -1;	
			}
			
			// Send copied buffer as a result
			var _size = buffer_get_size(_bufferToCopy);
			var _buffer = buffer_create(_size+__CANVAS_HEADER_SIZE, buffer_fixed, 1);
			buffer_write(_buffer, buffer_bool, GetStatus() == CanvasStatus.HAS_DATA_CACHED ? true : false);
			buffer_write(_buffer, buffer_u16, __width);
			buffer_write(_buffer, buffer_u16, __height);
			buffer_copy(_bufferToCopy, 0, _size, _buffer, __CANVAS_HEADER_SIZE);
			/* Feather ignore once GM1035 */
			return _buffer;
		}
		
		static SetBufferContents = function(_cvBuff) {
			buffer_seek(_cvBuff, buffer_seek_start, 0);
			var _isCompressed = buffer_read(_cvBuff, buffer_bool);
			var _width = buffer_read(_cvBuff, buffer_u16);
			var _height = buffer_read(_cvBuff, buffer_u16);
			
			if ((__width != _width) || (__height != _height)) {
				__width = _width;
				__height = _height;
				if (surface_exists(__surface)) {
					surface_resize(__surface, _width, _height);	
				}
			}
			
			var _buff = buffer_create(1, buffer_grow, 1);
			buffer_copy(_cvBuff, __CANVAS_HEADER_SIZE, buffer_get_size(_cvBuff), _buff, 0);
			
			if (_isCompressed) && (GetStatus() != CanvasStatus.HAS_DATA_CACHED) {
				var _dbuff = buffer_decompress(_buff);
				if (buffer_exists(_dbuff)) {
					buffer_delete(_buff);
					_buff = _dbuff;
				}
			}
			
			switch(GetStatus()) {
				case CanvasStatus.NO_DATA:
					__status = CanvasStatus.HAS_DATA;
				case CanvasStatus.HAS_DATA:
					__buffer = _buff;
					__refreshSurface();
				break;
				
				case CanvasStatus.HAS_DATA_CACHED:
					__cacheBuffer = _buff;
				break;
			}
			return self;
		}
			
		static __surfaceCreate = function() {
			if !(surface_exists(__surface)) {
				__surface = surface_create(__width, __height);
			}
		}
		
		static GetStatus = function() {
			return __status;	
		}
		
		static Cache = function() {
			if (!buffer_exists(__cacheBuffer)) {
				if (buffer_exists(__buffer)) {
					// Have to do this due to a bug with buffer_compress. 
					// Will change later once bugfix comes through.
					var _size = __width*__height*4;
					__cacheBuffer = buffer_compress(__buffer, 0, _size);
					
					// Remove main buffer
					buffer_delete(__buffer);
					/* Feather ignore once GM1013 */
					__buffer = -1;
					
					// Remove surface
					if (surface_exists(__surface)) {
						surface_free(__surface);	
						/* Feather ignore once GM1013 */
						__surface = -1;
					}
				}
			}
			
			__status = CanvasStatus.HAS_DATA_CACHED;
			return self;
		}
			
		static Restore = function() {
			if (!buffer_exists(__buffer)) && (buffer_exists(__cacheBuffer)) {
				var _dbuff = buffer_decompress(__cacheBuffer);
				if (buffer_exists(_dbuff)) {
					__buffer = _dbuff;
					buffer_delete(__cacheBuffer);
					__cacheBuffer = -1;
					// Restore surface
					CheckSurface();
				} else {
					show_error("Canvas: Something terrible has gone wrong with unloading cache data!\nReport it to TabularElf at once!", true);	
				}
			}
			__status = CanvasStatus.HAS_DATA;
			return self;
		}
		
		static WriteToCache = function(_bool) {
			__writeToCache = _bool;	
			return self;
		}
		
		static FreeSurface = function() {
			if (surface_exists(__surface)) {
				surface_free(__surface);	
			}
			return self;
		}
}
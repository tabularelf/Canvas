#macro __CANVAS_CREDITS "@TabularElf - https://tabelf.link/"
#macro __CANVAS_VERSION "1.3.0"
#macro __CANVAS_ON_WEB (os_browser != browser_not_a_browser)
show_debug_message("Canvas " + __CANVAS_VERSION + " initalized! Created by " + __CANVAS_CREDITS);

#macro __CANVAS_HEADER_SIZE 5

enum CanvasStatus {
	NO_DATA,
	IN_USE,
	HAS_DATA,
	HAS_DATA_CACHED
}

/// @func Canvas
/// @param {Real} width
/// @param {Real} height
/// @param {Boolean} forceInit
function Canvas(_width, _height, _forceInit = false) constructor {
		__width = _width;
		__height = _height;
		__surface = -1;
		__buffer = -1;
		__cacheBuffer = -1;
		__status = CanvasStatus.NO_DATA;
		__writeToCache = true;
		__index = 0;
		
		if (_forceInit) {
			__init();
			CheckSurface();
			__status = CanvasStatus.HAS_DATA;
		}
		
		static Start = function(_ext = -1) {
			__index = _ext;
			if (!surface_exists(__surface)) {
				if (!buffer_exists(__buffer)) {
					__SurfaceCreate();
					if (_ext == -1) {
						surface_set_target(__surface);
					} else {
						surface_set_target_ext(_ext, __surface);	
					}
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
			__init();
			
			if (__writeToCache) {
				__UpdateCache();
			}
			
			__status = CanvasStatus.HAS_DATA;
			
			return self;
		}
		
		static __init = function() {
			if (!buffer_exists(__buffer)) {
				if (buffer_exists(__cacheBuffer)) {
					// Lets decompress it
					Restore();
				} else {
					__buffer = buffer_create(__width * __height * 4, buffer_fixed, 4);	
				}
			}
		}
		
				
		static CopyCanvas = function(_canvas, _x, _y, _forceResize = false, _updateCache = __writeToCache) {
			if (!CanvasIsCanvas(_canvas)) {
				__CanvasError("Canvas " + string(_canvas) + " is not a valid Canvas instance!");
			}
			
			if (!_canvas.IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");
			}
			CopySurface(_canvas.GetSurfaceID(), _x, _y, _forceResize, _updateCache);
			return self;
		}
		
		static CopyCanvasPart = function(_canvas, _x, _y, _xs, _ys, _ws, _hs, _forceResize = false, _updateCache = __writeToCache) {
			if (!CanvasIsCanvas(_canvas)) {
				__CanvasError("Canvas " + string(_canvas) + " is not a valid Canvas instance!");	
			}
			
			if (!_canvas.IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");
			}
			CopySurfacePart(_canvas.GetSurfaceID(), _x, _y, _xs, _ys, _ws, _hs, _forceResize, _updateCache);
			return self;
		}
		
		static IsAvailable = function() {
			return (__status == CanvasStatus.HAS_DATA) || (__status == CanvasStatus.HAS_DATA_CACHED);	
		}
		
		static CopySurface = function(_surfID, _x, _y, _forceResize = false, _updateCache = __writeToCache) {
			if (!surface_exists(_surfID)) {
				show_error("Canvas: Surface " + string(_surfID) + " doesn't exist!", true);	
			}
			
			__init();
			CheckSurface();
			
			var _currentlyWriting = false;
			
			if (surface_get_target() == __surface) {
				_currentlyWriting = true;
				Finish();
			}
			
			var _width = surface_get_width(_surfID);
			var _height = surface_get_height(_surfID);
			
			if (_forceResize) && ((__width != (_x + _width)) || (__height != (_y + _height))) {
				Resize(_x + _width, _y + _height, true);	
			}
			
			__init();
			CheckSurface();
			
			surface_copy(__surface, _x, _y, _surfID);
			if (_updateCache) {
				__UpdateCache();
			}
			
			if (_currentlyWriting) {
				Start(__index);	
			}
			
			return self;
		}
		
		static CopySurfacePart = function(_surfID, _x, _y, _xs, _ys, _ws, _hs, _forceResize = false, _updateCache = __writeToCache) {
			if (!surface_exists(_surfID)) {
				show_error("Canvas: Surface " + string(_surfID) + " doesn't exist!", true);	
			}
			
			__init();
			CheckSurface();
			
			var _currentlyWriting = false;
			
			if (surface_get_target() == __surface) {
				_currentlyWriting = true;
				Finish();
			}
			
			var _width = surface_get_width(_surfID);
			var _height = surface_get_height(_surfID);
			
			if (_forceResize) && ((__width != (_x + _width)) || (__height != (_y + _height))) {
				Resize(_x + _width, _y + _height, true);	
			}
			
			surface_copy_part(__surface, _x, _y, _surfID, _xs, _ys, _ws, _hs);
			if (_updateCache) {
				__UpdateCache();
			}
			
			if (_currentlyWriting) {
				Start(__index);	
			}
			
			return self;
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
				if (!surface_exists(__surface)) {
					__SurfaceCreate();
					if (buffer_exists(__cacheBuffer)) {
						Restore();	
					}
					buffer_set_surface(__buffer,__surface, 0);
				}
			} 
		}
		
		static Resize = function(_width, _height, _keepData = false) {
			
			if (__width == _width) && (__height == _height) return self;
			
			__width = _width;
			__height = _height;
			
			if (!_keepData) || (__CANVAS_ON_WEB) {
				if (buffer_exists(__buffer)) {
					buffer_delete(__buffer);
				}	
				
				if (buffer_exists(__cacheBuffer)) {
					buffer_delete(__cacheBuffer);
				}
				
				if (surface_exists(__surface)) {
					surface_free(__surface);	
				}
			}
			
			__init();
			CheckSurface();
			
			if (_keepData) && (!__CANVAS_ON_WEB) {
				
				var _currentlyWriting = false;
				
				if (surface_get_target() == __surface) {
					_currentlyWriting = true;
					Finish();
				}
				
				var _tempSurf = surface_create(_width, _height);
				surface_copy(_tempSurf, 0, 0, __surface);
				surface_resize(__surface, _width, _height);
				buffer_resize(__buffer, _width*_height*4);
				surface_copy(__surface, 0, 0, _tempSurf);
				surface_free(_tempSurf);
				
				
				__UpdateCache();	
				
				__status = CanvasStatus.HAS_DATA;
				
				if (_currentlyWriting) {
					Start(__index);	
				}
			}
			
			return self;
		}
		
		static GetWidth = function() {
			return __width;	
		}
		
		static GetHeight = function() {
			return __height;	
		}
		
		static GetSurfaceID = function() {
			if (__status == CanvasStatus.NO_DATA) return -1;
			CheckSurface();
			return __surface;
		}
		
		static __refreshSurface = function() {
			surface_free(__surface);
			CheckSurface();
		}
		
		static GetBufferContents = function(_forceCompress = false) {
			//
			if (_forceCompress) {
				if (buffer_exists(__buffer)) {
					var _cbuff = buffer_compress(__buffer, 0, buffer_get_size(__buffer));
					var _buff = __copyBufferContents(_cbuff, true);
					buffer_delete(_cbuff);
					return _buff;
				}
			}
			
			var _bufferToCopy = (buffer_exists(__cacheBuffer) ? __cacheBuffer : (buffer_exists(__buffer) ? __buffer : -1));
			if (_bufferToCopy == -1) {
				return -1;	
			}
			
			var _buffer = __copyBufferContents(_bufferToCopy);
			return _buffer;
		}
		
		static __copyBufferContents = function(_bufferToCopy, _forceCompressed = false) {
			// Send copied buffer as a result
			var _size = buffer_get_size(_bufferToCopy);
			var _isCompressed = (_forceCompressed ? true: (GetStatus() == CanvasStatus.HAS_DATA_CACHED ? true : false));
			var _buffer = buffer_create(_size+__CANVAS_HEADER_SIZE, buffer_fixed, 1);
			buffer_write(_buffer, buffer_bool, _isCompressed);
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
					buffer_delete(__buffer);
					__buffer = _buff;
					__refreshSurface();
				break;
				
				case CanvasStatus.HAS_DATA_CACHED:
					buffer_delete(__cacheBuffer);
					__cacheBuffer = _buff;
				break;
			}
			return self;
		}
			
		static __SurfaceCreate = function() {
			if (!surface_exists(__surface)) {
				__surface = surface_create(__width, __height);
			}
		}
		
		static __UpdateCache = function() {
			buffer_get_surface(__buffer, __surface, 0);
			__status = CanvasStatus.HAS_DATA;	
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
					/* Feather ignore once GM1043 */
					__buffer = -1;
					
					// Remove surface
					if (surface_exists(__surface)) {
						surface_free(__surface);	
						/* Feather ignore once GM1043 */
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
					/* Feather ignore once GM1043 */
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
		
		static UpdateCache = function() {
			switch(GetStatus()) {
				case CanvasStatus.NO_DATA:
				case CanvasStatus.HAS_DATA_CACHED:
					__init();
					CheckSurface();
				case CanvasStatus.HAS_DATA:
					__UpdateCache();
				break;
				case CanvasStatus.IN_USE:
					show_error("Canvas: Canvas is currently in use! Please call .Finish() before updating the cache!", true);
				break;
				
				
			}
			return self;
		}
		
		static Flush = function() {
			if (surface_exists(__surface)) {
				surface_free(__surface);	
			}
			return self;
		}
		
		static FreeSurface = Flush;
		
		static GetTexture = function() {
			return surface_get_texture(GetSurfaceID());
		}
		
		static GetPixel = function(_x, _y) {
			__init();
			if (_x >= __width || _x < 0) || (_y >= __height || _y < 0) return 0;
			var _col = buffer_peek(__buffer, (_x + (_y * __width)) * 4, buffer_u32);
			var _r = _col & 0xFF;
			var _g = (_col >> 8) & 0xFF;
			var _b = (_col >> 16) & 0xFF;
			return (_b & 0xFF) << 16 | (_g & 0xFF) << 8 | (_r & 0xFF);
		}
		
		static GetPixelArray = function(_x, _y) {
			__init();
			if (_x >= __width || _x < 0) || (_y >= __height || _y < 0) return [0,0,0,0];
			var _col = buffer_peek(__buffer, (_x + (_y * __width)) * 4, buffer_u32);
			var _r = _col & 0xFF;
			var _g = (_col >> 8) & 0xFF;
			var _b = (_col >> 16)  & 0xFF;
			var _a = (_col >> 24) / 0xFF;
			return [_r, _g, _b, _a];
		}
		
		static Clear = function() {
			__init();
			CheckSurface();
			
			surface_set_target(__surface);	
			draw_clear_alpha(c_black, 0);
			surface_reset_target();
			
			buffer_fill(__buffer, 0, buffer_u8, 0, buffer_get_size(__buffer));
			return self;
		}
		
		static Draw = function(_x, _y) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface(__surface, _x, _y);
		}
		
		static DrawExt = function(_x, _y, _xscale, _yscale, _rot, _col, _alpha) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_ext(__surface, _x, _y, _xscale, _yscale, _rot, _col, _alpha);
		}
		
		static DrawTiled = function(_x, _y) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_tiled(__surface, _x, _y);
		}
		
		static DrawTiledExt = function(_x, _y) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_tiled_ext(__surface, _x, _y, _xscale, _yscale, _col, _alpha);
		}
		
		static DrawPart = function(_left, _top, _width, _height, _x, _y) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_part(__surface, _left, _top, _width, _height, _x, _y);
		}
		
		static DrawPartExt = function(_left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_part_ext(__surface, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha);
		}
		
		static DrawStretched = function(_x, _y, _width, _height) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_stretched(__surface, _x, _y, _width, _height);
		}
		
		static DrawStretchedExt = function(_x, _y, _width, _height, _col, _alpha) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_stretched_ext(__surface, _x, _y, _width, _height, _col, _alpha);
		}
		
		static DrawGeneral = function(_left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _col1, _col2, _col3, _col4, _alpha) {
			if (!IsAvailable()) {
				__CanvasError("Canvas is empty or in use!");		
			}
			CheckSurface();
			draw_surface_general(__surface, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _col1, _col2, _col3, _col4, _alpha);
		}
}
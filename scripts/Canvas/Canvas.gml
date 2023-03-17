/// @func Canvas
/// @param {Real} width
/// @param {Real} height
/// @param {Boolean} forceInit
/// @param {Constant.SurfaceFormatType} surfaceFormat
function Canvas(_width, _height, _forceInit = false, _format = surface_rgba8unorm) constructor {
		static __sys = __CanvasSystem();
		__width = _width;
		__height = _height;
		__surface = -1;
		__buffer = -1;
		__cacheBuffer = -1;
		__status = CanvasStatus.NO_DATA;
		__writeToCache = true;
		__index = -1;
		__useDepth = surface_get_depth_disable();
		// Add to refList
		__refContents = {
			buff: __buffer,
			cbuff: __cacheBuffer,
			surf: __surface
		}
		__isAppSurf = false;
		
		var _weakRef = weak_ref_create(self);
		
		ds_list_add(__sys.refList, [_weakRef, __refContents]);
		
		if (!surface_format_is_supported(_format)) {
			__CanvasError("Surface format " + string(__CanvasSurfFormat(_format)) + " not supported on this platform!");
		}
		
		__updateFormat(_format);
		if (_forceInit) {
			__init();
			CheckSurface();
			__status = CanvasStatus.HAS_DATA;
		}
		
		#region Default Methods
		
		/// @param {Real} targetID use set_target_ext? (default: no) - any value != -1 will use set_target_ext
		static Start = function(_targetID = -1) {
			__index = _targetID;
			if (!surface_exists(__surface)) {
				if (!buffer_exists(__buffer)) {
					__SurfaceCreate();
					surface_set_target(__surface);
					draw_clear_alpha(0, 0);
					surface_reset_target();
				} else {
					CheckSurface();
				}
			}
			
			if (_targetID == -1) {
				surface_set_target(__surface);
			} else {
				surface_set_target_ext(__surface, _targetID);	
			}
			
			__status = CanvasStatus.IN_USE;
			return self;
		}
		
		static Finish = function() {
			surface_reset_target();
			__index = -1;
			__init();
			
			if (__writeToCache) {
				__UpdateCache();
			}
			
			__status = CanvasStatus.HAS_DATA;
			
			return self;
		}
				
		/// @param {struct.Canvas} canvas
		/// @param {Real} x destination x
		/// @param {Real} y destination y
		/// @param {Bool} forceResize
		/// @param {Bool} updateCache
		static CopyCanvas = function(_canvas, _x, _y, _forceResize = false, _updateCache = __writeToCache) {
			if (!CanvasIsCanvas(_canvas)) {
				__CanvasError("Canvas " + string(_canvas) + " is not a valid Canvas instance!");
			}
			
			__validateContents();
			CopySurface(_canvas.GetSurfaceID(), _x, _y, _forceResize, _updateCache);
			return self;
		}
		
		/// @param {Canvas} Canvas
		/// @param {Real} x destination x
		/// @param {Real} y destination y
		/// @param {Real} xs source x
		/// @param {Real} ys source y
		/// @param {Real} ws source width
		/// @param {Real} hs source height
		/// @param {Bool=false} forceResize
		/// @param {Bool} updateCache
		static CopyCanvasPart = function(_canvas, _x, _y, _xs, _ys, _ws, _hs, _forceResize = false, _updateCache = __writeToCache) {
			if (!CanvasIsCanvas(_canvas)) {
				__CanvasError("Canvas " + string(_canvas) + " is not a valid Canvas instance!");	
			}
			
			__validateContents();
			CopySurfacePart(_canvas.GetSurfaceID(), _x, _y, _xs, _ys, _ws, _hs, _forceResize, _updateCache);
			return self;
		}
		
		static IsAvailable = function() {
			return (__status == CanvasStatus.HAS_DATA) || (__status == CanvasStatus.HAS_DATA_CACHED);	
		}
		
		/// @param {Id.Surface} surfID
		/// @param {Real} x destination x
		/// @param {Real} y destination y
		/// @param {Bool=false} forceResize
		/// @param {Bool} updateCache
		static CopySurface = function(_surfID, _x, _y, _forceResize = false, _updateCache = __writeToCache) {
			if (!surface_exists(_surfID)) {
				__CanvasError("Surface " + string(_surfID) + " doesn't exist!");	
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
			
			__status = CanvasStatus.HAS_DATA;
			
			return self;
		}
		
		/// @param {Id.Surface} surfID
		/// @param {Real} x destination x
		/// @param {Real} y destination y
		/// @param {Real} xs source x
		/// @param {Real} ys source y
		/// @param {Real} ws source width
		/// @param {Real} hs source height
		/// @param {Bool=false} forceResize
		/// @param {Bool} updateCache
		static CopySurfacePart = function(_surfID, _x, _y, _xs, _ys, _ws, _hs, _forceResize = false, _updateCache = __writeToCache) {
			if (!surface_exists(_surfID)) {
				__CanvasError("Surface " + string(_surfID) + " doesn't exist!");	
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
			
			__status = CanvasStatus.HAS_DATA;
			
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
					if (surface_exists(__surface)) buffer_set_surface(__buffer,__surface, 0);
				}
			} 
			return self;
		}
		

		/// @param {Real} width new width
		/// @param {Real} height new height
		/// @param {Bool} keepData 
		static Resize = function(_width, _height, _keepData = false) {
			
			if (__width == _width) && (__height == _height) return self;
			if (_width <= 0) || (_height <= 0) return self;
			
			__width = _width;
			__height = _height;
			
			if (__isAppSurf) {
				surface_resize(application_surface, __width, __height);	
				return self;
			}
			
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
				buffer_resize(__buffer, _width*_height*__format);
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
		
		/// @param {Bool} forceCompress 
		static GetBufferContents = function(_forceCompress = false) {
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
		
		/// @param {Buffer} buffer 
		/// @param {Real} offset 
		static SetBufferContents = function(_cvBuff, _offset = 0, _forceFormat = false) {
			buffer_seek(_cvBuff, buffer_seek_start, _offset);
			// Ensure that we aren't on a very old version of Canvas
			var _version = buffer_read(_cvBuff, buffer_u8);
			if (_version < 2) {
				__CanvasError("Setting buffer contents from an older version of Canvas. Please make a new Canvas buffer contents.");	
			}
			var _isCompressed = buffer_read(_cvBuff, buffer_bool);
			var _format = buffer_read(_cvBuff, buffer_u8);
			var _width = buffer_read(_cvBuff, buffer_u16);
			var _height = buffer_read(_cvBuff, buffer_u16);
			
			if (__format != _format) {
				if (!_forceFormat) {
					__CanvasError("Surface format mismatched! Expected: " + string(__CanvasSurfFormat(__format)) + " got " + string(__CanvasSurfFormat(_format)));
					exit;
				}
				Free();
				__updateFormat(_format);
			}
			
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
			
			__refContents.surf = __surface;
			__refContents.buff = __buffer;
			__refContents.cbuff = __cacheBuffer;
			return self;
		}
		
		static GetStatus = function() {
			return __status;	
		}
		
		static SetDepthEnabled = function(_bool) {
			__useDepth = !_bool;	
			return self;
		}
		
		static GetDepthEnabled = function() {
			return __useDepth;	
		}
		
		static Cache = function() {
			if (!buffer_exists(__cacheBuffer)) {
				if (buffer_exists(__buffer)) {
					var _size = __width*__height*__bufferSize;
					__cacheBuffer = buffer_compress(__buffer, 0, _size);
					__refContents.cbuff =__cacheBuffer;
					
					// Remove main buffer
					buffer_delete(__buffer);
					/* Feather ignore once GM1043 */
					__buffer = -1;
					__refContents.buff = -1;
					
					// Remove surface
					if (surface_exists(__surface)) {
						surface_free(__surface);	
						/* Feather ignore once GM1043 */
						__surface = -1;
						__refContents.surf = -1;
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
					__refContents.buff = __buffer;
					buffer_delete(__cacheBuffer);
					/* Feather ignore once GM1043 */
					__cacheBuffer = -1;
					__refContents.cbuff = -1;
					// Restore surface
					CheckSurface();
				} else {
					show_error("Canvas: Something terrible has gone wrong with unloading cache data!\nReport it to TabularElf at once!", true);	
				}
			}
			__status = CanvasStatus.HAS_DATA;
			return self;
		}
		
		/// @param {Bool} Boolean
		static SetWriteToCache = function(_bool) {
			__writeToCache = _bool;	
			return self;
		}
		
		static GetWriteToCache = function() {
			return __writeToCache;	
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
				__surface = -1;
				__refContents.surf = -1;
			}
			return self;
		}
		
		static GetTexture = function() {
			return surface_get_texture(GetSurfaceID());
		}
		
		/// @param {Real} x 
		/// @param {Real} y 
		static GetPixel = function(_x, _y) {
			__init();
			if (_x >= __width || _x < 0) || (_y >= __height || _y < 0) return 0;
			var _r, _g, _b, _result, _col;
			
			switch(__format) {
				case surface_rgba8unorm: 
					_col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u32);
					_r = _col & 0xFF;
					_g = (_col >> 8) & 0xFF;
					_b = (_col >> 16) & 0xFF;
					_result = _b << 16 | _g << 8 | _r;
				break;
				case surface_r8unorm: 
					_col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u8);
					_r = _col;
					_result = _r;
				break;
				case surface_rg8unorm: 
					_col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u16);
					_r = _col & 0xFF;
					_g = (_col >> 8) & 0xFF;
					_result = (_g & 0xFF) << 8 | (_r & 0xFF);
				break;
				case surface_rgba4unorm: 
					var _col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u16);
					_r = _col & 0x80;
					_g = (_col >> 4) & 0x80;
					_b = (_col >> 8) & 0x80;
					_result = (_b & 0x80) << 8 | (_g & 0x80) << 4 | (_r & 0x80);
				break;
				case surface_rgba16float:
				case surface_r16float: 
				case surface_rgba32float: 
				case surface_r32float: 
					__CanvasError("GetPixel() does not support " + string(__CanvasSurfFormat(__format)) + ". Please use GetPixelArray()");
				break;
			}
			return _result;
		}
		
		/// @param {Real} x 
		/// @param {Real} y 
		static GetPixelArray = function(_x, _y) {
			__init();
			if (_x >= __width || _x < 0) || (_y >= __height || _y < 0) return [0,0,0,0];
			var _r = 0, _g = 0, _b = 0, _a = 0, _col;
			
			switch(__format) {
				case surface_rgba8unorm: 
					_col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u32);
					_r = _col & 0xFF;
					_g = (_col >> 8) & 0xFF;
					_b = (_col >> 16)  & 0xFF;
					_a = (_col >> 24) / 0xFF;
				break;
				case surface_r8unorm: 
					_col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u8);
					_r = _col;
				break;
				case surface_rg8unorm: 
					_col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u16);
					_r = _col & 0xFF;
					_g = (_col >> 8) & 0xFF;
				break;
				case surface_rgba4unorm: 
					_col = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_u16);
					_r = _col & 0x80;
					_g = (_col >> 4) & 0x80;
					_b = (_col >> 8) & 0x80;
				break;
				case surface_rgba16float:
					_r = buffer_peek(__buffer, (_x + (_y * __width)) * 2, buffer_f16);
					_g = buffer_peek(__buffer, (_x + (_y * __width)) * 4, buffer_f16);
					_b = buffer_peek(__buffer, (_x + (_y * __width)) * 6, buffer_f16);
					_a = buffer_peek(__buffer, (_x + (_y * __width)) * 8, buffer_f16);
				case surface_r16float: 
					_r = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_f16);
				case surface_rgba32float: 
					_r = buffer_peek(__buffer, (_x + (_y * __width)) * 4, buffer_f32);
					_g = buffer_peek(__buffer, (_x + (_y * __width)) * 8, buffer_f32);
					_b = buffer_peek(__buffer, (_x + (_y * __width)) * 12, buffer_f32);
					_a = buffer_peek(__buffer, (_x + (_y * __width)) * 16, buffer_f32);
				case surface_r32float: 
					_r = buffer_peek(__buffer, (_x + (_y * __width)) * __bufferSize, buffer_f32);
				break;
			}
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
		
		static GetFormat = function() {
			return __format;		
		}
		
		/// @param {Real} x 
		/// @param {Real} y 
		static Draw = function(_x, _y) {
			__validateContents();
			CheckSurface();
			draw_surface(__surface, _x, _y);
		}
		
		/// @param {Real} _x 
		/// @param {Real} _y 
		/// @param {Real} _xscale
		/// @param {Real} _yscale 
		/// @param {Real} _rot
		/// @param {Real} _col
		/// @param {Real} _alpha
		static DrawExt = function(_x, _y, _xscale, _yscale, _rot, _col, _alpha) {
			__validateContents();
			CheckSurface();
			draw_surface_ext(__surface, _x, _y, _xscale, _yscale, _rot, _col, _alpha);
		}
		
		/// @param {Real} x 
		/// @param {Real} y 
		static DrawTiled = function(_x, _y) {
			__validateContents();
			CheckSurface();
			draw_surface_tiled(__surface, _x, _y);
		}
		
		/// @param {Real} x 
		/// @param {Real} y 
		/// @param {Real} xscale
		/// @param {Real} yscale 
		/// @param {Real} colour
		/// @param {Real} alpha
		static DrawTiledExt = function(_x, _y, _xscale, _yscale, _col, _alpha) {
			__validateContents();
			CheckSurface();
			draw_surface_tiled_ext(__surface, _x, _y, _xscale, _yscale, _col, _alpha);
		}
		
		/// @param {Real} left
		/// @param {Real} top
		/// @param {Real} width
		/// @param {Real} height 
		/// @param {Real} x 
		/// @param {Real} y 
		static DrawPart = function(_left, _top, _width, _height, _x, _y) {
			__validateContents();
			CheckSurface();
			draw_surface_part(__surface, _left, _top, _width, _height, _x, _y);
		}
		
		/// @param {Real} left
		/// @param {Real} top
		/// @param {Real} width
		/// @param {Real} height 
		/// @param {Real} x 
		/// @param {Real} y 
		/// @param {Real} xscale
		/// @param {Real} yscale 
		/// @param {Real} colour
		/// @param {Real} alpha
		static DrawPartExt = function(_left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha) {
			__validateContents();
			CheckSurface();
			draw_surface_part_ext(__surface, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _col, _alpha);
		}
		
		/// @param {Real} x
		/// @param {Real} y
		/// @param {Real} width
		/// @param {Real} height 
		static DrawStretched = function(_x, _y, _width, _height) {
			__validateContents();
			CheckSurface();
			draw_surface_stretched(__surface, _x, _y, _width, _height);
		}
		
		/// @param {Real} x
		/// @param {Real} y
		/// @param {Real} width
		/// @param {Real} height 
		/// @param {Real} colour
		/// @param {Real} alpha
		static DrawStretchedExt = function(_x, _y, _width, _height, _col, _alpha) {
			__validateContents();
			CheckSurface();
			draw_surface_stretched_ext(__surface, _x, _y, _width, _height, _col, _alpha);
		}
		
		/// @param {Real} left
		/// @param {Real} top
		/// @param {Real} width
		/// @param {Real} height 
		/// @param {Real} x
		/// @param {Real} y
		/// @param {Real} xscale
		/// @param {Real} yscale 
		/// @param {Real} rot
		/// @param {Real} colour1
		/// @param {Real} colour2
		/// @param {Real} colour3
		/// @param {Real} colour4
		/// @param {Real} alpha
		static DrawGeneral = function(_left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _col1, _col2, _col3, _col4, _alpha) {
			__validateContents();
			CheckSurface();
			draw_surface_general(__surface, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _rot, _col1, _col2, _col3, _col4, _alpha);
		}
	#endregion
		
		#region Internal Methods
		
		static __refreshSurface = function() {
			surface_free(__surface);
			CheckSurface();
		}
			
		static __copyBufferContents = function(_bufferToCopy, _forceCompressed = false) {
			// Send copied buffer as a result
			var _size = buffer_get_size(_bufferToCopy);
			var _isCompressed = (_forceCompressed ? true: (GetStatus() == CanvasStatus.HAS_DATA_CACHED ? true : false));
			var _buffer = buffer_create(_size+__CANVAS_HEADER_SIZE, buffer_fixed, 1);
			buffer_write(_buffer, buffer_u8, __CANVAS_HEADER_VERSION);
			buffer_write(_buffer, buffer_bool, _isCompressed);
			buffer_write(_buffer, buffer_u8, __format);
			buffer_write(_buffer, buffer_u16, __width);
			buffer_write(_buffer, buffer_u16, __height);
			buffer_copy(_bufferToCopy, 0, _size, _buffer, __CANVAS_HEADER_SIZE);
			/* Feather ignore once GM1035 */	
			return _buffer;
		}
			
		static __SurfaceCreate = function() {
			if (!surface_exists(__surface)) {
				if (__isAppSurf) {
					__surface = application_surface;
					exit;
				}
				var _oldDepthDisabled = surface_get_depth_disable();
				surface_depth_disable(__useDepth);
				__surface = surface_create(__width, __height, __format);
				surface_depth_disable(_oldDepthDisabled);
				__refContents.surf = __surface;
			}
		}
		
		static __UpdateCache = function() {
			if (!surface_exists(__surface)) exit;
			buffer_get_surface(__buffer, __surface, 0);
			__status = CanvasStatus.HAS_DATA;	
		}
			
		static __validateContents = function() {
			if (!IsAvailable()) {
				__CanvasError("Canvas has no data or in use!");		
			}	
		}
			
		static __init = function() {
			if (!buffer_exists(__buffer)) {
				if (buffer_exists(__cacheBuffer)) {
					// Lets decompress it
					Restore();
				} else {
					__buffer = buffer_create(__width * __height * __bufferSize, buffer_fixed, 1);	
					__refContents.buff = __buffer;
				}
			}
		}
		
		static __updateFormat = function(_format) {
			__format = _format;
			switch(_format) {
				case surface_rgba8unorm: __bufferSize = 4; break;
				case surface_r8unorm: __bufferSize = 1; break;
				case surface_rg8unorm: __bufferSize = 2; break;
				case surface_rgba4unorm: __bufferSize = 2; break;
				case surface_rgba16float: __bufferSize = 8; break;
				case surface_r16float: __bufferSize = 2; break;
				case surface_rgba32float: __bufferSize = 16; break;
				case surface_r32float: __bufferSize = 4; break;
				default: __CanvasError("Invalid surface format! Got " + string(_format)); break;
			}	
		}
		
		#endregion
}
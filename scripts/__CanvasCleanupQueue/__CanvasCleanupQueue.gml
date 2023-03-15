function __CanvasCleanupQueue() {
			var _size = ds_list_size(GCList);
			var _totalTime = get_timer() + 5000;
			var _totalInstancesCleaned = 0;
			repeat(_size) {
				var _isCleanedProper = true;
				var _contents = GCList[| 0];
				if (surface_exists(_contents.surf)) {
					surface_free(_contents.surf);	
					_isCleanedProper = false;
				}
				
				if (buffer_exists(_contents.buff)) {
					buffer_delete(_contents.buff);	
					_isCleanedProper = false;
				}
				
				if (buffer_exists(_contents.cbuff)) {
					buffer_delete(_contents.cbuff);	
					_isCleanedProper = false;
				}
				
				if (!_isCleanedProper) {
					++_totalInstancesCleaned;
				}
				ds_list_delete(GCList, 0);
				if (get_timer() >= _totalTime) {
					show_debug_message("Canvas: Lost references: Garbage collected " + string(_totalInstancesCleaned));
					exit;
				}
			}
			
			if (_totalInstancesCleaned > 0) {
				show_debug_message("Canvas: Lost references: Garbage collected " + string(_totalInstancesCleaned));	
			}
		}
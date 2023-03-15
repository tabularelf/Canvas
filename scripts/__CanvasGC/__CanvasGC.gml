function __CanvasGC() {
	var _size = ds_list_size(refList);
	static _i = 0;
	_i = _i % _size;
	var _totalTime = get_timer() + 50;
	repeat(_size) {
		if (!weak_ref_alive(refList[| _i][0])) {
			var _isCleanedProper = true;
			var _contents = refList[| _i][1];
			ds_list_add(GCList, _contents);
			
			ds_list_delete(refList, _i);
			--_i;
			_size--;
		}
		_i = (_i+1) % _size;
		
		if (get_timer() >= _totalTime) exit;
	}
}
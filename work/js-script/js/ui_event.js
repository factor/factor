var UI_EVENT_MODULE = UI_EVENT_MODULE || function() {

	var keys = {
		'enter': 13,
		'esc': 27
	}
	
	var keys_pressed = {}
	
	$(function() {
		bindListenKeys();
	});

	return {
		'hasBeenPressed': hasBeenPressed,
		'clearKey': clearKey
	}
	
	function bindListenKeys() {
		$('body').keyup(function(event) {
			var key = getKey(event);

			if(!!key) {
				keys_pressed[key] = true;
			}
		});
	}

	function hasBeenPressed(key) {
		return keys_pressed[key] !== undefined;		
	}
	
	function clearKey(key) {
		delete keys_pressed[key];
	}
	
	function getKey(ui_event) {
		var keyCode = ui_event.keyCode || ui_event.which;

		for(var key in keys) {
			if(keys.hasOwnProperty(key)) {
				if(keys[key] === keyCode) return key; 
			}
		}
		
		return false;
	}
	
}();

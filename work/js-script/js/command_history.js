/**
	Command history for cycling through.
*/

	var JSFACTOR_COMMAND_HISTORY = JSFACTOR_COMMAND_HISTORY || function() {
		var history = [];
		var position = 0;
		var MAX_LENGTH = 10;
		
		function older() { if(--position < 0) position = 0; }
		function newer() { if(++position >= history.length) position = history.length - 1; }
		function get() { return history[position]; }
		function add(command) { 
		if($.trim(command) !== '') { 
				history.push(command); 
				position = history.length - 1;
			}
			
			if(history.length > MAX_LENGTH) {
				history = history.slice(history.length - MAX_LENGTH, history.length);
			}
		}
		
		return {
			'older': older,
			'newer': newer,
			'get': get,
			'add': add
		}
	}();


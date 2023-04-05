var JSFACTOR_EXAMPLES = JSFACTOR_EXAMPLES || function() {
	function example() {
		var result = [];
		for(var i = 0; i < arguments.length; ++i) result.push(arguments[i]);
		return ["clear"].concat(result);
	}
	
	function canvas_example() {
		var result = [];
		for(var i = 0; i < arguments.length; ++i) result.push(arguments[i]);
		return ["canvas-clear"].concat(result);
	}
	
	var examples = {
	  'dup':			example("4", "dup"),
	  'drop':			example("7", "3", "drop"),
	  'nip':			example("20", "10", "nip"),
	  'over': 		example("3", "5", "over"),
	  'swap': 		example("2", "7", "swap"),
	  'if': 			example("3 0 >", '[ "hello" ]', '[ "goodbye" ]', "if"),
	  'when': 		example('3 0 >', '[ "hello" ]', 'when'),
	  'curry': 		example('3', '[ 2 + ]', 'curry'),
	  'map': 			example('{ 1 2 3 }', '[ dup * ]', 'map'),
	  'each': 		example('{ 4 7 }', '[ dup ]', 'each'),
	  'keep': 		example('5', '[ 2 + ]', 'keep'),
	  'dip': 			example('30', '5', '[ 2 + ]', 'dip'),
	  'filter': 	example('{ 1 2 3 4 }', '[ 2 mod 0 = ]', 'filter'),
	  'compose': 	example('5 [ 2 > ]', '[ not ]', 'compose', 'call'),
	  'line': 		canvas_example('40 40 100 100', 'line'),
	  'rect': 		canvas_example('40 40 100 100', 'rect'),
	  'color': 		canvas_example('30 50 100', 'color')
	};
	
	return {
		'examples': function() { return examples; }
	}
		
}();

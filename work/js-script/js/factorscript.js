$(function() {
  var factorCodeSelector = ".factorcode";
  
  function appendToResult(value) {
  	var html = "<div class='stackvalue'>" + value + "</div>";
  	$('.result').append(html);
  }
  
	var interpreter = initializeInterpreter({
	 'clear': function() {},
	 'append': appendToResult,
	 'refresh': function() { }
	});
	interpreter.setSelf(interpreter);

	function execute(input) {
		interpreter.execute(input);
	}
	
	function getCleanedInput(input) {
		var result = "";
		
		JSFACTOR_GENERIC.for_each(input, 
			function(elem) { 
				if(elem.toString() !== '\t' && elem.toString() !== '\r' && elem.toString() !== '\n') result += elem;
				else result += ' ';
			});
		
		return result;
	}
	
	function executeFactorscripts() {
		$(factorCodeSelector).each(function(index, elem) {
				var input = getCleanedInput($(this).html());
				execute(input);
		});
	};

	function show_stack() {
		JSFACTOR_GENERIC.for_each(interpreter.stack(), 
			function(elem) { 
				appendToResult(interpreter.toString(elem)); 
			});
	}
	
	executeFactorscripts();
  show_stack();	
});

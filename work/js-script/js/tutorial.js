function initTutorial () {
	var generic = JSFACTOR_GENERIC;
	
	var output = {
		'clear': function(value) {},
		'append': function(value) { alert(value); },
		'refresh': function() {}
	};
	
	var interpreter = initializeInterpreter(output);
	
	function escapeHTML (string) {
		var div = document.createElement('div');
		var text = document.createTextNode(string);
		div.appendChild(text);
		return div.innerHTML;
  }

	function refresh(elem) {
		var stack = interpreter.stack();
		
		var result = "";
		
		generic.for_each(generic.reverse(stack), function(elem) { 
			result += '<li>' + interpreter.toString(elem) + '</li>'; 
		});
		
		elem.find('ul:nth(1)').html(result);		
	}
	
	function updateAfterStack(codeblock, inputValue) {
		interpreter.setStack([]);

		var value = "";
		var stack = codeblock.find('ul:first li').each(function(index, elem) {
			var stackValue = $(elem).text();
			value = stackValue.toString() + " " + value;
		});
		
		
		value += inputValue;

		interpreter.execute(value);
		
		refresh(codeblock);
	}
	
	$(function() {
		$('.codeblock').each(function() {
				if($(this).find('.input').length > 0) {
					var inputValue = $.trim($(this).find('.input').text());
					updateAfterStack($(this), inputValue);
				}
		});
		
		$('.userinput input').keypress(function(event) {
				if(event.keyCode === 13 || event.keyCode === 10) {
					$(this).parent().find('button').click();
				}
		});
		
		$('.userinput button').click(function(event) {
			var codeblock = $(this).closest('.codeblock');
			var inputValue = $.trim(codeblock.find('input').val());
			updateAfterStack(codeblock, inputValue);
			codeblock.find('input').val('');
		});
		
		$('input:first').focus();
	});
	
}

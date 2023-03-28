var JSFACTOR_NATIVE_WORDS = JSFACTOR_NATIVE_WORDS || function() {
	var generic = JSFACTOR_GENERIC;
	var graph = CANVAS_MODULE;
	var ui_event = UI_EVENT_MODULE;

	var environments = [];

	function getEnvironment() { return environments[environments.length - 1]; }
  function setStack(stack) { return getEnvironment().setStack(stack); }
	function getStack() { return getEnvironment().getStack(); }
	function getOutput() { return getEnvironment().getOutput(); }
	
	function wordDef(word, stack_effect, description) {
		return {
		  'word': word,
		  'description': description,
		  'stack_effect': stack_effect
		}
	}
	
	function categoryDef(operations, description) {
		return {
			'operations': operations,
			'description': description
		}
	}

  function code(body) {
  	return "&lt;span class='code'&gt;" + body.replace(' ', '&nbsp;') + "&lt;/span&gt;";
  }

  function codeline(body) {
  	return "&lt;div class='codeline'&gt;" + body.replace(' ', '&nbsp;') + "&lt;/div&gt;";
  }
  
	var categories = {
		'shuffle': categoryDef(['dup', 'drop', 'over', 'swap', 'nip'], "Shuffle words change the stack in trivial manners. They copy elements or move their relative places. Learn these first!"),
		'combinator (basic)': categoryDef(['while', 'until', 'if', 'if*', 'when', 'when*'], "Combinators are words that take quotations from stack and call them. These are basic combinatorics for conditional evaluation. While and until are not very idiomatic to Factor, though. Prefer advanced combinators instead."), 
		'combinator (adv.)': categoryDef(['map', 'each', 'filter', 'keep', 'dip', 'compose', 'curry'], "Combinators that are a bit complex. Used for composing quotations together or with a sequence."),
		'combinator (cleave)': categoryDef(['cleave', 'bi', '2bi', 'tri', 'bi@', 'bi*'], "Cleave combinators deal with multiplicity of quotations or elements. e.g. They apply different quotations to same object, or one quotation to many objects. Very handy for complex operations."), 
		'math': categoryDef(['+', '-', '*', '/', '<', '>', '=', 'or', 'and', 'not', 'mod', 'sin', 'cos'], "Logical or arithmetic operations. NOTE: doesn't reflect the true number system of Factor yet!"),
		'sequence': categoryDef(['<array>', ',', 'at*', '>alist', 'assoc-size', 'reduce'], "Sequence operations for e.g. arrays "+ code("{ 1 2 3 }") + " and association lists " + codeline('H{ { 1 "foo" } { 2 "bar" } }') ),
		'graph': categoryDef(['line', 'rect', 'color', 'canvas-clear'], "Very limited methods to draw on HTML5 canvas that is shown in the bottom of the screen. WARNING: is in experimental stage and is known to have problems but will be polished later. Turtles? Who knows."),
		'misc': categoryDef(['clear', 'call', '.', 'get', 'set', 'sleep', 'pressed', 'random'], "Miscellaneous operations, mostly for interacting with the environment.")		
	}
	
	var factor_words = {
		'bi': wordDef(factor_bi, "( x p q -- )", "Applies p quote to x and then applies q to x"),
		'2bi': wordDef(factor_2bi, "( x y p q -- )", "Applies p to x and y and then applies q to x and y"),
		'tri': wordDef(factor_tri, "( x p q r -- )", "Applies p to x, then q to x, and lastly r to x"),
		'bi@': wordDef(factor_bi_at, "( x y quot -- )", "Applies the quot to x and then to y"),
		'bi*': wordDef(factor_bi_star, "( x y p q -- )", "Applies p to x and then q to y"),
		'at*': wordDef(factor_assoc_at, "( key assoc -- value/f ? )", "Outputs the value related to given key in assoc, and if there is such value, then f. Additionally, outputs t or f, telling whether key existed, respectively."),
		'assoc-size': wordDef(factor_assoc_size, "( assoc - n )", "Outputs the number of elements in assoc."),
		'>alist': wordDef(factor_assoc_tolist, "( assoc - {...} )", "Outputs assoc as an association list (array with pairs)."),
		'curry': wordDef(factor_curry, "( obj quot -- newquot )", "Outputs a new quotation which when called first pushes obj and then calls original quot."),  
		'if': wordDef(factor_if, "( ? true false -- )", "Depending on the topmost value, calls either quotation 'true' or 'false'."),
		'if*': wordDef(factor_if_star, "( cond true false -- )", "If cond is true, the quote 'true' is called with cond still on the stack. Otherwise the quote 'false' is called without cond on the stack."),
		'when': wordDef(factor_when, "( cond true -- )", "If cond is not f, calls the quote 'true'."),
		'when*': wordDef(factor_when_star, "( cond true -- )", "If cond is not f, calls the quote 'true' with cond on the stack."),
		'while': wordDef(factor_while, "( ok? ( -- ? ) body: ( -- ) -- )", "Looping construct. Calls 'body' until 'ok?' is f."),
		'until': wordDef(factor_until, "( pred: ( -- ? ) body: ( -- ) -- )", "Calls the quote 'body' so long as pred gives t."),
		'map': wordDef(factor_map, "( seq1 quot -- seq2 )", "Applies quote to every element in sequence. Result is new sequence."),
		'each': wordDef(factor_each, "( seq1 quot -- seq2 )", "Applies quote on each element on the sequence."),
		'keep': wordDef(factor_keep, "( x quot -- x )", "Calls quote, and restore element below quote afterwards."),
		'dip': wordDef(factor_dip, "( x quot -- x )", "Calls quote without the element below it. Puts element back on top afterwards."),
		'filter': wordDef(factor_filter, "( seq pred -- newseq )", "Calls 'pred' quote on each element on seq. Each element that yields true will be added into the result sequence (preserving order)."),    
		'cleave': wordDef(factor_cleave, "( x seq-of-quot -- )", "Applies each quot in the sequence to x"),
		'dup': wordDef(factor_dup, "( x -- x x )" , "Duplicates element."),
		'drop': wordDef(factor_drop, "( x -- )", "Removes element."), 
		'nip': wordDef(factor_nip, "( x y -- y )", "Drops 2nd topmost value."),
		'over': wordDef(factor_over, "( x y  -- x y x )", "Copies 2nd topmost element."), 
		'clear': wordDef(factor_clear, "( -- )", "Clears stack and history."),
		'or': wordDef(factor_or, "( obj1 obj2 )", "Generalized or: outputs the first value that is not f. If no such value, then outputs f."),
		'and': wordDef(factor_and, "( obj1 obj2 )", "Generalized and: outputs obj2 is both are not f. Otherwise outputs f."),
		'not': wordDef(factor_not, "( obj -- ? )", "Outputs t if obj is f, else outputs t."),		
		'+': wordDef(factor_plus, "( x y -- x+y )", "Sums up two elements."),
		'-': wordDef(factor_minus, "( x y -- x-y )", "Substracts top element from 2nd topmost element."),
		'*': wordDef(factor_multiply, "( x y -- x*y )", "Multiplies two elements."),
		'/': wordDef(factor_divide, "( x y -- x/y )", "Divides topmost element from 2nd topmost element."),
		'<': wordDef(factor_lower_than, "( x y -- x<y )", "Whether 2nd topmost value is lower than topmost value."),
		'>': wordDef(factor_greater_than, "( x y -- x>y )", "Whether 2nd topmost value is greater than topmost value."),
		'=': wordDef(factor_equals, "( x y -- x=y )", "If two topmost values on the stack are equal, then t, else f."),
		'mod': wordDef(factor_mod, "( x y -- z )", "Remainder of dividing x by y."),
		'call': wordDef(factor_call, "( callable -- )", "Calls a callable element, .e.g. for quotation it means applying."),
		'swap': wordDef(factor_swap, "( x y -- y x )", "Changes order of the two topmost elements."),
		'.': wordDef(factor_print, "( x -- )", "Prints element to result."),
		'<array>': wordDef(factor_make_array, "( n elem -- array )", "Creates array of n amount of elements, initialized to elem."),
		',': wordDef(factor_append_to_sequence, "( elt -- )", "Adds an element to the end of sequence."),
		'reduce': wordDef(factor_reduce, "( seq identity quot -- value )", "Calls call quot for each element with the result of previous call. Uses identity for first element call. e.g. " + codeline("{ 1 2 } 0 [ + ] reduce") + " is equivalent to " + codeline("0 1 + 2 +") + " which is " + code("3") + "."),  
		'compose': wordDef(factor_compose, "( quot1 quot2 -- newquot )", "Composes two quotations into new one that when called will first call quot1 and then quot2."),
		'get': wordDef(factor_symbol_get, "( symbol -- value )", "Gets value for symbol (by going through name stack), or f if not found."),
		'set': wordDef(factor_symbol_set, "( value symbol -- )", "Sets value to the symbol in current namespace."),
		'line': wordDef(factor_graph_line, "( x1 y1 x2 y2 -- )", "Draws line to canvas from (x1, y1) to (x2, y2)."),
		'rect': wordDef(factor_graph_rectangle, "( x1 y1 x2 y2 -- )", "Draws rectangle to canvas where (x1, y1) is left upper corner and (x2, y2) right bottom corner."),
		'color': wordDef(factor_graph_set_color, "( r g b -- )", "Set fill color as rgb for canvas drawing."), 
		'canvas-clear': wordDef(factor_graph_clear, '( -- )', "Clears drawing canvas"),
		'sleep': wordDef(factor_sleep, "( duration -- )", "Waits duration (in milliseconds) before proceeding to next word. WARNING: in experimental stage. Works only in non-complex expressions."),
		'pressed': wordDef(factor_key_pressed, "( key -- ? )", "Whether given key has been pressed. Note: clears press history, so 'enter pressed enter pressed' will give t f or f f unless user presses enter after first pressed call. Supported keys are \"enter\" and \"esc\". WARNING: is in experimental stage. Works only in non-complex expressions."),
		'random': wordDef(factor_random, "( n -- random )", "Gives a random value from [0, n)"),
		'sin': wordDef(factor_sin, "( n -- [-1,1] )", "Javascript sin."),
		'cos': wordDef(factor_cos, "( n -- [-1,1] )", "Javascript cos."),
		'$': wordDef(factor_jquery0, "( method selector -- ", "jQuery call, no arguments. Selector is jQuery selector expression as string, method is no-argument method."),
		'$1': wordDef(factor_jquery1, "( value method selector -- ", "jQuery call with one argument."),
		'$2': wordDef(factor_jquery2, "( value attribute method selector -- ", "jQuery call with two arguments."),
		'$$': wordDef(factor_jquery_fun, "( quoation selector -- ", "jQuery call with quotation (function).")
	};

	
	return {
		'categories': function() { return categories; },
		'words': function () { return factor_words; },
		'pushEnvironment': function(environment) { environments.push(environment); },
		'popEnvironment': function(environment) { return environments.pop(); }
	}

	function executeAll(input) {
		getEnvironment().executeAll(input);
	}
	
	function executeQuote(quote) {
		getEnvironment().executeAll(quote.quote);
	}

	function factor_sin() {
		var num = asNumber(popValueFromStack());
		pushToStack(Math.sin(num));
	}

	function factor_cos() {
		var num = asNumber(popValueFromStack());
		pushToStack(Math.cos(num));
	}
	
	function popSymbolFromStack() {
		var variable = popValueFromStack();
		if(!getEnvironment().isSymbol(variable)) throw "variable '" + variable + "' is not symbol";
		return variable;
	}
	
	function factor_jquery2() {
		var selector = popValueFromStack();
		var property = popString();
		var attribute = popString(); 
		var value = popValueFromStack();

		getEnvironment().evaluateJquery2(selector, property, attribute, value);		
	}

	function factor_jquery1() {
		var selector = popValueFromStack();
		var property = popString();
		var value = popValueFromStack();

		getEnvironment().evaluateJquery1(selector, property, value);		
	}

	function factor_jquery0() {
		var selector = popValueFromStack();
		var property = popString();

		getEnvironment().evaluateJquery0(selector, property);		
	}
	
	function factor_jquery_fun() {
		var selector = popString();
		var property = popString();
		var quotation = popQuotation();
		
		getEnvironment().bindJqueryFun(selector, property, quotation);		
	}
	
	function factor_symbol_get() {
		var variable = popSymbolFromStack();
		var value = getEnvironment().getValueFromSymbol(variable);
		
		if(value !== undefined) {
			pushToStack(value);
		} else {
			pushToStack(getEnvironment().f);
		}
	}
	
	function factor_symbol_set() {
		var variable = popSymbolFromStack();
		var value = popValueFromStack();

		getEnvironment().setValueForSymbol(value, variable);
	}
	
	function factor_bi() {
		executeAll([createQuote(["keep"]), "dip", "call"]);
	}
	
	function factor_2bi() {
		var q = popQuotation();
		var p = popQuotation();
		var y = popValueFromStack();
		var x = popValueFromStack();
		
		executeAll([x, y, p, "call", x, y, q, "call"]);
	}

	function factor_tri() {
		var r = popQuotation();
		var q = popQuotation();
		var p = popQuotation();
		var x = popValueFromStack();
		
		executeAll([x, p, "call", x, q, "call", x, r, "call"]); 
	}
	
	function factor_bi_at() {
		var quot = popQuotation();
		var y = popValueFromStack();
		// x is on the stack

		executeAll([quot, "call", y, quot, "call"]);
	}

	function factor_bi_star() {
		var q = popQuotation();
		var p = popQuotation();
		var y = popValueFromStack();
		// x is on the stack

		executeAll([p, "call", y, q, "call"]);
	}

	function factor_reduce() {
		var quot = popQuotation();
		var identity = popValueFromStack();
		var seq = popSequence();

		pushToStack(identity);
		pushToStack(seq);
		pushToStack(quot);

		executeAll(["each"]);		
	}
	
	function factor_nip() {
		var top = popValueFromStack();
		popValueFromStack(); // drop 2nd topmost value		
		pushToStack(top);
	}
	
	function factor_curry() {
		var quot = popQuotation();
		var obj = popValueFromStack();
		
		// we differentiate quotations with name params mainly because of toString
		if(!!quot.lexicalVariables) {
			pushToStack(createQuote([obj, quot, "call"]));
		} else {
			pushToStack(createQuote([obj].concat(quot.quote))); // FIXME: too low level here
		}
	}
	
	function factor_compose() {
		var quot2 = popQuotation();
		var quot1 = popQuotation();

		// we differentiate quotations with name params mainly because of toString
		if(!!quot1.lexicalVariables || !!quot2.lexicalVariables) {
			pushToStack(createQuote([quot1, "call", quot2, "call"]));
		} else {
			pushToStack(createQuote(quot1.quote.concat(quot2.quote))); // FIXME: too level here
		}
	}

	function factor_assoc_at() {
		var assoc = popAssoc();
		var key = popValueFromStack();

		var result = getEnvironment().assocFind(assoc, key);

		if(result !== undefined) {
			pushToStack(result);
			pushToStack(getEnvironment().t); // indication of success
		} else {
			pushToStack(getEnvironment().f); // value
			pushToStack(getEnvironment().f); // indication of failure
		}
	}
	
	function factor_assoc_size() {
		var assoc = popAssoc();
		
		pushToStack(getEnvironment().assocSize(assoc));
	}
	
	function factor_assoc_tolist() {
		var assoc = popAssoc();
		
		pushToStack(getEnvironment().assocToList(assoc));
	}
	
	// FIXME: mod and rem
	function factor_mod() {
		var y = asNumber(popValueFromStack());
		var x = asNumber(popValueFromStack());
		
		//FIXME: check that x and y are numbers
		pushToStack(x % y);
	}
	
	function factor_filter() {
		var pred = popQuotation();
		var seq = popSequence();
		
		pushToStack(getEnvironment().createArray([]));
		var quote = createQuote(["dup", pred, "call", createQuote([","]), createQuote(["drop"]), "if"]);
		executeQuoteOnSequence(quote, seq);
		// top element is now new array with elements from original sequence filtered by predicate
	}
	
	function factor_not() {
		var value = popValueFromStack();
		
		if(isTrue(value)) {
			pushToStack(getEnvironment().f);
		} else {
			pushToStack(getEnvironment().t);
		}
	}
	
	function factor_or() {
		var topElement = popValueFromStack();
		var secondElement = popValueFromStack();
		
		if(isTrue(secondElement)) {
			pushToStack(secondElement);
		} else if(isTrue(topElement)) {
			pushToStack(topElement);
		} else {
			pushToStack(getEnvironment().f);
		}
	}
	
	function factor_and() {
		var topElement = popValueFromStack();
		var secondElement = popValueFromStack();
		
		if(isTrue(secondElement) && isTrue(topElement)) {
			pushToStack(topElement);
		} else {
			pushToStack(getEnvironment().f);
		}
	}
	
	function factor_when() {
		executeAll(["swap", createQuote(["call"]), createQuote(["drop"]), "if"]);
	}

	function factor_when_star() {
		executeAll(["over", createQuote(["call"]), createQuote(["drop", "drop"]), "if"]);
	}
	
	function factor_until() {
		var quote = popQuotation();
		var pred = popQuotation();
		
		var predForWhile = createQuote([pred, "call", "not"]);
		executeAll([predForWhile, quote, "while"]);
	}

	function factor_if_star() {
		var falseQuote = popQuotation();
		var trueQuote = popQuotation();
		var cond = popValueFromStack();
		
		if(getEnvironment().isTrue(cond)) {
			pushToStack(cond);
			executeQuote(trueQuote);	
		} else {
			executeQuote(falseQuote);
		}		
	}

	function factor_append_to_sequence() {
		var element = popValueFromStack();
		var sequence = popSequence();

		// in-place mutation
		// FIXME, should be probably indirected via interpreter's environment; now we have hard dependancy 
		sequence.array = sequence.array.concat(element); // make generic
		
		pushToStack(sequence);
	}

	function factor_cleave() {
		var sequenceOfQuots = popSequence();
		//var value = popValueFromStack();
		
		var q = [ "keep" ];
		var quote = createQuote(q);

		executeQuoteOnSequence(quote, sequenceOfQuots);
		factor_drop(); // remove object		
	}
	
	function factor_drop() {
		popValueFromStack();
	}
	
	function factor_clear() {
		setStack([]);
		getOutput().clear();
	}	

	function factor_over() {
		var values = popFromStack(2);
		pushToStack(values[0]);
		pushToStack(values[1]);
		pushToStack(values[0]);
	}
	
	function asNumber(value) {
		return getEnvironment().asNumber(value);
	}
	
	function factor_two_numbers(fun) {
		var values = popFromStack(2);

		var first = asNumber(values[0]);
		var second = asNumber(values[1]);
		var result = fun(first, second);
		pushToStack(result);
	}
	
	function factor_plus() {
		factor_two_numbers(function(n1, n2) { return n1 + n2; });
	}

	function factor_minus() {
		factor_two_numbers(function(n1, n2) { return n1 - n2; });
	}
	
	function factor_multiply() {
		factor_two_numbers(function(n1, n2) { return n1 * n2; });
	}
	
	function factor_divide() {
		factor_two_numbers(function(n1, n2) { return n1 / n2; });
	}

	function createBoolean(value) {
		return getEnvironment().createBoolean(value);
	}
	
	function factor_lower_than() {
		factor_two_numbers(function(n1, n2) { return createBoolean(n1 < n2); });		
	}

	function factor_greater_than() {
		factor_two_numbers(function(n1, n2) { return createBoolean(n1 > n2); });
	}


	function factor_dup() {
		var value = popFromStack(1)[0];
		pushToStack(value);
		pushToStack(value); // FIXME what about copy-semantics with closures?
	}
	
	function factor_make_array() {
		var element = popFromStack(1)[0];
		var numberOfElements = popFromStack(1)[0];
		
		var jsArray = generic.create_array(numberOfElements, element);
		pushToStack(getEnvironment().createArray(jsArray));
	}


	function createQuote(quote) {
	  return getEnvironment().createQuote(quote);
	}
	
	function factor_map() {
		var quote = popQuotation();
		var sequence = popSequence();

		pushToStack(getEnvironment().createArray([])); // array for collecting result

		// stack flow in executeQuoteOnSequence
		// top element is array into where results are collected
		
		// { }              | add first elem from sequence
		// { } elem   			| execute quote words; first: swap
		// elem { }         | secondly: add the parameter quot (given to map)
		// elem { } quot    | dip
		// value { }        | swap
		// { } value        | ,
		
		var q = [ "swap", quote, "dip", "swap", "," ];
		var wrapperQuote = createQuote(q);

		executeQuoteOnSequence(wrapperQuote, sequence);
	}

	function executeQuoteOnSequence(quote, sequence) {
		function executeQuoteOn(elem) {
			pushToStack(elem);
			getEnvironment().executeAll(quote.quote);
		}		
		
		generic.for_each(sequence.array, executeQuoteOn); // FIXME: should be generalized sequence protocol 
	}
	
	function factor_each() {
		var quote = popQuotation();
		var sequence = popSequence();
		
		executeQuoteOnSequence(quote, sequence);
	}
	
	function makeArrayFromStack(n) {
		var values = popFromStack(n);
		pushToStack(getEnvironment().createArray(values));
	}
	
	function factor_call() {
		var value = popQuotation();
		generic.for_each(value.quote, function(elem) { getEnvironment().interpret(elem); });
	}


	function factor_swap() {
		var values = popFromStack(2);
		pushToStack(values.pop());
		pushToStack(values.pop());
	}

	
	function factor_keep() {
		var quot = popQuotation();
		var elem = popValueFromStack();
		
		pushToStack(elem);
		executeQuotation(quot);
		pushToStack(elem);
	}
	
	function factor_dip() {
		var quot = popQuotation();
		var elem = popValueFromStack();
		
		executeQuotation(quot);
		pushToStack(elem);
	}
	
	function executeQuotation(quotation) {
		generic.for_each(quotation.quote, function(elem) { getEnvironment().interpret(elem); });		
	}
	
	function factor_if() {
		var falseQuot = popQuotation();
		var trueQuot = popQuotation();
		var value = popFromStack(1)[0];
	
		executeQuotation(getEnvironment().isTrue(value) ? trueQuot : falseQuot);
	}
	
	function isTrue(value) {
		return getEnvironment().isTrue(value);
	}
	
	function factor_while() {
		var bodyQuot = popQuotation();
		var predicateQuot = popQuotation();

		while(true) {
			executeQuotation(predicateQuot);
			var value = popValueFromStack();
			
			if(isTrue(value)) {
				executeQuotation(bodyQuot);
			} else break;
		}
	}
	
	function factor_random() {
		var value = popValueFromStack();
		var n = asNumber(value);
		
		pushToStack(getEnvironment().random(n));
	}
	
	function popValueFromStack() {
		return popFromStack(1)[0];		
	}
	
	function factor_print(value) {
		output(popFromStack(1));
	}
	
	function factor_graph_rectangle() {
		var values = popFromStack(4);
		var x1 = asNumber(values[0]);
		var y1 = asNumber(values[1]);
		var x2 = asNumber(values[2]);
		var y2 = asNumber(values[3]);
		
		graph.draw_rectangle(x1, y1, x2, y2);
	}

	function factor_graph_line() {
		var values = popFromStack(4);
		var x1 = asNumber(values[0]);
		var y1 = asNumber(values[1]);
		var x2 = asNumber(values[2]);
		var y2 = asNumber(values[3]);
		
		graph.draw_line(x1, y1, x2, y2);
	}
	
	function factor_graph_clear() {
		graph.clear_canvas();
	}
	
	function factor_graph_set_color() {
		var values = popFromStack(3);
		var r = asNumber(values[0]);
		var g = asNumber(values[1]);
		var b = asNumber(values[2]);
		
		graph.set_color(r, g, b);
	}

	function factor_sleep(continuation) {
		var value = popValueFromStack();
		var duration = asNumber(value);
		
		var combinedContinuation = getEnvironment().createContinuation(continuation || function() {});
		setTimeout(combinedContinuation, duration);
		//getEnvironment().sleep(duration, continuation);// || function() {});
		throw "continuation";
	}

	function factor_key_pressed_delayed() {
		var name = popString().string;  //FIXME shouldn't be aware of implementation of string
		
		if(ui_event.hasBeenPressed(name)) {
			pushToStack(getEnvironment().t);
			ui_event.clearKey(name);
		}	else {
			pushToStack(getEnvironment().f);
		}
	}
	
	function factor_key_pressed(continuation) {
		if(continuation === undefined) throw "continuation undefined: probably 'pressed' word used in place where not permitted"; 
			
		function composedContinuation() {
			factor_key_pressed_delayed();
			continuation();
		}
		
		setTimeout(getEnvironment().createContinuation(composedContinuation), 0);
		throw "continuation";
	}
	
	function pushToStack(value) {
		getStack().push(value);
		//output(value);
	}

	function factor_equals() {
		var x = popValueFromStack();
		var y = popValueFromStack();
		
		if(getEnvironment().structuralEquals(x, y)) {
			pushToStack(getEnvironment().t);
		} else {
			pushToStack(getEnvironment().f);
		}
	}
	
	function output(value) {
		getOutput().append(getEnvironment().toString(value));
	}
	
	function popFromStack(num) {
		if(num > getStack().length) {
			throw "stack underflow: not enough elements in stack";
		} else {
			var stack = getStack();
			var length = stack.length;
			return stack.splice(length - num, num);
		}
	}
	
	
	function popOne(check, typeName) {
		var result = popFromStack(1)[0];
		if(!check(result)) throw getEnvironment().toString(result) + " is not " + typeName;
		return result;
	}
	
	function popString() {
		return popOne(getEnvironment().isString, 'string');
	}
	
	function popAssoc() {
		return popOne(getEnvironment().isAssoc, 'assoc'); // FIXME: generalize and change names to assoc
	}
	
	function popQuotation() {
		return popOne(getEnvironment().isQuote, 'quote');
	}

	function popSequence() {
		return popOne(getEnvironment().isSequence, "sequence");
	}
	
}();

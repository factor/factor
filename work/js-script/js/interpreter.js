function initializeInterpreter(output) {
	var generic = JSFACTOR_GENERIC;
	var nativeWords = JSFACTOR_NATIVE_WORDS;
	var parser = JSFACTOR_PARSER;
	
	var stack = [];
	var user_words = {}
	var symbols = {}
	var dynamicValues = {} // from symbols to values

	var Self;
	
	function setSelf(interpreter) { Self = interpreter; }
	
	function getOutput() { return output; }

	var factor_f = { // false
		'type': 'f',
		'value': 'f'
	}
	
	var factor_t = { // true
		'type': 't',
		'value': 't'
	}
	
	var environment = {
		'pushValueToStack': function(value) { stack.push(value); },
		'popValueFromStack': function(value) { return stack.pop; },
		'setStack': function(newStack){ stack = newStack; },
		'getStack': getStack,
		'getOutput': function(){ return output; },
		'executeAll': executeAll,
		'interpret': interpret,
		'addSymbol': addSymbol,
		'isNum': isNum,
		'createArray': createArray,
		'createString': createString,
		'createQuote': createQuote,
		'createAssoc': createAssoc,
		'toString': toString,
		'isQuote': isQuote,
		'isSequence': isSequence,
		'asNumber': asNumber,
		'isAssoc': isAssoc,
		'isString': isString,
		'isSymbol': isSymbol,
		'getValueFromSymbol': getValueFromSymbol,
		'setValueForSymbol': setValueForSymbol,
		'assocFind': assocFind,
		'assocSize': assocSize,
		'assocToList': assocToList,
		'createBoolean': createBoolean,
		'isTrue': isTrue,
		'f': factor_f,
		't': factor_t,
		'addWord': addWord,
		'structuralEquals': structuralEquals,
		'sleep': sleep,
		'random': random,
		'createContinuation': createContinuation,
		'evaluateJquery0': evaluateJquery0,
		'evaluateJquery1': evaluateJquery1,
		'evaluateJquery2': evaluateJquery2,
		'bindJqueryFun': bindJqueryFun		
	}

	
	function createContinuation(continuation) {
		return function() {
			try { continuation(); } 
			catch(e) { output.append(e); }
			
		  output.refresh();
		}
	}
	
	function getStack() { return stack; }
	function setStack(newStack) { stack = newStack; }
	function getUserWords() { return user_words; }
	
	function createSimpleToken(elem) {
		return {
			'type': 'simple',
			'value': elem
		}
	}
	
	function execute(input_) {
		var input = $.trim(input_); //.replace('\s', ' ');
		
		if(input !== "") {
			var backupStack = generic.copy_array(stack);

			try {
				parser.pushEnvironment(environment);
				var parsed = parser.parse(input);
				environment = parser.popEnvironment();
				executeAll(parsed);
			} catch(e) {
				output.append(e);
				output.append("stack was:\n" + toString(stack));
				stack = backupStack;
			}
			
			output.refresh();			
		}

	}

	function out(value) {
		output.append(value.length + " :: " + toString(value));		
	}

	
	//FIXME: parameter should be named better, it's tokens in JS-array
	function executeAll(strings) {
		//generic.for_each(strings, function(elem) { interpret(elem) } );
		try {				
			generic.for_each_indexed(strings, 
				function(elem, index) {
					function continuation() {
						executeAll(strings.slice(index + 1));
					}
					
					interpret(elem, continuation);
				}
			);
		} catch(e) { // we must catch here, cause executeAll is the outermost inside resumed continuation
			if(e === "continuation") {
				return "continuation"; // gracefully escape execution	
			} else throw e;
		}
	}
	
	function interpret(value, continuation) {
		/*
		if(console !== undefined) { // firebug debugging info
			console.log("stack: " + toString(stack));
			console.log("value: " + toString(value));
		}
		*/
		
		if(executeFactorWord(value, continuation)) {}
		else if(isLiteral(value)) {
			stack.push(value);
		} else if(isValidSymbolName(value) && symbols[value] !== undefined) {
			stack.push(symbols[value]);
		} else if(isLexicalGet(value)) {
			lexicalGet(value);
		} else if(isLexicalSet(value)) {
			lexicalSet(value);
		} else {
			throw "Error, no word named '" + toString(value) + "' was found.";
		}
	}
	
	function lexicalGet(get) {
		var value = get.value.fun();
		if(value === undefined) throw "internal error: lexical get gave undefined value";
		stack.push(value);
	}	
	
	function lexicalSet(set) {
		var value = stack.pop()
		if(value === undefined) throw "stack underflow; not enough elemements for named parameters"; // FIXME: more descriptive 
		set.value.fun(value);
	}
	
	function isLiteral(value) {
		return isString(value) ||
					 isNum(value) || 
					 isSequence(value) || 
					 isQuote(value) ||
					 isBoolean(value) ||
					 isAssoc(value) ||
					 isSymbol(value) ||
					 isJqueryObject(value);
	}

	function isJqueryObject(value ) { return value.type === 'jquery'; }
	
	function isString(value) {
		return value.type === 'string';
	}
	
	//FIXME: add ratio and floating point support
	function isNum(value) {
		if(value.type !== undefined) return false; // number isn't wrapped in current implementation
		value = value.toString();
		
		if(value.indexOf('.') >= 0) throw "Floating point not yet supported";
		
		var signIndexOf = value.indexOf('-'); 
		if(signIndexOf > 0) return false; // - sign can be at position 0 but not later
		if(signIndexOf === 0) value = value.substring(1); // remove sign for later processing
		return value.length > 0 && generic.for_all(value, function(elem) { return elem >= '0' && elem <= '9'; });
	}

	// USED by: executeFactorWord
  // returns true/false depending whether word was possible to execute
	function executeUserWord(value, continuation) {
		var word = user_words[value];

		if(word === undefined) {
			return false;
		} else {

			generic.for_each_indexed(word, function(string, index) {
					var rest = word.slice(index + 1);
					
					function combinedContinuation() {
						
						executeAll(rest, continuation);
						
						if(continuation !== undefined) {
							continuation();
						}
					}
					
					interpret(string, combinedContinuation);
					
			}); 
			return true;
		}
	}

	function executeFactorWord(value, continuation) {
		var word = nativeWords.words()[value];
		if(word === undefined) {
			return executeUserWord(value, continuation);
		} else {
			nativeWords.pushEnvironment(environment);
			var result = word.word(continuation);
			environment = nativeWords.popEnvironment();
			return true;
		}
	}

	function addWord(word, definition) {
		user_words[word] = definition;
	}
	
	function createQuote(quote) {
		return {
			'type': 'quote',
			'quote': quote
		}
	}	

	function createArray(value) {
		return {
			'type': 'array',
			'array': value
		}
	}

	function createString(value) {
		return {
			'type': 'string',
			'string': value
		}
	}
	
	function isLexicalSet(value) { return value.type === 'lexical_set'; }
	function isLexicalGet(value) { return value.type === 'lexical_get'; }

	function isSymbol(value) { return value.type === 'symbol'; }

	function isValidSymbolName(value) {
		return 	value !== undefined && 
						$.trim(value.toString()).length > 0 &&
					  generic.for_all(value, function(elem) { return (elem >= 'a' && elem <= 'z') || (elem >= 'A' && elem <= 'Z'); });
	}
	
	function addSymbol(value) {
		generic.okUnless("symbol name '" + value + "' isn't in class [a-Z]", !isValidSymbolName(value)); 

		if(symbols[value] !== undefined) return; // don't redefine, as it would lose the value
			
		symbols[value] = createSymbol(value);
	}
	
	function createSymbol(value) {
		return {
			'type': 'symbol',
			'value': value
		}
	}

	function isQuote(value) {
		return value.type === 'quote';		
	}

	// all values are true except singleton value f
	function isTrue(value) { return value.type !== factor_f.type; }
	
	function isBoolean(value) { return value === factor_t || value === factor_f; }  

	function isSequence(elem) {
		return elem.type === 'array'; // FIXME: add sequence type information
	}
	
	function isAssoc(elem) {
		return elem.type === 'assoc';
	}
	
	function createBoolean(value) {
		if(value === true || value === "true") {
			return factor_t;
		} else if(value === false || value === "false") {
			return factor_f;
		} else throw "Cannot create boolean from: " + toString(value);
	}

	//FIXME: write decent hashmap for javascript, which doesn't have inbuild map
	function createAssoc(value) {
		for(var i = 0; i < value.length; ++i) {
			generic.okUnless("assoc content's must be sequences (with two elements)", !isSequence(value[i]));
			generic.okUnless("assoc { key value } pair's key not given", value[i].array[0] === undefined);
			generic.okUnless("assoc { key value } pair's value not given", value[i].array[1] === undefined);
			generic.assert("number of elements in assoc's { key value } pair", 2, value[i].array.length); 
		}
		
		return {
			'type': 'assoc',
			'value': value
		}
	}	

	function asNumber(value) {
		var result = parseFloat(value);
		
		if(isNaN(result)) {
			throw "'" + toString(value) + "'" + " is not a number";
		}
		
		return result;
	}

	//FIXME: quotations, should it?
	function structuralEquals(v1, v2) {
		// numbers are not wrapperd (they have no type attribute) so they must be tested first
		if(isNum(v1) && isNum(v2)) {
			return v1 == v2;
		} else if(isNum(v1) || isNum(v2)){
			return false;
		}

		if(v1.type === undefined && v2.type === undefined) {
			throw "Equals not supported on words: " + toString(v1) + " = " + toString(v2);
		} else if(v1.type === undefined) {
			throw "Equals: " + toString(v1) + "'s type is undefined";
		}	else if(v2.type === undefined) {
			throw "Equals: " + toString(v2) + "'s type is undefined";
			// Boolean must be checked before ensuring that types are same: because f and t have different types (they are singletons)
			// FIXME: instead of checking types are the same, types should be checked to be equal-compatible 
		} else if(isBoolean(v1)) { 
			return v1.value === v2.value;
		} else if(v1.type !== v2.type) {
			return false;
			// v1 and v2 types are the same from now on
		} else if(isString(v1)) {
			return v1.string === v2.string;
		} else if(isSymbol(v1)) {
			return v1.value === v2.value;
		} else if(isSequence(v1)) {
			if(v1.array.length !== v2.array.length) {
				return false;
			} else {
				// for all 0 <= i < v1.length: v1[i] must equal v2[i] structurally
				for(var i = 0; i < v1.array.length; ++i) {
					if(!structuralEquals(v1.array[i], v2.array[i])) return false;
				}
				
				return true;
			}			
		} else if(isAssoc(v1)) {
			if(v1.value.length !== v2.value.length) {
				return false;
			} else {
				// for all 0 <= i < v1.length: v1[i] must equal v2[i] structurally
				for(var i = 0; i < v1.value.length; ++i) {
					if(!structuralEquals(v1.value[i], v2.value[i])) return false;
				}
				
				return true;
			}
		} else if(isQuote(v1)) {
			throw "Equals on quotation is not supported in this implementation: " + toString(v1) + " = " + toString(v2);
		}
	}


	function assocFind(assoc, key) {
		for(var i = 0; i < assoc.value.length; ++i) {
			var pair = assoc.value[i].array;
			if(structuralEquals(pair[0], key)) return pair[1];
		}
		
		return undefined;
	}

	function assocSize(assoc) {
		return assoc.value.length;	
	}
	
	function assocToList(assoc) {
		// because internally they are the same just put content in array wrapper
		return createArray(assoc.value);  
	}
	
	function join(seq) {
		return generic.reduce("", seq, function(acc, elem) { return acc + (acc !== "" ? " " : "") + toString(elem); })
	}
	
	//FIXME: use isXXX functions instead of checking type
	function toString(elem) {
		if(elem === undefined) {
			return "undefined";
		}
		
		if(generic.isPrimitiveArray(elem)) {
			return join(elem); 
		} else if(elem.type === 'quote') {
			if(elem.lexicalVariables !== undefined) {
				var result = "[| ";
				for(var i = 0; i < elem.lexicalVariables.length; ++i) {
					result += elem.lexicalVariables[i] + " ";
				}
				
				var body = elem.quote.slice(elem.lexicalVariables.length)
				return result + " | " + toString(body) + " ]";
			} else {
				return "[ " + toString(elem.quote) + " ]";
			}
		} else if(elem.type === 'string') {
			return "\"" + elem.string + "\"";			
		} else if(elem.type === 'assoc') {
			//return "H{ " + join(elem.value) + " }";
			return "H{ " + generic.reduce("", elem.value, function(acc, elem) { return acc + " " + toString(elem); }) + " }";
		} else if(elem.type === 'array') {
			return "{ " + toString(elem.array) + " }";
		} else if(elem.type === factor_f.type) {
			return "f";
		} else if(elem.type === factor_t.type) {
			return "t";
		} else if(isSymbol(elem)) {
			return elem.value;
		} else if(isLexicalGet(elem)) { // lexicalSet is not needed, parameters are inlined to quote toString
			return ' ' + elem.value.variableName + ' ';
		} else {
			return elem;
		}
	}


	function getValueFromSymbol(symbol) {
		return dynamicValues[symbol.value];
	}
	
	function setValueForSymbol(value, symbol) {
		dynamicValues[symbol.value] = value;
	}
	
	function currentTimeInMilliseconds() {
		return (new Date).getTime();
	}
	
	function sleep(duration, continuation) {
		if(duration === undefined || duration <= 0) return;
		if(duration > 5000) throw "sleep doesn't support times bigger than 5000 milliseconds";

		setTimeout(continuation, duration); // this implementation is problematic since it cannot be contained in nested expressions
		
		/*
		var start_time = currentTimeInMilliseconds();
		var end_time = start_time + duration; 
		
		while(currentTimeInMilliseconds() < end_time) {};
		*/
	}
	
	function random(n) {
		return Math.ceil(Math.random() * n) - 1; //FIXME add support for random [0, 1]
	}
	
	function removeCustomWord(name) {
		if(user_words.hasOwnProperty(name)) {
		  delete user_words[name];
		}
	}

	/******************************************************************
	  jQuery support    FIXME move to own module
	*******************************************************************/
	
	function getSelectorObject(selector) {
		return isJqueryObject(selector) ? 
						selector.value : $(eval(toString(selector)));
	}
	
	function evaluateJquery2(selector_, property_, attribute_, value_) {
		var selectorObj = getSelectorObject(selector_);
		var property = eval(toString(property_));
		var attribute = eval(toString(attribute_));
		var value = eval(toString(value_));

		selectorObj[property](attribute, value);
	}

	function evaluateJquery1(selector_, property_, value_) {
		var selectorObj = getSelectorObject(selector_);
		var property = eval(toString(property_));
		var value = eval(toString(value_));

		selectorObj[property](value);
	}

	function evaluateJquery0(selector_, property_) {
		var selectorObj = getSelectorObject(selector_);
		var property = eval(toString(property_));

		selectorObj[property]();
	}

  function createJqueryObject(obj) {
  	return {
  		'type': 'jquery',
  		'value': obj
  	};
  }
  
  /**
    binds a delayed computation of quotation for jQuery selector
  */
	function bindJqueryFun(selector_, property_, quotation_) {
		var selector = eval(toString(selector_));
		var property = eval(toString(property_));

		var helperInterpreter = initializeInterpreter({
			'append': function(value) { $('#result').append(value); },
			'clear': function() {},
			'refresh': function() {}
		});

		(function evaluateJquery(interpreter, quotation) {
			$(selector)[property](function() {
				interpreter.stack().push(createJqueryObject($(this)));
				interpreter.stack().push(quotation)
				interpreter.execute("call");
			});
		})(Self, quotation_);			
		//})(helperInterpreter, quotation_);
	}	
	
	/***************************/
	/** MODULE INTERFACE       */
	/***************************/
	
	return {
		'execute': execute,
		'stack': getStack,
		'setStack': setStack,
		'words': getUserWords,
		'removeCustomWord': removeCustomWord,
		'native_words': nativeWords.words,
		'categories': nativeWords.categories,
		'environment': function() { return environment; },
		'toString': toString,
		'setParser': function(newParser) { parser = newParser; },  //FIXME: ugly way to set interpreter; there's circular dependency
		'setSelf': setSelf // FIXME: crude hack
	};
	
};

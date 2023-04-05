var JSFACTOR_PARSER = JSFACTOR_PARSER || function() {
	var generic = JSFACTOR_GENERIC;
	
	 // FIXME: interpreter should be properly modularized, currently
	 // 1) init order of js files is important in index.html and two instances of interpreter are made (should use pushEnvironment)
	var helperInterpreter = initializeInterpreter(
		{
			'append': function(value) { alert(value); },
			'clear': function(value) {}
		});
	
	// for more, see: http://docs.factorcode.org/content/vocab-syntax.html	
	var parse_words = {
		'{': parse_array,
		':': parse_define_word,
		'[': parse_quote,
		'f': parse_f,
		't': parse_t,
		'H{': parse_assoc,
		'SYNTAX:': parse_syntax,
		'SYMBOL:': parse_symbol, //FIXME: incomplete definition
		'[|': parse_quote_with_named_params
	}
	
	var environments = [];
	
	var lexical_variables = {};

	function copyLexicalVariables() {
		return generic.shallowCopyObject(lexical_variables);
	}
	
	function setLexicalVariables(newArray) {
		lexical_variables = newArray;
	}
	
	function setLexicalVariable(variableName, value) {
		lexical_variables[variableName] = value;
	}
	
	function getLexicalVariable(variableName) {
		return lexical_variables[variableName];
	}
	
	function getEnvironment() { 
		return environments[environments.length -1]; 
	} // assume there's one
	
	return {
	  'parse': parse,
		'pushEnvironment': function(environment) { environments.push(environment); },
		'popEnvironment': function(environment) { return environments.pop(); }
	}
	
	function out(value) {
		getEnvironment().getOutput().append(value.length + " :: " + getEnvironment().toString(value));		
	}
	
	function parse(input) {
		function parseInner(rest, acc) {
			
			if(rest === "") {
				 return acc;
			}

			if(rest[0] === '\"') {
				var result = parse_string(rest, 0)
				return parseInner(result.rest, acc.concat([result.string]));
			} else if(rest[0] === ' ') {
				return parseInner(rest.slice(1), acc); // ignore whitespace
			} else {
				var nextToken = getNextToken(rest);
				var next = nextToken.next;
				var word = parse_words[next];
				
				if(next !== "" && word !== undefined) {
					var result = word(nextToken.rest, acc /*already parsed*/) //old? not needed, next.length);
					var newAcc;
					// parsing word can modify already parsed values, check whether that has been done, if so, acc is not needed 
					if(result.parsed_modified !== undefined) {
						newAcc = result.value !== undefined ? result.parsed_modified.concat(result.value) : result.parsed_modified;
					} else {
					  newAcc = result.value !== undefined ? acc.concat(result.value) : acc;
					}
					
					return parseInner(result.rest, newAcc);
				} else {
					var lexical = getLexicalVariable(next);
					if(lexical !== undefined) {
						// adds lexical value getter to parse tree
						var lexicalGetObject = {
							'type': 'lexical_get', 
							'value': lexical.get
						}
						
						return parseInner(nextToken.rest, acc.concat([lexicalGetObject]));
					} else {
						return parseInner(nextToken.rest, acc.concat([next]));
					}
				}
			}
		}
		
		return parseInner(input, []);
	}

	function getNextToken(string) {
		var splitted = string.split(" ");
		
		var next = splitted[0];
		var trimmed = $.trim(next); 
		if(trimmed === '' && splitted.length > 1) return getNextToken(string.slice(next.length+1));
		var rest = splitted.length <= 1 ? "" : string.slice(next.length+1);

		return {
			'next': next,
			'rest': rest
		}
		
	}


	function parse_quote(strings) {
		return parse_grouped(strings, "[", "]", getEnvironment().createQuote);
	}

	function t() { 
		return getEnvironment().t; 
	}

	function f() { 
		return getEnvironment().f; 
	}
	
	function parse_f(strings) {
		return {
			'value': f(),
			'rest': strings // strings doesn't contain f
		}
	}

	function parse_t(strings) {
		return {
			'value': t(),
			'rest': strings // strings doesn't contain t
		}
	}
	
	function parse_array(strings) {
		return parse_grouped(strings, "{", "}", getEnvironment().createArray);
	}

	function stringToString(string) { 
		return '\"' + string.join(" ") + '\"' 
	}
	
	function parse_string(strings, start_index) {
		var startToken = "\"", endToken = "\"";
		
		for(var i = start_index + 1; i < strings.length; ++i) {
			var current = strings[i];

			if(current == endToken) {
				var object = strings.slice(start_index + 1, i);
				var string = getEnvironment().createString(object);
				var after = strings.slice(i + 1);

				return {
					'string': string,
					'rest': after
				}
			} else if(current == startToken && startToken !== endToken) {
				throw "error parsing: another " + startToken + " before " + endToken;
			}
		}
		
		throw "error parsing: " + endToken + " expected.";		
	}

	function tokenAddsGroupingDepth(token, startToken) {
		//FIXME: should be generalized as endToken(token) === endToken(startToken)
		if(token === '{' && startToken === 'H{') return true;
		if(token === 'H{' && startToken === '{') return true;
	  else return token === startToken
	}
	
	// startToken has been already taken from 'strings' 
	function parse_grouped(strings, startToken, endToken, createObject) {
		var inner = ""; // stuff inside group tokens, e.g. { 1 2 3 } => inner = 1 2 3
		var groupDepth = 0; // for matching correct start and end tokens (in same level), e.g. { { } }  <- outermost tokens are selected 
		
		function addToInner(value) {
	  	if(inner === "") inner += value;
	  	else inner += " " + value;
		}

		// token by token find the matching endToken and recursively call parse to parse inner body
		// e.g. { 5 { 3 5 } } 		
		while(true) {
		  var next = getNextToken(!!next ? next.rest : strings);

		  if(tokenAddsGroupingDepth(next.next, startToken)) {
	  		addToInner(next.next);
		  	++groupDepth;
		  } else if(next.next === endToken) {
		  	if(groupDepth > 0) { // too deep yet; not matching endToken
		  		addToInner(next.next);
		  		--groupDepth;
		  	} else { // matching endToken found
					var innerParsed = parse(inner);
					var value = createObject(innerParsed);		  	
					return {
						'value': value,
						'rest': next.rest
					}
				}
		  } else if(next.rest.length === 0) {
		  	throw "error parsing: no matching " + endToken + " found."; 
		  } else {
		  	addToInner(next.next);
		  }
		}
				
	}

	// missing stack effect declaration is ok for now
	function parse_define_word(strings) {
		var startToken = ":";
		var endToken = ";";
		
		var inner = ""; // stuff inside group tokens, e.g. { 1 2 3 } => inner = 1 2 3
		var innerLength = 0;
		
		function addToInner(value) {
	  	if(inner === "") inner += value;
	  	else inner += " " + value;
	  	++innerLength;
		}

		while(true) {
			var next = getNextToken(!!next ? next.rest : strings);
			var current = next.next;
			
			if(current === endToken) {
				if(innerLength === 0) throw "Word is missing name from its definition.";
				if(innerLength === 1) throw "Word is missing body from its definition.";

				var restToBeParsed = next.rest; // for function return
				
				next = getNextToken(inner);
				var wordName = next.next;
				var wordBody = parse(next.rest);				
				
				if(getEnvironment().isNum(wordName)) throw "Word name cannot be a number"; //FIXME check not num, t, f, string...

				getEnvironment().addWord(wordName, wordBody);
				getEnvironment().getOutput().append("Added word: " + wordName + " " + getEnvironment().toString(wordBody));
				
				return {
					'value': undefined, // nothing is added to parse tree
					'rest': restToBeParsed 
				}
			} else if(current === startToken) {
				throw "error parsing: another '" + startToken + "' before '" + endToken + "'";
		  } else if(next.rest.length === 0) {
		  	throw "error parsing: no matching " + endToken + " found."; 
			} else {
				addToInner(current);
			}
		}
		
		throw "error parsing: ';' expected.";
	}
	
	
	function parse_assoc(strings) {
		var result = parse_grouped(strings, "H{", "}", getEnvironment().createAssoc);
		
		return {
			'value': result.value,
			'rest': result.rest
		}
	}

		
	function isProperName(value) {
		return generic.for_all(value, function(elem) { return elem >= 'a' && elem <= 'Z'; });
	}

	/*
	  creates parse word that can modify already parsed values
	  currently doesn't support reading forward
	*/
	function createParseWord(value) {
		generic.okUnless("parse word name not given", value[0] === undefined);
		generic.okUnless("parse definition body not given", value[1] === undefined);

		var name = value[0];
		if(parse_words[name] !== undefined) throw "parse word '" + name + "' already defined.";
		var definition = getEnvironment().createQuote(value.slice(1));
		
		parse_words[name] = function(strings, already_parsed) {
			/*
			  parse word that executes definition on new interpreter
			  stack is set to contain already parsed values for modification
			  then the definition is called and the resulting stack is the new parsed array which we give back as returning value for main 'parse'
			*/
			
			helperInterpreter.setParser(JSFACTOR_PARSER);
			helperInterpreter.setStack([]);
			generic.for_each(already_parsed, function(elem) { helperInterpreter.stack().push(elem); });			
			helperInterpreter.stack().push(definition);
			helperInterpreter.execute("call");

			var parsed = helperInterpreter.stack();
			
			return {
				'value': undefined,
				'rest': strings, // doesn't consume any new, if needed, could used as SYMBOL or on top of the stack (harder)
				'parsed_modified':  parsed
			}
		}
		
	}
	
	function parse_syntax(strings) {
		//FIXME change so that no SYNTAX: definition inside SYNTAX: is possible; neither other parsing words
		var result = parse_grouped(strings, "SYNTAX:", ";", createParseWord);
		
		return {
			'value': undefined,
			'rest': result.rest
		}
	}
	
	function parse_symbol(strings) {
		var next = getNextToken(strings);
		
		var name = next.next;
		
		getEnvironment().addSymbol(name);
		
		return {
			'value': undefined, // don't put any values to parsed
			'rest': next.rest
		}
	}
	
	//FIXME: COPIED, should refactor
	function isValidSymbolName(value) {
	   return  generic.for_all(value, function(elem) { return (elem >= 'a' && elem <= 'z') || (elem >= 'A' && elem <= 'Z'); });
	}
	
	function parse_quote_named_def(strings, startToken, endToken) {
		var variables = [];
		
		while(true) {
			var token = getNextToken(!!token ? token.rest : strings);

			if(token.next === endToken) { // && correctDepth
				generic.okUnless("no named variables given for quotation", variables.length === 0);
				return {
					'variables': variables,
					'rest': token.rest 				
				}
			} else if($.trim(token.next) === '') {
				throw "invalid definition for quotation: variable name expected instead of empty token";
			} else {
				generic.okUnless("not valid name for variable", !isValidSymbolName(token.next));
				variables.push(token.next);
			}
		}
	}

	// O(n^2) but only couple of variables are generally defined
	function checkAllVariablesAreDifferent(variables) {
		generic.for_each_indexed(variables, function(elem1, i) {
				generic.for_each_indexed(variables, function(elem2, j) {
						if(i !== j && elem1 === elem2) throw "Parameter name " + elem1 + " is defined at least twice.";
				});
		});
	}

	function parse_quote_with_named_params(strings) {

		// this is needed because of nested quoations with same variable name but different binding
		var copyOfLexicalVariables = copyLexicalVariables(); 
		
		// check that more than 0 variables and that they are valid names
		var result = parse_quote_named_def(strings, "[|", "|");

		checkAllVariablesAreDifferent(result.variables);
		
		var quoteArray = []; // the result value
		
		generic.for_each(generic.reverse(result.variables), // reverse so that values are bind in correct order
			function(elem) {
				var value = undefined; // can different entities reference same value, and thus

				var lexicalObject = {
					'value': value,
					'set': {
						'fun': function(retrievalValue) { value = retrievalValue; },
						'variableName': elem
					},
					'get': {
						'fun': function() { return value; },
						'variableName': elem
					}
				}
				
				setLexicalVariable(elem, lexicalObject);
				quoteArray.push({
						'type': 'lexical_set',
						'value': lexicalObject.set
				}); // the variable setters must be put to the front of quote
			}); 
		
		//var definition = parse_quote_named_def(result.rest, "|", "]"); // FIXME: fix parse so that quotations inside quotations are not making trouble
		
		function createQuoteNamedDefinition(value) { return value; }

		var definition = parse_grouped(result.rest, "|", "]", createQuoteNamedDefinition);
		setLexicalVariables(copyOfLexicalVariables);
		
		generic.for_each(definition.value, function(elem) { quoteArray.push(elem); });
		
		var resultQuote = getEnvironment().createQuote(quoteArray);
		resultQuote.lexicalVariables = result.variables; // mostly for redundant meta-information
		
		return {
			'value': resultQuote, // quote that will first read the values and bind them to variables
			'rest': definition.rest
		}
	}
	
}();

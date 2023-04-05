var JSFACTOR_TESTS = JSFACTOR_TESTS || function() {
	var generic = JSFACTOR_GENERIC;
	
  var interpreter = initializeInterpreter(
    {
    	'append': function(value) { console.log(value); },
    	'clear': function() {},
    	'refresh': function() {}
    });

  var tests = [];

  function test(name, stackBefore, testInput, stackAfter,
  							beforeFun, afterFun /* optional manual checking funs */) {
  	tests.push({
  		'name': name,
  		'stack_before': stackBefore,
  		'test_input': testInput,
  		'stack_after': stackAfter,
  		'beforeFun': beforeFun,
  		'afterFun': afterFun
  	});
  }
  
  function env() { return interpreter.environment(); }
  
  var f = env().f;
  var t = env().t;

/*************************************/
/* START OF TESTS */
/*************************************/

  
/* shuffle words */

	test("swap two elements", 						[1, 2], "swap", [2, 1]);
  test("drop element", 									[1, 2], "drop", [1]);
  test("duplicate elements", 						[3], "dup", [3, 3]);
  test("removed 2nd topmost element", 	[5, 3], "nip", [3]);
  test("copy 2nd topmost element", 			[3, 4], "over", [3, 4, 3]);

/* combinator words (basic) */

	test("if with true cond", [], 				"t [ 10 ] [ 0 ] if", ["10"]);
	test("if with false cond", [], 				"f [ 10 ] [ 0 ] if", ["0"]); // FIXME: numbers should be wrapped
	test("if* with true cond", [],			 	"t [ ] [ 0 ] if*", [t]);
	test("if* with false cond", [], 			"f [ ] [ 0 ] if*", ["0"]);
	
	test("when with true cond", [], 			"t [ 3 ] when", ["3"]);
	test("when with false cond", [], 			"f [ 3 ] when", []);
	test("when* with true cond", [], 			"t [ ] when*", [t]);
	test("when* with false cond", [], 		"f [ ] when*", []);
	
	test("while", [], 										"3 [ dup 10 < ] [ 1 + ] while", [10]);
	test("while no body evaluation", [], 	"f [ ] [ t t ] while", []);
	test("until", [], 										"0 [ dup 10 > ] [ 1 + ] until", [11]);
	test("until no body evalution", [], 	"t [ ] [ 1 2 3 ] until", []);
	
/* combinator words advanced */

	test("curry", [], 										"1 [ 2 + ] curry call", [3]);
	test("map", [], 											"{ 1 2 3 } [ 2 * ] map", [seq([2, 4, 6])]);
	test("each", [], 											"{ 1 2 3 } [ 1 + ] each", [2, 3, 4]);
	
	test("keep", [], 											"1 [ 2 + ] keep", [3, "1"]); // FIXME: we have a problem with number representation; should be wrapped
	test("dip", [], 											"5 1 [ 2 + ] dip", [7, "1"]);
	test("filter", [], 										"{ 1 2 3 4 } [ 2 > ] filter", [seq([3, 4])]);

	test("compose", [], 									"[ 1 ] [ 2 ] compose [ + ] compose call", [3]);
	
/* math words */
  /* generalized boolean */
	test("or gives value not f", [], 			"f 1 or", ["1"]);
	test("or gives 2nd topmost value if both not f", [],
																				"3 5 or", ["3"]);
	test("or two f's yields f", [], 			"f f or", [f]);
	test("and f and f yields f", [], 			"f f and", [f]);
	test("and f and t yields f", [], 			"f t and", [f]);
	test("and gives topmost value if true", [], 
																				"5 3 and", ["3"]);
  test("not of f gives t", [], 					"f not", [t]);
  test("not of value other than f yields f", [], 
  																			"35 not", [f]);
  test("5 is greater than 3", 					[5, 3], ">", [t]);
  test("3 is not greater than 5", 			[3, 5], ">", [f]);
  test("3 is smaller than 3", 					[3, 5], "<", [t]);
  test("5 is not smaller than 3", 			[5, 3], "<", [f]);

  /* arithmetic operations */  
  test("sum elements", 									[4, 2], "+", [6]);
  test("substract elements", 						[4, 2], "-", [2]);
  test("substract elements", 						[2, 4], "-", [-2]);

  test("multiply elements", 						[5, 6], "*", [30]);
  test("divide elements", 							[10, 2], "/", [5]);
  test("10 mod 4 yields 2", 						[10, 4], "mod", [2]); 
  
  /* equality */
  test("4 equals 4", [], 								"4 4 =", [t]);
  test("4 equals not 5", [], 						"4 5 =", [f]);

  test('string "abc" equals "abc"', 		[str("abc"), str("abc")], "=", [t]);
  
  test('string "abc" does not equal "bbc"', 
  																			[str("abc"), str("bbc")], "=", [f]);
  
  test('string "123" does not equal number 123', 
  																			[str("abc")], "123 =", [f]);
  
  test("t equals t", [], 								"t t =", [t]);
  test("t does not equal f", [], 				"t f =", [f]);
  test("f equals f", [], 								"f f =", [t]);

  test('{ "1" "2" } equals { "1" "2" }', 
																				[
																				 seq([str("1"), str("2")]), 
																				 seq([str("1"), str("2")])
																				], "=", [t]);
  
  test('{ "1" } does not equal { "2" }', 
																				[
																					seq([str("1")]), 
																					seq([str("2")])
																				], "=", [f]);

	test("symbol foo equals symbol foo", [],
																				"SYMBOL: foo foo dup =", [t]);
	
	test("symbol foo does not equal symbol bar", [], 
																				"SYMBOL: foo SYMBOL: bar foo bar =", [f]);

/* sequence */

	test("at* gives value by key and t to indicate success", [], 
																				"1 H{ { 1 42 } } at*", ["42", t]);
	
	test("at* gives f if key not found and another f to indicate failure", [], 
																				"2 H{ { 1 42 } } at*", [f, f]);
	
	test("assoc-size gives elements in assoc", [], 
																				"H{ { 1 1 } { 2 2 } { 3 3 } } assoc-size", [3]);
	test("assoc-size is 0 for empty assoc", [], 
																				"H{ } assoc-size", [0]);
	
	test("alist gives assoc as array (association list)", [],
																				"H{ { 1 2 } { 2 3 } } >alist { { 1 2 } { 2 3 } } =", [t]);
	
	test("<array> creates array so that elements are initialized", [], 
																				"3 9 <array>", [ seq([9, 9, 9 ]) ]);
	test("elt adds element at the end of a sequence", [], 
																				"{ 1 2 } 3 ,", [seq([1, 2, 3])]);
	
	test("reduce combines elements with quote, example: add values up", [], 
																				"{ 1 2 3 } 0 [ + ] reduce", [6]);

/* misc */
	
	test("call quote", [], 								"[ 1 2 + ] call", [3]);
	
	test("whitespaces shouldn't matter in parsing", [], 
																				"  1  2  [ 3 +  ]  curry  call    *  ", [5]);

/* combinator words cleave, spread, apply  */

	test("cleave", [], 										"5 { [ 1 + ] [ 2 * ] [ 5 - ] } cleave", [6, 10, 0]);
	test("bi", [], 												"10 [ 2 * ] [ 5 - ] bi", [20, 5]);
	test("2bi", [],												"2 3 [ * ] [ - ] 2bi", [6, -1]);
	test("tri", [], 											"5 [ 10 * ] [ 10 + ] [ 10 - ] tri", [50, 15, -5]);
	test("bi@", [],												"2 3 [ 10 * ] bi@", [20, 30]);
	test("bi*", [],												"2 3 [ 2 * ] [ 3 * ] bi*", [4, 9]);
	

/* semantics */

/* locals */
 /* quotations with named parameters */

 
 test("named parameters order", 				[1, 2], "[| a b | a b ] call", [1, 2]);
 test("named parameters order #2", 			[1, 2], "[| a b | b a ] call", [2, 1]);

 
 
 test("quotation with inner quotation", [1, 2, 3], "[| a b | [| c | c ] call a + b * ] call", [9]);
 test("quotation with many occurrences of same variable name inside one quotation",
 	 																			[1], "[| a | a a + a + ] call", [3]); 
 

 test("quotation inside quotation with named variable but binds to different value", [], 
 	 																			"1 2 [| a | a [| a | a ] call + ] call", [3]);
 
 test("quotation inside quotation with named variable but binds to different value", [], 
 	 																			"1 2 [| a | [| a | a ] call a + ] call", [3]);
 
 

 test("set and get value for symbol", 	[5], "SYMBOL: foo foo set foo get", [5]);
 
// test("dup creates a new copy, instead of shallow references", [], "{ 5 } dup 3 ,", [seq([5]), seq([5, 3])]);

/* misc */

	
/*************************************/
/* END OF TESTS */
/*************************************/


	function currentTime() { return new Date().getTime(); }

	function quot(quot) {
		return env().createQuote(quot);
	}

	function seq(array) {
		return env().createArray(array);
	}
	
	function str(string) {
		return env().createString(string);
	}
	
  function clearEnvironment() {
  	interpreter.setStack([]);
  	// should also clear environment totally, e.g. symbols, custom words, etc
  }

  function run_tests() {
		console.log("TESTS TO RUN: " + tests.length);
		tests = generic.reverse(tests); // just for development phase (test are added at the end and it would be nice to see them at top)
		try{
  	  generic.for_each_indexed(tests, run_test);
  	} catch(e) {
  		console.log(e);
  		console.log("stack was:");
  		console.log(interpreter.stack());
  		console.log("TEST FAILED");
  		alert("TEST FAILED");
  		return;
  	}  		
  	
  	console.log("ALL " + tests.length +  " TESTS SUCCEEDED");
  }
  
  function run_test(test, num) {
  	console.log("TEST " + (1 + num) + ": " + test.name );
  	console.log("\t" + interpreter.toString(test.stack_before));
  	console.log("\t" + test.test_input);

  	clearEnvironment();
  	generic.for_each(test.stack_before, function(elem) { interpreter.stack().push(elem); });
  	
  	var testData = {}; // object for passing information between beforeFun and afterFun
  	if(!!test.beforeFun) test.beforeFun(testData);
  	interpreter.execute(test.test_input);
  	console.log("\t" + interpreter.toString(test.stack_after) + " == " + interpreter.toString(interpreter.stack()));
  	if(!!test.afterFun) test.afterFun(testData);
  	assertStack(test.stack_after);
  	console.log("ok");
  }
  
  function assertStack(stack_after) {
  	generic.okUnless("stack's are not balanced", stack_after.length !== interpreter.stack().length);
    
  	for(var i = stack_after.length - 1; i >= 0; --i) {
    	generic.assert("", interpreter.toString(stack_after[i]), interpreter.toString(interpreter.stack()[i]));
    }
  }  

  return {
  	'run_tests': run_tests
  }
}();


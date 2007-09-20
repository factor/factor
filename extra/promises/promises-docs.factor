! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax promises ;

HELP: promise 
{ $values { "quot" "a quotation with stack effect ( -- X )" } { "promise" "a promise object" } }
{ $description "Creates a promise to return a value. When forced this quotation is called and the value returned. The value is memorised so that calling " { $link force } " again does not call the quotation again, instead the previous value is returned directly." } 
{ $see-also force promise-with promise-with2 } ;

HELP: promise-with
{ $values { "value" "an object" } { "quot" "a quotation with stack effect ( value -- X )" } { "promise" "a promise object" } }
{ $description "Creates a promise to return a value. When forced this quotation is called with the given value on the stack and the result returned. The value is memorised so that calling " { $link force } " again does not call the quotation again, instead the previous value is returned directly." } 
{ $see-also force promise promise-with2 } ;

HELP: promise-with2
{ $values { "value1" "an object" } { "value2" "an object" } { "quot" "a quotation with stack effect ( value1 value2 -- X )" } { "promise" "a promise object" } }
{ $description "Creates a promise to return a value. When forced this quotation is called with the given values on the stack and the result returned. The value is memorised so that calling " { $link force } " again does not call the quotation again, instead the previous value is returned directly." } 
{ $see-also force promise promise-with2 } ;

HELP: force
{ $values { "promise" "a promise object" } { "value" "a factor object" } }
{ $description "Calls the quotation associated with the promise if it has not been called before, and returns the value. If the promise has been forced previously, returns the value from the previous call." } 
{ $see-also promise promise-with promise-with2 } ;

HELP: LAZY:
{ $syntax "LAZY: word definition... ;" } 
{ $values { "word" "a new word to define" } { "definition" "a word definition" } }
{ $description "Creates a lazy word in the current vocabulary. When executed the word will return a " { $link promise } " that when forced, executes the word definition. Any values on the stack that are required by the word definition are captured along with the promise." } 
{ $examples
  { $example "LAZY: my-add ( a b -- c ) + ;\n1 2 my-add force ." "3" }
}
{ $see-also force promise-with promise-with2 } ;

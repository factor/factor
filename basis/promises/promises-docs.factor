! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: promises

HELP: <promise>
{ $values { "quot" { $quotation ( -- x ) } } { "promise" "a promise object" } }
{ $description "Creates a promise to return a value. When forced this quotation is called and the value returned. The value is memorized so that calling " { $link force } " again does not call the quotation again, instead the previous value is returned directly." } ;

HELP: force
{ $values { "promise" "a promise object" } { "value" "a factor object" } }
{ $description "Calls the quotation associated with the promise if it has not been called before, and returns the value. If the promise has been forced previously, returns the value from the previous call." } ;

HELP: LAZY:
{ $syntax "LAZY: word ( stack -- effect ) definition... ;" }
{ $values { "word" "a new word to define" } { "definition" "a word definition" } }
{ $description "Creates a lazy word in the current vocabulary. When executed the word will return a " { $link promise } " that when forced, executes the word definition. Any values on the stack that are required by the word definition are captured along with the promise." }
{ $examples
  { $example "USING: arrays sequences prettyprint promises ;" "IN: scratchpad" "LAZY: zeroes ( -- pair ) 0 zeroes 2array ;" "zeroes force second force first ." "0" }
} ;

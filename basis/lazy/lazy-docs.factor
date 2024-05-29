! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: lazy

HELP: <lazy>
{ $values { "quot" { $quotation ( -- x ) } } { "lazy" lazy } }
{ $description "Creates a lazy to return a value. When forced this quotation is called and the value returned. The value is memoized so that calling " { $link force } " again does not call the quotation again, instead the previous value is returned directly." } ;

HELP: force
{ $values { "lazy" lazy } { "value" object } }
{ $description "Calls the quotation associated with the lazy if it has not been called before, and returns the value. If the lazy has been forced previously, returns the value from the previous call." } ;

HELP: LAZY:
{ $syntax "LAZY: word ( stack -- effect ) definition... ;" }
{ $values { "word" "a new word to define" } { "definition" "a word definition" } }
{ $description "Creates a lazy word in the current vocabulary. When executed the word will return a " { $link lazy } " that when forced, executes the word definition. Any values on the stack that are required by the word definition are captured along with the lazy." }
{ $examples
  { $example "USING: arrays lazy sequences prettyprint ;" "IN: scratchpad" "LAZY: zeroes ( -- pair ) 0 zeroes 2array ;" "zeroes force second force first ." "0" }
} ;

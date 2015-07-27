USING: help.markup help.syntax math sequences words ;
IN: math.partial-dispatch

HELP: define-integer-ops
{ $values { "word" word } { "fix-word" word } { "big-word" word } }
{ $description "Defines an integral arithmetic operation. 'word' is the generic word, 'fix-word' the word to dispatch on if the last argument is a " { $link fixnum } " and 'big-word' thew ord if it is a " { $link bignum } "." } ;

HELP: derived-ops
{ $values { "word" word } { "words" sequence } }
{ $description "Lists all derived words of the given word, including the word itself." } ;

ARTICLE: "math.partial-dispatch"
"Partially-dispatched math operations, used by the compiler"
"Partially-dispatched math operations" ;

ABOUT: "math.partial-dispatch"

USING: combinators help.markup help.syntax kernel kernel.private sequences
words ;
IN: stack-checker.known-words

HELP: check-declaration
{ $values { "declaration" sequence } }
{ $description "Checks that a declaration sequence as inputted to a " { $link declare } " word is well-formed." } ;

HELP: define-primitive
{ $values { "word" word } { "inputs" sequence } { "outputs" sequence } }
{ $description "Marks the word as a primitive whose input and output types must be the given ones." } ;

HELP: infer-call
{ $description "Performs inferencing for the " { $link call } " word." } ;

HELP: infer-call-effect
{ $description "Performs inferencing for the " { $link call-effect } " word." } ;

HELP: infer-local-reader
{ $values { "word" word } }
{ $description "This is a hack for combinators " { $vocab-link "combinators.short-circuit.smart" } "." } ;

HELP: infer-ndip
{ $values { "word" word } { "n" "the dip depth" } }
{ $description "Performs inferencing for one of the dip words." } ;

HELP: infer-special
{ $values { "word" word } }
{ $description "Performs inferencing of a word with the \"special\" property set." } ;


ARTICLE: "stack-checker.known-words" "Hard-coded stack effects for primitive words"
"This vocab declares primitive and shuffle words." ;

ABOUT: "stack-checker.known-words"

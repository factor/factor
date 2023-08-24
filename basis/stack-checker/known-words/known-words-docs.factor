USING: combinators help.markup help.syntax kernel kernel.private sequences
words ;
IN: stack-checker.known-words

HELP: check-declaration
{ $values { "declaration" sequence } }
{ $description "Checks that a declaration sequence as input to a " { $link declare } " word is well-formed." } ;

HELP: infer-call
{ $description "Performs inferencing for the " { $link call } " word." } ;

HELP: infer-call-effect
{ $values { "word" word } }
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


ARTICLE: "stack-checker.known-words" "Extra properties for special words"
"This vocab adds properties for words that are handled specially by the compiler. Such as " { $link curry } " and " { $link dip } "." ;

ABOUT: "stack-checker.known-words"

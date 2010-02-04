IN: stack-checker.transforms
USING: help.markup help.syntax combinators words kernel ;

HELP: define-transform
{ $values { "word" word } { "quot" "a quotation taking " { $snippet "n" } " inputs from the stack and producing another quotation as output" } { "n" "a non-negative integer" } }
{ $description "Defines a compiler transform for the optimizing compiler. When a call to " { $snippet "word" } " is being compiled, the compiler first checks that the top " { $snippet "n" } " stack values are literal, and if so, calls the quotation with those inputs at compile time. The quotation can output a new quotation, or " { $link f } "."
$nl
"If the quotation outputs " { $link f } ", or if not all inputs are literal, a call to the word is compiled as usual, or compilation fails if the word does not have a static stack effect."
$nl
"Otherwise, if the transform output a new quotation, the quotation replaces the word's call site." }
{ $examples "The " { $link cond } " word compiles to efficient code because it is transformed using " { $link cond>quot } ":"
{ $code "\\ cond [ cond>quot ] 1 define-transform" } } ;

USING: help.markup help.syntax inference.transforms
combinators words ;

HELP: define-transform
{ $values { "word" word } { "quot" "a quotation taking " { $snippet "n" } " inputs from the stack and producing another quotation as output" } { "n" "a non-negative integer" } }
{ $description "Defines a compiler transform for the optimizing compiler. When a call to " { $snippet "word" } " is being compiled, the compiler ensures that the top " { $snippet "n" } " stack values are literal; if they are not, compilation fails. The literal values are passed to the quotation, which is expected to produce a new quotation. The call to the word is then replaced by this quotation." }
{ $examples "Here is a word which pops " { $snippet "n" } " values from the stack:"
{ $code ": ndrop ( n -- ) [ drop ] times ;" }
"This word is inefficient; it does not have a static stack effect. This means that words calling " { $snippet "ndrop" } " cannot be compiled by the optimizing compiler, and additionally, a call to this word will always involve a loop with arithmetic, even if the value of " { $snippet "n" } " is known at compile time. A compiler transform can fix this:"
{ $code "\\ ndrop [ \\ drop <repetition> >quotation ] 1 define-transform" }
"Now, a call like " { $snippet "4 ndrop" } " is replaced with " { $snippet "drop drop drop drop" } " at compile time; the optimizer then ensures that this compiles as a single machine instruction, which is a lot cheaper than an actual call to " { $snippet "ndrop" } "."
$nl
"The " { $link cond } " word compiles to efficient code because it is transformed using " { $link cond>quot } ":"
{ $code "\\ cond [ cond>quot ] 1 define-transform" } } ;

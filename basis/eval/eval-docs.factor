IN: eval
USING: help.markup help.syntax strings io effects ;

HELP: eval
{ $values { "str" string } { "effect" effect } }
{ $description "Parses Factor source code from a string, and calls the resulting quotation, which must have the given stack effect." }
{ $errors "Throws an error if the input is malformed, or if the evaluation itself throws an error." } ;

HELP: eval(
{ $syntax "eval( inputs -- outputs )" }
{ $description "Parses Factor source code from the string at the top of the stack, and calls the resulting quotation, which must have the given stack effect." }
{ $errors "Throws an error if the input is malformed, or if the evaluation itself throws an error." } ;

HELP: eval>string
{ $values { "str" string } { "output" string } }
{ $description "Evaluates the Factor code in " { $snippet "str" } " with " { $link output-stream } " rebound to a string output stream, then outputs the resulting string. The code in the string must not take or leave any values on the stack." } ;

ARTICLE: "eval" "Evaluating strings at runtime"
"The " { $vocab-link "eval" } " vocabulary implements support for evaluating strings at runtime."
{ $subsection POSTPONE: eval( }
{ $subsection eval>string } ;

ABOUT: "eval"

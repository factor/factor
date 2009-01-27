IN: eval
USING: help.markup help.syntax strings io ;

HELP: eval
{ $values { "str" string } }
{ $description "Parses Factor source code from a string, and calls the resulting quotation." }
{ $errors "Throws an error if the input is malformed, or if the evaluation itself throws an error." } ;

HELP: eval>string
{ $values { "str" string } { "output" string } }
{ $description "Evaluates the Factor code in " { $snippet "str" } " with " { $link output-stream } " rebound to a string output stream, then outputs the resulting string." } ;

ARTICLE: "eval" "Evaluating strings at runtime"
"The " { $vocab-link "eval" } " vocabulary implements support for evaluating strings at runtime."
{ $subsection eval }
{ $subsection eval>string } ;

ABOUT: "eval"

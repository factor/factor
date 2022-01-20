USING: help.markup help.syntax strings ;
IN: strings.parser

HELP: bad-escape
{ $error-description "Indicates the parser encountered an invalid escape code following a backslash (" { $snippet "\\" } ") in a string literal. See " { $link "escape" } " for a list of valid escape codes." } ;

HELP: escape
{ $values { "escape" "a single-character escape" } { "ch" "a character" } }
{ $description "Converts from a single-character escape code and the corresponding character." }
{ $examples { $example "USING: kernel prettyprint strings.parser ;" "CHAR: n escape CHAR: \\n = ." "t" } } ;

HELP: parse-string
{ $values { "str" "a new " { $link string } } }
{ $description "Parses one or more lines until a quote (\"), interpreting escape codes along the way." }
{ $errors "Throws an error if the string contains an invalid escape sequence." }
$parsing-note ;

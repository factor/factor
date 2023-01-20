! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: parser-combinators

HELP: list-of
{ $values
  { "items" "a parser object" } { "separator" "a parser object" } { "parser" "a parser object" } }
{ $description
    "Return a parser for parsing the repetition of things that are "
    "separated by a certain symbol. For example, comma separated lists. "
    "'items' is a parser that can parse the individual elements. 'separator' "
    "is a parser for the symbol that separatest them. The result tree of "
    "the resulting parser is an array of the parsed elements." }
{ $example "USING: parser-combinators parser-combinators.simple prettyprint ;" "\"1,2,3,4\" integer-parser \",\" token list-of parse-1 ." "{ 1 2 3 4 }" }
{ $see-also list-of } ;

HELP: any-char-parser
{ $values
  { "parser" "a parser object" } }
{ $description
    "Return a parser that consumes a single value "
    "from the input string. The value consumed is the "
    "result of the parse." }
{ $examples
{ $example "USING: lists.lazy parser-combinators prettyprint ;" "\"foo\" any-char-parser parse-1 ." "102" } } ;

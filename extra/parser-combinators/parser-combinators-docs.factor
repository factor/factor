! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax parser-combinators ;

HELP: list-of
{ $values 
  { "items" "a parser object" } { "separator" "a parser object" } { "parser" "a parser object" } }
{ $description 
    "Return a parser for parsing the repetition of things that are "
    "separated by a certain symbol. For example, comma separated lists. "
    "'items' is a parser that can parse the individual elements. 'separator' "
    "is a parser for the symbol that separatest them. The result tree of " 
    "the resulting parser is an array of the parsed elements." }
{ $example "USE: parser-combinators" "\"1,2,3,4\" 'integer' \",\" token list-of parse car parse-result-parsed ." "{ 1 2 3 4 }" }
{ $see-also list-of } ;


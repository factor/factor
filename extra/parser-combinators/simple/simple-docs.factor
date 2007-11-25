! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup parser-combinators
parser-combinators.simple ;

HELP: 'digit'
{ $values 
  { "parser" "a parser object" } }
{ $description 
    "Return a parser that consumes a single digit from "
    "the input string. The numeric value of the digit "
    " consumed is the result of the parse." }
{ $examples
{ $example "USING: lazy-lists parser-combinators ;" "\"123\" 'digit' parse-1 ." "1" } } ;

HELP: 'integer'
{ $values 
  { "parser" "a parser object" } }
{ $description 
    "Return a parser that consumes an integer from "
    "the input string. The numeric value of the integer "
    " consumed is the result of the parse." }
{ $examples
{ $example "USING: lazy-lists parser-combinators ;" "\"123\" 'integer' parse-1 ." "123" } } ;
HELP: 'string'
{ $values 
  { "parser" "a parser object" } }
{ $description 
    "Return a parser that consumes a string enclosed in "
    "quotations from the input string. The string value "
    " consumed is the result of the parse." }
{ $examples
{ $example "USING: lazy-lists parser-combinators ;" "\"\\\"foo\\\"\" 'string' parse-1 ." "\"foo\"" } } ;
HELP: 'bold'
{ $values 
  { "parser" "a parser object" } }
{ $description 
    "Return a parser that consumes a string enclosed in "
    "the '*' character from the input string. This is "
    "commonly used in markup languages to indicate bold "
    "faced text." }
{ $example "USE: parser-combinators" "\"*foo*\" 'bold' parse-1 ." "\"foo\"" }
{ $example "USE: parser-combinators" "\"*foo*\" 'bold' [ \"<strong>\" swap \"</strong>\" 3append ] <@ parse-1 ." "\"<strong>foo</strong>\"" } ;
HELP: 'italic'
{ $values 
  { "parser" "a parser object" } }
{ $description 
    "Return a parser that consumes a string enclosed in "
    "the '_' character from the input string. This is "
    "commonly used in markup languages to indicate italic "
    "faced text." }
{ $examples
{ $example "USING: lazy-lists parser-combinators ;" "\"_foo_\" 'italic' parse-1 ." "\"foo\"" }
{ $example "USING: lazy-lists parser-combinators ;" "\"_foo_\" 'italic' [ \"<emphasis>\" swap \"</emphasis>\" 3append ] <@ parse-1 ." "\"<emphasis>foo</emphasis>\"" } } ;
HELP: comma-list
{ $values 
  { "element" "a parser object" } { "parser" "a parser object" } }
{ $description 
    "Return a parser that parses comma separated lists of elements. "
    "'element' should be a parser that can parse the elements. The "
    "result of the parser is a sequence of the parsed elements." }
{ $examples
{ $example "USING: lazy-lits parser-combinators ;" "\"1,2,3,4\" 'integer' comma-list parse-1 ." "{ 1 2 3 4 }" } } ;

{ $see-also 'digit' 'integer' 'string' 'bold' 'italic' comma-list } related-words

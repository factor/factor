! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: parser-combinators.simple

HELP: digit-parser
{ $values
  { "parser" "a parser object" } }
{ $description
    "Return a parser that consumes a single digit from "
    "the input string. The numeric value of the digit "
    " consumed is the result of the parse." }
{ $examples
{ $example "USING: lists.lazy parser-combinators parser-combinators.simple prettyprint ;" "\"123\" digit-parser parse-1 ." "1" } } ;

HELP: integer-parser
{ $values
  { "parser" "a parser object" } }
{ $description
    "Return a parser that consumes an integer from "
    "the input string. The numeric value of the integer "
    " consumed is the result of the parse." }
{ $examples
{ $example "USING: lists.lazy parser-combinators parser-combinators.simple prettyprint ;" "\"123\" integer-parser parse-1 ." "123" } } ;
HELP: string-parser
{ $values
  { "parser" "a parser object" } }
{ $description
    "Return a parser that consumes a string enclosed in "
    "quotations from the input string. The string value "
    " consumed is the result of the parse." }
{ $examples
{ $example "USING: lists.lazy parser-combinators parser-combinators.simple prettyprint ;" "\"\\\"foo\\\"\" string-parser parse-1 ." "\"foo\"" } } ;

HELP: bold-parser
{ $values
  { "parser" "a parser object" } }
{ $description
    "Return a parser that consumes a string enclosed in "
    "the '*' character from the input string. This is "
    "commonly used in markup languages to indicate bold "
    "faced text." }
{ $example "USING: parser-combinators parser-combinators.simple prettyprint ;" "\"*foo*\" bold-parser parse-1 ." "\"foo\"" }
{ $example "USING: kernel parser-combinators parser-combinators.simple prettyprint sequences ;" "\"*foo*\" bold-parser [ \"<strong>\" \"</strong>\" surround ] <@ parse-1 ." "\"<strong>foo</strong>\"" } ;

HELP: italic-parser
{ $values
  { "parser" "a parser object" } }
{ $description
    "Return a parser that consumes a string enclosed in "
    "the '_' character from the input string. This is "
    "commonly used in markup languages to indicate italic "
    "faced text." }
{ $examples
{ $example "USING: parser-combinators parser-combinators.simple prettyprint ;" "\"_foo_\" italic-parser parse-1 ." "\"foo\"" }
{ $example "USING: kernel parser-combinators parser-combinators.simple prettyprint sequences ;" "\"_foo_\" italic-parser [ \"<emphasis>\" \"</emphasis>\" surround ] <@ parse-1 ." "\"<emphasis>foo</emphasis>\"" } } ;
HELP: comma-list
{ $values
  { "element" "a parser object" } { "parser" "a parser object" } }
{ $description
    "Return a parser that parses comma separated lists of elements. "
    { $snippet "element-parser" } " should be a parser that can parse the elements. The "
    "result of the parser is a sequence of the parsed elements." }
{ $examples
{ $example "USING: lists.lazy parser-combinators parser-combinators.simple prettyprint ;" "\"1,2,3,4\" integer-parser comma-list parse-1 ." "{ 1 2 3 4 }" } } ;

{ $see-also digit-parser integer-parser string-parser bold-parser italic-parser comma-list } related-words

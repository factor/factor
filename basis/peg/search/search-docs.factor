! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel peg sequences strings ;
IN: peg.search

HELP: tree-write
{ $values
  { "object" object } }
{ $description
    "Write the object to the standard output stream, unless "
    "it is an array, in which case recurse through the array "
    "writing each object to the stream." }
{ $example "USE: peg.search" "{ 65 \"bc\" { 68 \"ef\" } } tree-write" "AbcDef" } ;

HELP: search
{ $values
  { "string" string }
  { "parser" "a peg based parser" }
  { "seq"    sequence }
}
{ $description
    "Returns a sequence containing the parse results of all substrings "
    "from the input string that successfully parse using the "
    "parser."
}

{ $example "USING: peg.parsers peg.search prettyprint ;" "\"one 123 two 456\" 'integer' search ." "V{ 123 456 }" }
{ $example "USING: peg peg.parsers peg.search prettyprint ;" "\"one 123 \\\"hello\\\" two 456\" 'integer' 'string' 2choice search ." "V{ 123 \"hello\" 456 }" }
{ $see-also replace } ;

HELP: replace
{ $values
  { "string" string }
  { "parser" "a peg based parser" }
  { "result" string }
}
{ $description
    "Returns a copy of the original string but with all substrings that "
    "successfully parse with the given parser replaced with "
    "the result of that parser."
}
{ $example "USING: math math.parser peg peg.parsers peg.search prettyprint ;" "\"one 123 two 456\" 'integer' [ 2 * number>string ] action replace ." "\"one 246 two 912\"" }
{ $see-also search } ;


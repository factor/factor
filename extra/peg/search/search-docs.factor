! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup peg ;
IN: peg.search

HELP: tree-write
{ $values
  { "object" "an object" } }
{ $description
    "Write the object to the standard output stream, unless "
    "it is an array, in which case recurse through the array "
    "writing each object to the stream." }
{ $example "{ 65 \"bc\" { 68 \"ef\" } } tree-write" "AbcDef" } ;

HELP: search
{ $values
  { "string" "a string" }
  { "parser" "a peg based parser" }
  { "seq"    "a sequence" }
}
{ $description
    "Returns a sequence containing the parse results of all substrings "
    "from the input string that successfully parse using the "
    "parser."
}

{ $example "\"one 123 two 456\" 'integer' search" "V{ 123 456 }" }
{ $example "\"one 123 \\\"hello\\\" two 456\" 'integer' 'string' 2array choice search" "V{ 123 \"hello\" 456 }" }
{ $see-also replace } ;

HELP: replace
{ $values
  { "string" "a string" }
  { "parser" "a peg based parser" }
  { "result"    "a string" }
}
{ $description
    "Returns a copy of the original string but with all substrings that "
    "successfully parse with the given parser replaced with "
    "the result of that parser."
}
{ $example "\"one 123 two 456\" 'integer' [ 2 * number>string ] action replace" "\"one 246 two 912\"" }
{ $see-also search } ;


! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup parser-combinators
parser-combinators.replace ;

HELP: tree-write
{ $values 
  { "object" "an object" } }
{ $description 
    "Write the object to the standard output stream, unless "
    "it is an array, in which case recurse through the array "
    "writing each object to the stream." }
{ $example "[ { 65 \"bc\" { 68 \"ef\" } } tree-write ] string-out ." "\"AbcDef\"" } ;

HELP: search
{ $values 
  { "string" "a string" } 
  { "parser" "a parser combinator based parser" } 
  { "seq"    "a sequence" } 
}
{ $description 
    "Returns a sequence containing the parse results of all substrings "
    "from the input string that successfully parse using the "
    "parser."
}
    
{ $example "\"one 123 two 456\" 'integer' search ." "{ 123 456 }" }
{ $example "\"one 123 \\\"hello\\\" two 456\" 'integer' 'string' <|> search ." "{ 123 \"hello\" 456 }" }
{ $see-also search* replace replace* } ;

HELP: search*
{ $values 
  { "string" "a string" } 
  { "parsers" "a sequence of parser combinator based parsers" } 
  { "seq"    "a sequence" } 
}
{ $description 
    "Returns a sequence containing the parse results of all substrings "
    "from the input string that successfully parse using any of the "
    "parsers in the 'parsers' sequence."
}
    
{ $example "\"one 123 \\\"hello\\\" two 456\" 'integer' 'string' 2array search* ." "{ 123 \"hello\" 456 }" }
{ $see-also search replace replace* } ;

HELP: replace
{ $values 
  { "string" "a string" } 
  { "parser" "a parser combinator based parser" } 
  { "result"    "a string" } 
}
{ $description 
    "Returns a copy of the original string but with all substrings that "
    "successfully parse with the given parser replaced with "
    "the result of that parser."
}   
{ $example "\"one 123 two 456\" 'integer' [ 2 * number>string ] <@ replace ." "\"one 246 two 912\"" }
{ $example "\"hello *world* from *factor*\" 'bold' [ \"<strong>\" swap \"</strong>\" 3append ] <@ replace ." "\"hello <strong>world</strong> from <strong>factor</strong>\"" }
{ $example "\"hello *world* from _factor_\"\n 'bold' [ \"<strong>\" swap \"</strong>\" 3append ] <@\n 'italic' [ \"<emphasis>\" swap \"</emphasis>\" 3append ] <@ <|>\n replace ." "\"hello <strong>world</strong> from <emphasis>factor</emphasis>\"" }
{ $see-also search search* replace* } ;

HELP: replace*
{ $values 
  { "string" "a string" } 
  { "parsers" "a sequence of parser combinator based parsers" } 
  { "result"    "a string" } 
}
{ $description 
    "Returns a copy of the original string but with all substrings that "
    "successfully parse with the given parsers replaced with "
    "the result of that parser. Each parser is done in sequence so that "
    "the parse results of the first parser can be replaced by later parsers."
}   
{ $example "\"*hello _world_*\"\n 'bold' [ \"<strong>\" swap \"</strong>\" 3append ] <@\n 'italic' [ \"<emphasis>\" swap \"</emphasis>\" 3append ] <@ 2array\n replace* ." "\"<strong>hello <emphasis>world</emphasis></strong>\"" }
{ $see-also search search* replace* } ;


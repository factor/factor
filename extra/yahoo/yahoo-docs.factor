USING: help.syntax help.markup ;
IN: yahoo

HELP: search-yahoo
{ $values { "search" search } { "seq" "sequence of arrays of length 3" } }
{ $description "Uses Yahoo's REST API to search for the specified query, getting the number of answers specified. Returns a sequence of " { $link result } " instances." } ;

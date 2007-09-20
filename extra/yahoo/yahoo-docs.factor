USING: yahoo help.syntax help.markup ;

HELP: search-yahoo
{ $values { "search" "a string" } { "num" "a positive integer" } { "seq" "sequence of arrays of length 3" } }
{ $description "Uses Yahoo's REST API to search for the query specified in the search string, getting the number of answers specified. Returns a sequence of 3arrays, { title url summary }, each of which is a string." } ;

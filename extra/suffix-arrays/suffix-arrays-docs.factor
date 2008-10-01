! Copyright (C) 2008 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax io.streams.string
sequences strings math suffix-arrays.private ;
IN: suffix-arrays

HELP: >suffix-array
{ $values
     { "seq" sequence }
     { "array" array } }
{ $description "Creates a suffix array from the input sequence." } ;

HELP: SA{
{ $description "Creates a new literal suffix array at parse-time." } ;

HELP: suffixes
{ $values
     { "string" string }
     { "suffixes-seq" "a sequence of slices" } }
{ $description "Returns a sequence of tail slices of the input string." } ;

HELP: from-to
{ $values
     { "index" integer } { "suffix-array" "a suffix-array" } { "begin" string }
     { "from" integer } { "to" integer } }
{ $notes "Slices are [m,n) and we want (m,n) so we increment." } ;

HELP: query
{ $values
     { "begin" string } { "suffix-array" "a suffix-array" }
     { "matches" array } }
{ $description "Returns " } ;

ARTICLE: "suffix-arrays" "Suffix arrays"
"The " { $vocab-link "suffix-arrays" } " vocabulary implements the suffix array data structure for efficient lookup of subsequences. This suffix array implementation is a sorted array of suffixes. Querying it for matches uses binary search for efficiency." $nl

"Creating new suffix arrays:"
{ $subsection >suffix-array }
"Literal suffix arrays:"
{ $subsection POSTPONE: SA{ }
"Querying suffix arrays:"
{ $subsection query } ;

ABOUT: "suffix-arrays"

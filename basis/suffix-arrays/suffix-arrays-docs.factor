! Copyright (C) 2008 Marc Fauconneau.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax io.streams.string
sequences strings math suffix-arrays.private ;
IN: suffix-arrays

HELP: >suffix-array
{ $values
    { "seq" sequence }
    { "suffix-array" array } }
{ $description "Creates a suffix array from the input sequence. Suffix arrays are arrays of slices." } ;

HELP: SA{
{ $description "Creates a new literal suffix array at parse-time." } ;

HELP: suffixes
{ $values
    { "string" string }
    { "suffixes-seq" "a sequence of slices" } }
{ $description "Returns a sequence of tail slices of the input string." } ;

HELP: query
{ $values
    { "begin" sequence } { "suffix-array" "a suffix-array" }
    { "matches" array } }
{ $description "Returns a sequence of sequences from the suffix-array that contain the input sequence. An empty array is returned when there are no matches." } ;

ARTICLE: "suffix-arrays" "Suffix arrays"
"The " { $vocab-link "suffix-arrays" } " vocabulary implements the suffix array data structure for efficient lookup of subsequences. This suffix array implementation is a sorted array of suffixes. Querying it for matches uses binary search for efficiency." $nl

"Creating new suffix arrays:"
{ $subsections >suffix-array }
"Literal suffix arrays:"
{ $subsections POSTPONE: SA{ }
"Querying suffix arrays:"
{ $subsections query } ;

ABOUT: "suffix-arrays"

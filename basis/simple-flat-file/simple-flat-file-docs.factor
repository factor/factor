! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup strings biassocs arrays ;
IN: simple-flat-file

ABOUT: "simple-flat-file"

ARTICLE: "simple-flat-file" "Parsing simple flat files"
"The " { $vocab-link "simple-flat-file" } " vocabulary provides words for loading and parsing simple flat files in a particular format which is common for encoding and Unicode tasks."
{ $subsections
    flat-file>biassoc
    load-interval-file
    data
} ;

HELP: load-interval-file
{ $values { "filename" string } { "table" "an interval map" } }
{ $description "This loads a file that looks like Script.txt in the Unicode Character Database and converts it into an efficient interval map, where the keys are characters and the values are strings for the properties." } ;

HELP: data
{ $values { "filename" string } { "data" array } }
{ $description "This loads a file that's delineated by semicolons and lines, returning an array of lines, where each line is an array split by the semicolons, with whitespace trimmed off." } ;

HELP: flat-file>biassoc
{ $values { "filename" string } { "biassoc" biassoc } }
{ $description "This loads a flat file, in the form that many encoding resource files are in, with two columns of numeric data in hex, and returns a biassoc associating them." } ;

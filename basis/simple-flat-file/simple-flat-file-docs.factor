! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: arrays biassocs help.syntax help.markup interval-maps
strings ;
IN: simple-flat-file

ABOUT: "simple-flat-file"

ARTICLE: "simple-flat-file" "Parsing simple flat files"
"The " { $vocab-link "simple-flat-file" } " vocabulary provides words for loading and parsing simple flat files in a particular format which is common for encoding and Unicode tasks."
{ $subsections
    load-codetable-file
    load-interval-file
    load-data-file
} ;

HELP: load-interval-file
{ $values { "filename" string } { "table" interval-map } }
{ $description "This loads a file that looks like Script.txt in the Unicode Character Database and converts it into an efficient interval map, where the keys are characters and the values are strings for the properties." } ;

HELP: load-data-file
{ $values { "filename" string } { "data" array } }
{ $description "This loads a file that's delineated by semicolons and lines, returning an array of lines, where each line is an array split by the semicolons, with whitespace trimmed off." } ;

HELP: load-codetable-file
{ $values { "filename" string } { "biassoc" biassoc } }
{ $description "This loads a flat file, in the form that many encoding resource files are in, with two columns of numeric data in hex, and returns a biassoc associating them." } ;

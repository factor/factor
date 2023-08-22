! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel math strings ;
IN: wrap

ABOUT: "wrap"

ARTICLE: "wrap" "Word wrapping"
"The " { $vocab-link "wrap" } " vocabulary implements word wrapping. Wrapping can take place based on simple strings, assumed to be monospace, or abstract word objects."
{ $vocab-subsections
    { "String word wrapping" "wrap.strings" }
    { "Word object wrapping" "wrap.words" }
} ;

HELP: element
{ $class-description "An element to be wrapped. It has the following slots:" }
{ $slots
    { "contents" "The object being wrapped." }
    { "black" "The width of the object (e.g., the text length)." }
    { "white" "The space after the object (e.g., trailing whitespace)." }
} ;

HELP: wrap
{ $values { "elements" { $sequence element } } { "width" real } { "array" array } }
{ $description "Break the " { $snippet "elements" } " into lines such that the total width of each line tries to be less than " { $snippet "width" } " while attempting to minimize the raggedness represented by the amount of space at the end of each line. Returns an array of lines." } ;

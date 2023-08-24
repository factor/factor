! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math strings ;
IN: progress-bars

HELP: make-progress-bar
{ $values
    { "percent" "a real number between 0 and 1" } { "length" integer }
    { "string" string }
}
{ $description "Makes a progress bar " { $snippet "percent" } " completed that is " { $snippet "length" } " characters long." } ;

ARTICLE: "progress-bars" "Progress bars"
"The " { $vocab-link "progress-bars" } " vocabulary implements a simple progress bar string." $nl
"To make a generic progress bar string:"
{ $subsections make-progress-bar }
"The " { $vocab-link "progress-bars.models" } " vocabulary implements a word to display a progress bar that shows how much of a file has been read so far." ;

ABOUT: "progress-bars"

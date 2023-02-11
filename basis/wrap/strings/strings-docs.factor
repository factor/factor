! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup strings math ;
IN: wrap.strings

ABOUT: "wrap.strings"

ARTICLE: "wrap.strings" "String word wrapping"
"The " { $vocab-link "wrap.strings" } " vocabulary implements word wrapping for simple strings, assumed to be in monospace font."
{ $subsections
    wrap-lines
    wrap-string
    wrap-indented-string
} ;

HELP: wrap-lines
{ $values { "string" string } { "width" integer } { "newlines" "sequence of strings" } }
{ $description "Given a " { $snippet "string" } ", divides it into a sequence of lines where each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space." } ;

HELP: wrap-string
{ $values { "string" string } { "width" integer } { "newstring" string } }
{ $description "Given a " { $snippet "string" } ", alters the whitespace in the string so that each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space." } ;

HELP: wrap-indented-string
{ $values { "string" string } { "width" integer } { "indent" "string or integer" } { "newstring" string } }
{ $description "Given a " { $snippet "string" } ", alters the whitespace in the string so that each line has no more than " { $snippet "width" } " characters, unless there is a word longer than " { $snippet "width" } ". Linear whitespace between words is converted to a single space. The " { $snippet "indent" } " can be either a " { $link string } " or a number of spaces to prepend to each line." } ;

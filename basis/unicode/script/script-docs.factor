! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup strings unicode ;
IN: unicode.script

ABOUT: "unicode.script"

ARTICLE: "unicode.script" "Unicode script properties"
"The unicode standard gives every character a script. Note that this is different from a language, and that it is non-trivial to detect language from a string. To get the script of a character, use"
{ $subsections script-of } ;

HELP: script-of
{ $values { "char" "a code point" } { "script" string } }
{ $description "Finds the script of the given Unicode code point, represented as a string." } ;

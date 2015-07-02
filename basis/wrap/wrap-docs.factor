! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup strings math kernel ;
IN: wrap

ABOUT: "wrap"

ARTICLE: "wrap" "Word wrapping"
"The " { $vocab-link "wrap" } " vocabulary implements word wrapping. Wrapping can take place based on simple strings, assumed to be monospace, or abstract word objects."
{ $vocab-subsection "String word wrapping" "wrap.strings" }
{ $vocab-subsection "Word object wrapping" "wrap.words" } ;

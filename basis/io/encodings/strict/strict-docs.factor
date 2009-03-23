! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: io.encodings.strict

HELP: strict ( code -- strict )
{ $values { "code" "an encoding descriptor" } { "strict" "a strict encoding descriptor" } }
{ $description "Makes an encoding strict, that is, in the presence of a malformed code point, an error is thrown. Note that the existence of a replacement character in a file (U+FFFD) also throws an error." } ;

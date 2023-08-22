! Copyright (C) 2010 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax math math.approx ;

IN: math.approx

HELP: approximate
{ $values { "x" ratio } { "epsilon" ratio } { "y" ratio } }
{ $description
"Applied to two fractional numbers \"x\" and \"epsilon\", returns the "
"simplest rational number within \"epsilon\" of \"x\"."
$nl
"A rational number \"y\" is said to be simpler than another \"y'\" if "
"abs numerator y <= abs numerator y', and denominator y <= denominator y'"
$nl
"Any real interval contains a unique simplest rational; in particular note "
"that 0/1 is the simplest rational of all."
} ;

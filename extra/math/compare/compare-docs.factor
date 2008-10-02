! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax ;

IN: math.compare

HELP: absmin
{ $values { "a" "a number" } { "b" "a number" } { "x" "a number" } }
{ $description 
    "Returns the smaller absolute number with the original sign." 
} ;

HELP: absmax
{ $values { "a" "a number" } { "b" "a number" } { "x" "a number" } }
{ $description 
    "Returns the larger absolute number with the original sign."
} ;

HELP: posmax
{ $values { "a" "a number" } { "b" "a number" } { "x" "a number" } }
{ $description 
    "Returns the most-positive value, or zero if both are negative."
} ;

HELP: negmin
{ $values { "a" "a number" } { "b" "a number" } { "x" "a number" } }
{ $description 
    "Returns the most-negative value, or zero if both are positive."
} ;

HELP: clamp
{ $values { "a" "a number" } { "value" "a number" } { "b" "a number" } { "x" "a number" } }
{ $description 
    "Returns the value when between 'a' and 'b', 'a' if <= 'a', or 'b' if >= 'b'."
} ;


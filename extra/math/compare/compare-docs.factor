USING: help.markup help.syntax math ;
IN: math.compare

HELP: absmin
{ $values { "a" number } { "b" number } { "x" number } }
{ $description "Returns the smaller absolute number with the original sign." } ;

HELP: absmax
{ $values { "a" number } { "b" number } { "x" number } }
{ $description "Returns the larger absolute number with the original sign." } ;

HELP: posmax
{ $values { "a" number } { "b" number } { "x" number } }
{ $description "Returns the most-positive value, or zero if both are negative." } ;

HELP: negmin
{ $values { "a" number } { "b" number } { "x" number } }
{ $description "Returns the most-negative value, or zero if both are positive." } ;

USING: help.syntax help.markup arrays alien ;
IN: core-foundation.arrays

HELP: CF>array
{ $values { "alien" "a " { $snippet "CFArray" } } { "array" "an array of " { $link alien } " instances" } }
{ $description "Creates a Factor array from a Core Foundation array." } ;

HELP: <CFArray>
{ $values { "seq" "a sequence of " { $link alien } " instances" } { "alien" "a " { $snippet "CFArray" } } }
{ $description "Creates a Core Foundation array from a Factor array." } ;

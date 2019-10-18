USING: help.syntax help.markup strings ;
IN: core-foundation.strings

HELP: <CFString>
{ $values { "string" string } { "alien" "a " { $snippet "CFString" } } }
{ $description "Creates a Core Foundation string from a Factor string." } ;

HELP: CF>string
{ $values { "alien" "a " { $snippet "CFString" } } { "string" string } }
{ $description "Creates a Factor string from a Core Foundation string." } ;

HELP: CF>string-array
{ $values { "alien" "a " { $snippet "CFArray" } " of " { $snippet "CFString" } " instances" } { "seq" string } }
{ $description "Creates an array of Factor strings from a " { $snippet "CFArray" } " of " { $snippet "CFString" } "s." } ;

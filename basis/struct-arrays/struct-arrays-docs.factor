IN: struct-arrays
USING: help.markup help.syntax alien strings math ;

HELP: struct-array
{ $class-description "The class of C struct and union arrays."
$nl
"The " { $slot "underlying" } " slot holds a " { $link c-ptr } " with the raw data. This pointer can be passed to C functions." } ;

HELP: <struct-array>
{ $values { "length" integer } { "c-type" string } { "struct-array" struct-array } }
{ $description "Creates a new array for holding values of the specified C type." } ;

HELP: <direct-struct-array>
{ $values { "alien" c-ptr } { "length" integer } { "c-type" string } { "struct-array" struct-array } }
{ $description "Creates a new array for holding values of the specified C type, backed by the memory at " { $snippet "alien" } "." } ;

ARTICLE: "struct-arrays" "C struct and union arrays"
"The " { $vocab-link "struct-arrays" } " vocabulary implements arrays specialized for holding C struct and union values."
{ $subsection struct-array }
{ $subsection <struct-array> }
{ $subsection <direct-struct-array> } ;

ABOUT: "struct-arrays"

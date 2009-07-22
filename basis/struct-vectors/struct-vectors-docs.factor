IN: struct-vectors
USING: help.markup help.syntax alien strings math ;

HELP: struct-vector
{ $class-description "The class of growable C struct and union arrays." } ;

HELP: <struct-vector>
{ $values { "capacity" integer } { "c-type" string } { "struct-vector" struct-vector } }
{ $description "Creates a new vector with the given initial capacity." } ;

ARTICLE: "struct-vectors" "C struct and union vectors"
"The " { $vocab-link "struct-vectors" } " vocabulary implements vectors specialized for holding C struct and union values. These are growable versions of " { $vocab-link "struct-arrays" } "."
{ $subsection struct-vector }
{ $subsection <struct-vector> } ;

ABOUT: "struct-vectors"

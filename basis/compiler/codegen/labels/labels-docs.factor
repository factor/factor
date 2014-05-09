USING: help.markup help.syntax strings ;
IN: compiler.codegen.labels

HELP: define-label
{ $values { "name" string } }
{ $description "Defines a new label with the given name. The " { $slot "offset" } " slot is filled in later." } ;

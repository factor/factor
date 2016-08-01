USING: byte-arrays compiler.codegen.relocation help.markup help.syntax
strings ;
IN: compiler.codegen.labels

HELP: binary-literal-table
{ $var-description "A relocation table used during code generation to keep track of binary relocations. Binary literals are stored at the end of the generated assembly code on the code heap." } ;

HELP: define-label
{ $values { "name" string } }
{ $description "Defines a new label with the given name. The " { $slot "offset" } " slot is filled in later." } ;

HELP: emit-binary-literals
{ $description "Emits all binary literals in the " { $link binary-literal-table } "." } ;

HELP: rel-binary-literal
{ $values { "literal" byte-array } { "class" "relocation class" } }
{ $description "Adds a binary literal to the relocation table." }
{ $see-also binary-literal-table } ;

HELP: resolve-label
{ $values { "label/name" { $link label } " or " { $link string } } }
{ $description "Assigns the current " { $link compiled-offset } " to the given label." } ;

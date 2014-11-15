USING: assocs compiler.cfg compiler.cfg.instructions cpu.architecture
help.markup help.syntax math ;
IN: compiler.cfg.linear-scan.allocation.state

HELP: init-allocator
{ $values { "registers" { $link assoc } " mapping from register class to available machine registers." } }
{ $description "Initializes the state for the register allocator." }
{ $see-also reg-class } ;

HELP: next-spill-slot
{ $values { "size" "number of bytes required" } { "spill-slot" spill-slot } }
{ $description "Creates a new " { $link spill-slot } " of the given size and also allocates space in the " { $link cfg } " in the 'cfg' dynamic variable for it." } ;

HELP: spill-slots
{ $var-description "Mapping from vregs to spill slots." } ;

HELP: align-spill-area
{ $values { "align" integer } }
{ $description "This word is used to ensure that the alignment of the spill area in the " { $link cfg } " is equal to the largest " { $link spill-slot } "." } ;

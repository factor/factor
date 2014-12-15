USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals cpu.architecture heaps help.markup
help.syntax math vectors ;
IN: compiler.cfg.linear-scan.allocation.state

HELP: active-intervals
{ $var-description { $link assoc } " of active live intervals. The keys are register class symbols and the values vectors of " { $link live-interval-state } "." } ;

HELP: handled-intervals
{ $var-description { $link vector } " of handled live intervals." } ;

HELP: unhandled-intervals
{ $var-description { $link min-heap } " of live intervals which still need a register allocation." } ;

HELP: unhandled-sync-points
{ $var-description { $link min-heap } " of sync points which still need to be processed." } ;

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

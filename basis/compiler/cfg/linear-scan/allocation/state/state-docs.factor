USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.live-intervals cpu.architecture heaps help.markup
help.syntax kernel math sequences vectors ;
IN: compiler.cfg.linear-scan.allocation.state

HELP: activate-intervals
{ $values { "n" integer } }
{ $description "Any inactive intervals which have ended are moved to handled. Any inactive intervals which do not cover the current position are moved to active." } ;

HELP: active-intervals
{ $var-description { $link assoc } " of active live intervals. The keys are register class symbols and the values vectors of " { $link live-interval-state } "." } ;

HELP: add-active
{ $values { "live-interval" live-interval-state } }
{ $description "Adds a live interval to the " { $link active-intervals } " assoc." }
{ $see-also active-intervals } ;

HELP: align-spill-area
{ $values { "align" integer } { "cfg" cfg } }
{ $description "This word is used to ensure that the alignment of the spill area in the " { $link cfg } " is equal to the largest " { $link spill-slot } "." } ;

HELP: assign-spill-slot
{ $values
  { "coalesced-vreg" "vreg" }
  { "rep" representation }
  { "spill-slot" spill-slot }
}
{ $description "Assigns a spill slot for the vreg." } ;

HELP: deactivate-intervals
{ $values { "n" integer } }
{ $description "Any active intervals which have ended are moved to handled. Any active intervals which cover the current position are moved to inactive." } ;

HELP: free-positions
{ $values
  { "registers" assoc }
  { "reg-class" reg-class }
  { "assoc" assoc }
}
{ $description "Returns an assoc with the registers that can be used by the live interval. A utility used by " { $link register-status } " word." } ;

HELP: handled-intervals
{ $var-description { $link vector } " of handled live intervals. This variable I think is only used during the " { $link allocate-registers } " step." } ;

HELP: inactive-intervals
{ $var-description { $link assoc } " of inactive live intervals. Keys are register class symbols and the values vectors of " { $link live-interval-state } "." }
{ $see-also active-intervals } ;

HELP: init-allocator
{ $values
  { "live-intervals" { $link sequence } " of " { $link live-interval-state } }
  { "sync-points" { $link sequence } " of " { $link sync-point } }
  { "registers" { $link assoc } " mapping from register class to available machine registers." }
}
{ $description "Initializes the state for the register allocator." }
{ $see-also reg-class } ;

HELP: next-spill-slot
{ $values { "size" "number of bytes required" } { "spill-slot" spill-slot } }
{ $description "Creates a new " { $link spill-slot } " of the given size and also allocates space in the " { $link cfg } " in the 'cfg' dynamic variable for it." } ;

HELP: progress
{ $var-description "Start index of current live interval. We ensure that all live intervals added to the unhandled set have a start index strictly greater than this one. This ensures that we can catch infinite loop situations. We also ensure that all live intervals added to the handled set have an end index strictly smaller than this one. This helps catch bugs." }
{ $see-also check-handled check-unhandled } ;

HELP: register-available?
{ $values { "new" live-interval-state } { "result" "a pair" } { "?" boolean } }
{ $description "Whether the register in 'result' can be used for the given live interval." } ;

HELP: registers
{ $var-description "Mapping from register classes to sequences of machine registers." } ;

HELP: spill-slots
{ $var-description "Mapping from pairs of vregs and represenation sizes to spill slots." } ;

HELP: unhandled-min-heap
{ $var-description { $link min-heap } " of all live intervals and sync points which still needs processing. It is used by " { $link (allocate-registers) } ". The key of the heap is a pair of values, " { $slot "start" } " and " { $slot "end" } " for the "  { $link live-interval-state } " tuple and " { $slot "n" } " and 1/0.0 for the " { $link sync-point } " tuple. That way smaller live intervals are always processed before larger ones and all live intervals before sync points." } ;

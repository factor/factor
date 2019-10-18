USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.live-intervals compiler.cfg.stack-frame
cpu.architecture heaps help.markup help.syntax kernel math sequences
vectors ;
IN: compiler.cfg.linear-scan.allocation.state

HELP: activate-intervals
{ $values { "n" integer } }
{ $description "Any inactive intervals which have ended are moved to handled. Any inactive intervals which do not cover the current position are moved to active." } ;

HELP: active-intervals
{ $var-description { $link assoc } " of active live intervals. The keys are register class symbols and the values vectors of " { $link live-interval-state } "." } ;

HELP: active-intervals-for
{ $values { "live-interval" live-interval-state } { "seq" sequence } }
{ $description "Finds the active live intervals sharing the same register class as the given interval." } ;

HELP: add-active
{ $values { "live-interval" live-interval-state } }
{ $description "Adds a live interval to the " { $link active-intervals } " assoc." }
{ $see-also active-intervals } ;

HELP: align-spill-area
{ $values { "align" integer } { "stack-frame" stack-frame } }
{ $description "This word is used to ensure that the alignment of the spill area in the " { $link cfg } " is equal to the largest " { $link spill-slot } "." } ;

HELP: assign-spill-slot
{ $values
  { "coalesced-vreg" "vreg" }
  { "rep" representation }
  { "spill-slot" spill-slot }
}
{ $description "Assigns a spill slot for the vreg. The stack frames spill area align is updated so that it is at least as large as the vregs size. Then a " { $link spill-slot } " is assigned for the vreg/rep-size combination if one hasn't already been assigned and is put on the stack." }
{ $see-also next-spill-slot } ;

HELP: deactivate-intervals
{ $values { "n" integer } }
{ $description "Any active intervals which have ended are moved to handled. Any active intervals which cover the current position are moved to inactive." } ;

HELP: handled-intervals
{ $var-description { $link vector } " of handled live intervals. This variable I think is only used during the " { $link allocate-registers } " step." } ;

HELP: inactive-intervals
{ $var-description { $link assoc } " of inactive live intervals. Keys are register class symbols and the values vectors of " { $link live-interval-state } "." }
{ $see-also active-intervals } ;

HELP: init-allocator
{ $values
  { "intervals/sync-points" { $link sequence } " of " { $link live-interval-state } " and " { $link sync-point } "." }
  { "registers" { $link assoc } " mapping from register class to available machine registers." }
}
{ $description "Initializes the state for the register allocator." }
{ $see-also reg-class } ;

HELP: next-spill-slot
{ $values
  { "size" "number of bytes required" }
  { "stack-frame" stack-frame }
  { "spill-slot" spill-slot }
}
{ $description "Creates a new " { $link spill-slot } " of the given size and also allocates space in the " { $link cfg } " in the cfg for it." } ;

HELP: progress
{ $var-description "Start index of current live interval. We ensure that all live intervals added to the unhandled set have a start index greater than or equal to this one. This ensures that we can catch infinite loop situations. We also ensure that all live intervals added to the handled set have an end index strictly smaller than this one. This helps catch bugs." }
{ $see-also check-handled check-unhandled } ;

HELP: register-available?
{ $values { "new" live-interval-state } { "result" "a pair" } { "?" boolean } }
{ $description "Whether the register in 'result' can be used for the given live interval." } ;

HELP: registers
{ $var-description "Mapping from register classes to sequences of machine registers." } ;

HELP: spill-slots
{ $var-description "Mapping from pairs of vregs and represenation sizes to spill slots." }
{ $see-also init-allocator } ;

HELP: unhandled-min-heap
{ $var-description { $link min-heap } " of all live intervals and sync points which still needs processing. It is used by " { $link (allocate-registers) } ". The key of the heap is a pair of values, " { $slot "start" } " and " { $slot "end" } " for the " { $link live-interval-state } " tuple and " { $slot "n" } " and 1/0.0 for the " { $link sync-point } " tuple. That way smaller live intervals are always processed before larger ones and all live intervals before sync points." } ;

ARTICLE: "compiler.cfg.linear-scan.allocation.state" "Live interval state"
"Active intervals:"
{ $subsections active-intervals active-intervals-for add-active } ;

ABOUT: "compiler.cfg.linear-scan.allocation.state"

USING: compiler.cfg.instructions help.markup help.syntax sequences strings ;
IN: compiler.cfg.stacks.vacant

ARTICLE: "compiler.cfg.stacks.vacant" "Uninitialized/overinitialized stack location analysis"
"Consider the following sequence of instructions:"
{ $code
  "##inc-d 2"
  "..."
  "##allot"
  "##replace ... D 0"
  "##replace ... D 1"
}
"The GC check runs before stack locations 0 and 1 have been initialized, and so the GC needs to scrub them so that they don't get traced. This is achieved by computing uninitialized locations with a dataflow analysis, and recording the information in GC maps. The call_frame_slot_visitor object in vm/slot_visitor.hpp reads this information from GC maps and performs the scrubbing." ;

! HELP: initial-state
! { $description "Initially the stack bottom is at 0 for both the data and retain stacks and no replaces have been registered." } ;

HELP: vacant>bits
{ $values
  { "vacant" "sequence of uninitialized stack locations" }
  { "bits" "sequence of 1:s and 0:s" }
}
{ $description "Converts a sequence of uninitialized stack locations to the pattern of 1:s and 0:s that can be put in the " { $slot "scrub-d" } " and " { $slot "scrub-r" } " slots of a " { $link gc-map } ". 0:s are uninitialized locations and 1:s are initialized." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.vacant prettyprint ;"
    "{ 0 1 3 } vacant>bits ."
    "{ 0 0 1 0 }"
  }
} ;

HELP: overinitialized>bits
{ $values
  { "overinitialized" "sequence of overinitialized stack locations" }
  { "bits" "sequence of 1:s and 0:s" }
}
{ $description "Converts a sequence of overinitialized stack locations to the pattern of 1:s and 0:s that can be put in the " { $slot "check-d" } " and " { $slot "check-r" } " slots of a " { $link gc-map } ". 0:s are initialized locations and 0:s are empty ones. First element is stack location -1,second -2 and so on." } ;

ABOUT: "compiler.cfg.stacks.vacant"

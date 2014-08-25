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
"The GC check runs before stack locations 0 and 1 have been initialized, and so the GC needs to scrub them so that they don't get traced. This is achieved by computing uninitialized locations with a dataflow analysis, and recording the information in GC maps. The scrub_contexts() method on vm/gc.cpp reads this information from GC maps and performs the scrubbing." ;

HELP: initial-state
{ $description "Initially the stack bottom is at 0 for both the data and retain stacks and no replaces have been registered." } ;

HELP: vacant>bit-pattern
{ $values
  { "vacant" "sequence of uninitialized stack locations" }
  { "bit-pattern" "sequence of 1:s and 0:s" }
}
{ $description "Converts a sequence of uninitialized stack locations to the pattern of 1:s and 0:s that can be put in the " { $slot "scrub-d" } " and " { $slot "scrub-r" } " slots of a " { $link gc-map } "." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.vacant prettyprint ;"
    "{ 0 1 3 } vacant>bit-pattern ."
    "{ 0 0 1 0 }"
  }
} ;

ABOUT: "compiler.cfg.stacks.vacant"

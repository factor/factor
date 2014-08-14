USING: help.markup help.syntax sequences strings ;
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

ABOUT: "compiler.cfg.stacks.vacant"

USING: assocs compiler.cfg compiler.cfg.registers help.markup help.syntax math
sequences ;
IN: compiler.cfg.stacks.local

HELP: replace-mapping
{ $var-description "An " { $link assoc } " that maps from stack locations to virtual registers that were put on the stack." }
{ $see-also replace-loc } ;

HELP: current-height
{ $class-description "A tuple used to keep track of the heights of the data and retain stacks in a " { $link basic-block } " The idea is that if the stack change instructions are tracked, then multiple changes can be folded into one. It has the following slots:"
  { $table
    { { $slot "d" } { "Current datastack height." } }
    { { $slot "r" } { "Current retainstack height." } }
    { { $slot "emit-d" } { "Queued up datastack height change." } }
    { { $slot "emit-r" } { "Queued up retainstack height change." } }
  }
} ;

HELP: loc>vreg
{ $values { "loc" loc } { "vreg" "virtual register" } }
{ $description "Maps a stack location to a virtual register." } ;

HELP: replace-loc
{ $values { "vreg" "virtual register" } { "loc" loc } }
{ $description "Registers that the absolute stack location " { $snippet "loc" } " should be overwritten with the contents of the virtual register." } ;

HELP: peek-loc
{ $values { "loc" loc } { "vreg" "virtaul register" } }
{ $description "Retrieves the virtual register and the given stack location." } ;

HELP: translate-local-loc
{ $values { "loc" loc } { "loc'" loc } }
{ $description "Translates an absolute stack location to one that is relative to the current stacks height as given in " { $link current-height } "." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local compiler.cfg.registers compiler.cfg.debugger namespaces prettyprint ;"
    "T{ current-height { d 3 } } current-height set D 7 translate-local-loc ."
    "D 4"
  }
} ;

HELP: height-changes
{ $values { "current-height" current-height } { "insns" sequence } }
{ $description "Converts a " { $link current-height } " tuple to 0-2 stack height change instructions." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local ;"
    "T{ current-height { emit-d 4 } { emit-r -2 } } height-changes ."
    "{ T{ ##inc-d { n 4 } } T{ ##inc-r { n -2 } } }"
  }
} ;

HELP: emit-changes
{ $description "Insert height and stack changes prior to the last instruction." } ;

HELP: inc-d
{ $values { "n" number } }
{ $description "Increases or decreases the current datastacks height." } ;

ARTICLE: "compiler.cfg.stacks.local" "Local stack analysis"
"Local stack analysis. We build three sets for every basic block in the CFG:"
{ $list
  "peek-set: all stack locations that the block reads before writing"
  "replace-set: all stack locations that the block writes"
  "kill-set: all stack locations which become unavailable after the block ends because of the stack height being decremented" }
"This is done while constructing the CFG." ;


ABOUT: "compiler.cfg.stacks.local"

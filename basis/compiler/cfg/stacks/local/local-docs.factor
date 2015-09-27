USING: assocs compiler.cfg compiler.cfg.instructions compiler.cfg.registers
help.markup help.syntax math sequences ;
IN: compiler.cfg.stacks.local

HELP: replaces
{ $var-description "An " { $link assoc } " that maps from stack locations to virtual registers that were put on the stack." }
{ $see-also replace-loc } ;

HELP: height-state
{ $var-description "A two-tuple used to keep track of the heights of the data and retain stacks in a " { $link basic-block } " The idea is that if the stack change instructions are tracked, then multiple changes can be folded into one. The first item is the datastacks current height and queued up height change. The second item is the same for the retain stack." } ;

HELP: loc>vreg
{ $values { "loc" loc } { "vreg" "virtual register" } }
{ $description "Maps a stack location to a virtual register." } ;

HELP: replace-loc
{ $values { "vreg" "virtual register" } { "loc" loc } }
{ $description "Registers that the absolute stack location " { $snippet "loc" } " should be overwritten with the contents of the virtual register." }
{ $see-also replaces } ;

HELP: peek-loc
{ $values { "loc" loc } { "vreg" "virtaul register" } }
{ $description "Retrieves the virtual register at the given stack location." } ;

HELP: translate-local-loc
{ $values { "loc" loc } { "state" "height state" }  { "loc'" loc } }
{ $description "Translates an absolute stack location to one that is relative to the given height state." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local compiler.cfg.registers compiler.cfg.debugger namespaces prettyprint ;"
    "D: 7 { { 3 0 } { 0 0 } } translate-local-loc ."
    "D: 4"
  }
}
{ $see-also height-state } ;

HELP: height-state>insns
{ $values { "state" sequence } { "insns" sequence } }
{ $description "Converts a " { $link height-state } " tuple to 0-2 stack height change instructions." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local prettyprint ;"
    "{ { 0 4 } { 0 -2 } } height-state>insns ."
    "{ T{ ##inc { loc D: 4 } } T{ ##inc { loc R: -2 } } }"
  }
} ;

HELP: emit-changes
{ $values { "replaces" sequence } { "state" sequence } }
{ $description "Insert height and stack changes prior to the last instruction." } ;

HELP: inc-stack
{ $values { "loc" loc } }
{ $description "Increases or decreases the data or retain stack depending on if loc is a " { $link ds-loc } " or " { $link rs-loc } " instance. An " { $link ##inc } " instruction will later be inserted." } ;

ARTICLE: "compiler.cfg.stacks.local" "Local stack analysis"
"Local stack analysis. We build three sets for every basic block in the CFG:"
{ $list
  "peek-set: all stack locations that the block reads before writing"
  "replace-set: all stack locations that the block writes"
  "kill-set: all stack locations which become unavailable after the block ends because of the stack height being decremented" }
"This is done while constructing the CFG."
$nl
"Words for reading the stack state:"
{ $subsections
  peek-loc
  translate-local-loc }
"Words for writing the stack state:"
{ $subsections
  adjust
  inc-stack
  modify-height
  replace-loc
} ;


ABOUT: "compiler.cfg.stacks.local"

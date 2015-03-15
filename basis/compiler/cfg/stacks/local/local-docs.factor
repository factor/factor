USING: assocs compiler.cfg compiler.cfg.instructions compiler.cfg.registers
help.markup help.syntax math sequences ;
IN: compiler.cfg.stacks.local

HELP: replace-mapping
{ $var-description "An " { $link assoc } " that maps from stack locations to virtual registers that were put on the stack." }
{ $see-also replace-loc } ;

HELP: height-state
{ $var-description "A two-tuple used to keep track of the heights of the data and retain stacks in a " { $link basic-block } " The idea is that if the stack change instructions are tracked, then multiple changes can be folded into one. The first item is the datastacks current height and queued up height change. The second item is the same for the retain stack." } ;

HELP: loc>vreg
{ $values { "loc" loc } { "vreg" "virtual register" } }
{ $description "Maps a stack location to a virtual register." } ;

HELP: replace-loc
{ $values { "vreg" "virtual register" } { "loc" loc } }
{ $description "Registers that the absolute stack location " { $snippet "loc" } " should be overwritten with the contents of the virtual register." } ;

HELP: peek-loc
{ $values { "loc" loc } { "vreg" "virtaul register" } }
{ $description "Retrieves the virtual register at the given stack location." } ;

HELP: translate-local-loc
{ $values { "state" "height state" } { "loc" loc } { "loc'" loc } }
{ $description "Translates an absolute stack location to one that is relative to the given height state." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local compiler.cfg.registers compiler.cfg.debugger namespaces prettyprint ;"
    "{ { 3 0 } { 0 0 } } D 7 translate-local-loc ."
    "D 4"
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
    "{ T{ ##inc { loc D 4 } } T{ ##inc { loc R -2 } } }"
  }
} ;

HELP: emit-changes
{ $description "Insert height and stack changes prior to the last instruction." } ;

HELP: inc-d
{ $values { "n" number } }
{ $description "Increases or decreases the current datastacks height. An " { $link ##inc } " instruction will later be inserted." } ;

HELP: inc-r
{ $values { "n" number } }
{ $description "Increases or decreases the current retainstacks height. An " { $link ##inc } " instruction will later be inserted." } ;

ARTICLE: "compiler.cfg.stacks.local" "Local stack analysis"
"Local stack analysis. We build three sets for every basic block in the CFG:"
{ $list
  "peek-set: all stack locations that the block reads before writing"
  "replace-set: all stack locations that the block writes"
  "kill-set: all stack locations which become unavailable after the block ends because of the stack height being decremented" }
"This is done while constructing the CFG." ;


ABOUT: "compiler.cfg.stacks.local"

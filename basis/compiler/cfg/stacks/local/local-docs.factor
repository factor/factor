USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks hash-sets hashtables
help.markup help.syntax kernel math sequences ;
IN: compiler.cfg.stacks.local

HELP: emit-insns
{ $values { "replaces" sequence } { "state" sequence } }
{ $description "Insert height and stack changes prior to the last instruction." } ;

HELP: end-local-analysis
{ $values { "basic-block" basic-block } }
{ $description "Called to end the local analysis of a block. The word fills in the blocks slots " { $slot "replaces" } ", " { $slot "peeks" } " and " { $slot "kills" } " with what the blocks replaces, peeks and kill locations are." } ;

HELP: height-state
{ $var-description "A two-tuple used to keep track of the heights of the data and retain stacks in a " { $link basic-block } " The idea is that if the stack change instructions are tracked, then multiple changes can be folded into one. The first item is the datastacks current height and queued up height change. The second item is the same for the retain stack." } ;

HELP: height-state>insns
{ $values { "state" sequence } { "insns" sequence } }
{ $description "Converts a " { $link height-state } " tuple to 0-2 stack height change instructions." }
{ $examples
  "In this example the datastacks height is increased by 4 and the retainstacks decreased by 2."
  { $example
    "USING: compiler.cfg.stacks.local prettyprint ;"
    "{ { 0 4 } { 0 -2 } } height-state>insns ."
    "{ T{ ##inc { loc D: 4 } } T{ ##inc { loc R: -2 } } }"
  }
} ;

HELP: inc-stack
{ $values { "loc" loc } }
{ $description "Increases or decreases the data or retain stack depending on if loc is a " { $link ds-loc } " or " { $link rs-loc } " instance. An " { $link ##inc } " instruction will later be inserted." } ;

HELP: loc>vreg
{ $values { "loc" loc } { "vreg" "virtual register" } }
{ $description "Maps a stack location to a virtual register." } ;

HELP: local-kill-set
{ $values
  { "ds-height" integer }
  { "rs-height" integer }
  { "state" sequence }
  { "set" hash-set }
}
{ $description "The set of stack locations that was killed." }
{ $see-also compute-local-kill-set } ;

HELP: local-peek-set
{ $var-description "A " { $link hash-set } " used during local block analysis to keep track of peeked stack locations." } ;

HELP: peek-loc
{ $values { "loc" loc } { "vreg" "virtual register" } }
{ $description "Retrieves the virtual register at the given stack location. If no register has been stored at that location, then a new vreg is returned." } ;

HELP: record-stack-heights
{ $values { "ds-height" number } { "rs-height" number } { "bb" basic-block } }
{ $description "Sets the data and retain stack heights in relation to the cfg of this basic block." } ;

HELP: replace-loc
{ $values { "vreg" "virtual register" } { "loc" loc } }
{ $description "Registers that the absolute stack location " { $snippet "loc" } " should be overwritten with the contents of the virtual register." }
{ $see-also replaces } ;

HELP: replaces
{ $var-description "An " { $link assoc } " that maps from stack locations to virtual registers that were put on the stack during the local analysis phase. " { $link ds-push } " and similar words writes to it." }
{ $see-also replace-loc } ;

HELP: translate-local-loc
{ $values { "loc" loc } { "state" "height state" }  { "loc'" loc } }
{ $description "Translates an absolute stack location to one that is relative to the given height state." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local compiler.cfg.registers namespaces prettyprint ;"
    "D: 7 { { 3 0 } { 0 0 } } translate-local-loc ."
    "D: 4"
  }
}
{ $see-also height-state } ;

ARTICLE: "compiler.cfg.stacks.local" "Local stack analysis"
"Local stack analysis. For each " { $link basic-block } " in the " { $link cfg } ", three sets containing stack locations are built:"
{ $list
  { { $slot "peeks" } " all stack locations that the block reads before writing" }
  { { $slot "replaces" } " all stack locations that the block writes" }
  { { $slot "kills" } " all stack locations which become unavailable after the block ends because of the stack height being decremented. For example, if the block contains " { $link drop } ", then D: 0 will be contained in kills because that stack location will not be live anymore." }
}
"This is done while constructing the CFG."
$nl
"Words for reading the stack state:"
{ $subsections
  peek-loc
  translate-local-loc }
"Words for writing the stack state:"
{ $subsections
  inc-stack
  modify-height
  replace-loc
}
"Beginning and ending analysis:"
{ $subsections
  begin-local-analysis
  end-local-analysis
}
"Temporary variables that keeps track of the block's read and written stack locations:"
{ $subsections
  local-peek-set
  replaces
} ;


ABOUT: "compiler.cfg.stacks.local"

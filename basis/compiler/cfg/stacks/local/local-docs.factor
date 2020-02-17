USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks hash-sets hashtables
help.markup help.syntax kernel math sequences ;
IN: compiler.cfg.stacks.local

HELP: begin-local-analysis
{ $values { "basic-block" basic-block } }
{ $description "Begins the local analysis of the block. The height slot of the block is initialized with the resulting height of the last block." } ;

HELP: emit-insns
{ $values { "replaces" sequence } { "state" sequence } }
{ $description "Insert height and stack changes prior to the last instruction." } ;

HELP: end-local-analysis
{ $values { "basic-block" basic-block } }
{ $description "Called to end the local analysis of a block. The word fills in the blocks slots " { $slot "replaces" } ", " { $slot "peeks" } " and " { $slot "kills" } " with what the blocks replaces, peeks and kill locations are." } ;

HELP: global-loc>local
{ $values { "loc" loc } { "height-state" height-state } { "loc'" loc } }
{ $description "Translates an absolute stack location to one that is relative to the given height state." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local compiler.cfg.registers namespaces prettyprint ;"
    "D: 7 T{ height-state f 3 0 0 0 } global-loc>local ."
    "D: 4"
  }
}
{ $see-also height-state local-loc>global } ;

HELP: height-state
{ $description "A tuple which keeps track of the stacks heights and increments of a " { $link basic-block } " during local analysis. The idea is that if the stack change instructions are tracked, then multiple changes can be folded into one. It has the following slots:"
  { $slots
    {
        "ds-begin"
        "Datastack height at the beginning of the block."
    }
    {
        "rs-begin"
        "Retainstack height at the beginning of the block."
    }
    {
        "ds-inc"
        "Datastack change during the block."
    }
    {
        "rs-inc"
        "Retainstack change during the block."
    }
  }
}
{ $see-also inc-stack reset-incs } ;

HELP: height-state>insns
{ $values { "height-state" height-state } { "insns" sequence } }
{ $description "Converts a " { $link height-state } " tuple to 0-2 stack height change instructions." }
{ $examples
  "In this example the datastacks height is increased by 4 and the retainstacks decreased by 2."
  { $example
    "USING: compiler.cfg.stacks.local prettyprint ;"
    "T{ height-state f 0 0 4 -2 } height-state>insns ."
    "{ T{ ##inc { loc D: 4 } } T{ ##inc { loc R: -2 } } }"
  }
} ;

HELP: inc-stack
{ $values { "loc" loc } }
{ $description "Increases or decreases the data or retain stack depending on if loc is a " { $link ds-loc } " or " { $link rs-loc } " instance. An " { $link ##inc } " instruction will later be inserted." } ;

HELP: local-loc>global
{ $values { "loc" loc } { "height-state" height-state } { "loc'" loc } }
{ $description "Translates a stack location relative to a block to an absolute one. The word does the opposite to " { $link global-loc>local } "." } ;

HELP: loc>vreg
{ $values { "loc" loc } { "vreg" "virtual register" } }
{ $description "Maps a stack location to a virtual register." } ;

HELP: local-kill-set
{ $values
  { "ds-begin" integer }
  { "ds-inc" integer }
  { "rs-begin" integer }
  { "rs-inc" integer }
  { "set" hash-set }
}
{ $description "The set of stack locations that was killed. Locations on a stack are deemed killed if that stacks height is decremented." }
{ $see-also compute-local-kill-set } ;

HELP: local-peek-set
{ $var-description "A " { $link hash-set } " used during local block analysis to keep track of peeked stack locations." } ;

HELP: peek-loc
{ $values { "loc" loc } { "vreg" "virtual register" } }
{ $description "Retrieves the virtual register at the given stack location. If no register has been stored at that location, then a new vreg is returned." } ;

HELP: replace-loc
{ $values { "vreg" "virtual register" } { "loc" loc } }
{ $description "Registers that the absolute stack location " { $snippet "loc" } " should be overwritten with the contents of the virtual register." }
{ $see-also replaces } ;

HELP: replaces
{ $var-description "An " { $link assoc } " that maps from stack locations to virtual registers that were put on the stack during the local analysis phase. " { $link ds-push } " and similar words writes to it." }
{ $see-also replace-loc } ;

ARTICLE: "compiler.cfg.stacks.local" "Local stack analysis"
"For each " { $link basic-block } " in the " { $link cfg } ", local stack analysis is performed. The analysis is started right after the block is created with " { $link begin-local-analysis } " and finished with " { $link end-local-analysis } ", when the construction of the block is complete. During the analysis, three sets containing stack locations are built:"
{ $slots
  { "peeks" { " all stack locations that the block reads before writing" } }
  { "replaces" { " all stack locations that the block writes" } }
  { "kills" { " all stack locations which become unavailable after the block ends because of the stack height being decremented. For example, if the block contains " { $link drop } ", then D: 0 will be contained in kills because that stack location will not be live anymore." } }
}
"This is done while constructing the CFG. These sets are then used by the " { $link end-stack-analysis } " word to emit optimal sequences of " { $link ##peek } " and " { $link ##replace } " instructions to the cfg."
$nl
"For example, the code [ dup dup dup ] will only execute ##peek once, instead of three time which a 'non-lazy' method would."
$nl
"Words for reading the stack state:"
{ $subsections
  peek-loc
  global-loc>local
  local-loc>global
}
"Words for writing the stack state:"
{ $subsections
  inc-stack
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

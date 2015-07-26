USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.ssa.destruction.leaders compiler.cfg.ssa.interference
help.markup help.syntax kernel make sequences ;
IN: compiler.cfg.ssa.destruction.coalescing

HELP: class-element-map
{ $var-description "Maps leaders to equivalence class elements which are sequences of " { $link vreg-info } " instances." } ;

HELP: coalesce-cfg
{ $values { "cfg" cfg } }
{ $description "In this step, " { $link leader-map } " info is calculated." } ;

HELP: coalesce-elements
{ $values { "merged" "??" } { "follower" "vreg" } { "leader" "vreg" } }
{ $description "Delete follower's class, and set leaders's class to merged." } ;

HELP: coalesce-insn
{ $values { "insn" insn } }
{ $description "Generic word supposed to be called in a " { $link make } " context which generates a list of eliminatable vreg copies. The word either eliminates copies immediately in case of " { $link ##phi } " and " { $link ##tagged>integer } " instructions or appends copies to the make sequence so that they are handled later by " { $link coalesce-cfg } "." } ;

HELP: coalesce-vregs
{ $values { "merged" "??" } { "follower" "vreg" } { "leader" "vreg" } }
{ $description "Sets 'leader' as the leader of 'follower'." } ;

HELP: try-eliminate-copy
{ $values { "follower" "vreg" } { "leader" "vreg" } { "must?" boolean } }
{ $description "Tries to eliminate a vreg copy from 'leader' to 'follower'. If 'must?' is " { $link t } " then a " { $link vregs-shouldn't-interfere } " error is thrown if the vregs interfere." }
{ $see-also try-eliminate-copies vregs-interfere? } ;

HELP: try-eliminate-copies
{ $values { "pairs" "a sequence of vreg pairs" } { "must?" boolean } }
{ $description "Tries to eliminate the vreg copies in the " { $link sequence } " 'pairs'. If 'must?' is " { $link t } " then a " { $link vregs-shouldn't-interfere } " error is thrown if any of the vregs interfere." }
{ $see-also try-eliminate-copy } ;

ARTICLE: "compiler.cfg.ssa.destruction.coalescing" "Vreg Coalescing"
"This compiler pass eliminates redundant vreg copies."
$nl
"Main entry point:"
{ $subsections coalesce-cfg }
"Vreg copy elimination:"
{ $subsections
  try-eliminate-copies
  try-eliminate-copy
} ;

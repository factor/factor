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

HELP: coalesce-now
{ $values { "insn" insn } }
{ $description "Generic word which finds copy pairs in instructions and tries to eliminate them directly." }
{ $see-also coalesce-later } ;

HELP: coalesce-later
{ $values { "insn" insn } }
{ $description "Generic word supposed to be called in a " { $link make } " context which generates a list of eliminatable vreg copies. The copies are batched up and then eliminated by " { $link try-eliminate-copies } "." } ;

HELP: coalesce-vregs
{ $values { "merged" "??" } { "follower" "vreg" } { "leader" "vreg" } }
{ $description "Sets 'leader' as the leader of 'follower'." } ;

HELP: eliminatable-copy?
{ $values { "vreg1" "vreg" } { "vreg2" "vreg" } { "?" boolean } }
{ $description "Determines if a vreg copy can be eliminated. It can be eliminated if the vregs have the same register class and same representation size." } ;

HELP: try-eliminate-copy
{ $values { "follower" "vreg" } { "leader" "vreg" } { "must?" boolean } }
{ $description "Tries to eliminate a vreg copy from 'leader' to 'follower'. If 'must?' is " { $link t } " then a " { $link vregs-shouldn't-interfere } " error is thrown if the vregs interfere." }
{ $see-also try-eliminate-copies vregs-interfere? } ;

HELP: try-eliminate-copies
{ $values { "pairs" "a sequence of vreg pairs" } { "must?" boolean } }
{ $description "Tries to eliminate the vreg copies in the " { $link sequence } " 'pairs'. If 'must?' is " { $link t } " then a " { $link vregs-shouldn't-interfere } " error is thrown if any of the vregs interfere." }
{ $see-also try-eliminate-copy } ;

ARTICLE: "compiler.cfg.ssa.destruction.coalescing" "Vreg Coalescing"
"This compiler pass eliminates redundant vreg copies. Coalescing occurs in two steps. First all redundant copies in all " { $link ##tagged>integer } " and " { $link ##phi } " instructions are handled. Then those in other instructions like " { $link vreg-insn } ", " { $link ##copy } " and " { $link ##parallel-copy } "."
$nl
"Main entry point:"
{ $subsections coalesce-cfg }
"Vreg copy elimination:"
{ $subsections
  try-eliminate-copies
  try-eliminate-copy
} ;

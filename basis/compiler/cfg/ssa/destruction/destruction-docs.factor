USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.ssa.destruction.private compiler.cfg.ssa.interference help.markup
help.syntax kernel sequences ;
IN: compiler.cfg.ssa.destruction

HELP: class-element-map
{ $var-description "Maps leaders to equivalence class elements which are sequences of " { $link vreg-info } " instances." } ;

HELP: cleanup-cfg
{ $values { "cfg" cfg } }
{ $description "In this step, " { $link ##parallel-copy } " instructions are substituted with more concreete " { $link ##copy } " instructions. " { $link ##phi } " instructions are removed here." } ;

HELP: coalesce-elements
{ $values { "merged" "??" } { "follower" "vreg" } { "leader" "vreg" } }
{ $description "Delete follower's class, and set leaders's class to merged." } ;

HELP: coalesce-vregs
{ $values { "merged" "??" } { "follower" "vreg" } { "leader" "vreg" } }
{ $description "Sets 'leader' as the leader of 'follower'." } ;

HELP: copies
{ $var-description "Sequence of copies (tuples of { vreg-dst vreg-src}) that maybe can be eliminated later." }
{ $see-also init-coalescing } ;

HELP: try-eliminate-copy
{ $values { "follower" "vreg" } { "leader" "vreg" } { "must?" boolean } }
{ $description "Tries to eliminate a vreg copy from 'leader' to 'follower'. If 'must?' is " { $link t } " then a " { $link vregs-shouldn't-interfere } " error is thrown if the vregs interfere." }
{ $see-also try-eliminate-copies vregs-interfere? } ;

HELP: try-eliminate-copies
{ $values { "pairs" "a sequence of vreg pairs" } { "must?" boolean } }
{ $description "Tries to eliminate the vreg copies in the " { $link sequence } " 'pairs'. If 'must?' is " { $link t } " then a " { $link vregs-shouldn't-interfere } " error is thrown if any of the vregs interfere. To ensure deterministic " { $link leader-map } " data, the pairs are sorted." }
{ $see-also try-eliminate-copy } ;

ARTICLE: "compiler.cfg.ssa.destruction" "SSA Destruction"
"Because of the design of the register allocator, this pass has three peculiar properties."
{ $list
  "Instead of renaming vreg usages in the CFG, a map from vregs to canonical representatives is computed. This allows the register allocator to use the original SSA names to get reaching definitions."
  { "Useless " { $link ##copy } " instructions, and all " { $link ##phi } " instructions, are eliminated, so the register allocator does not have to remove any redundant operations." }
  { "This pass computes live sets and fills out the " { $slot "gc-roots" } " slots of GC maps with " { $vocab-link "compiler.cfg.liveness" } ", so the linear scan register allocator does not need to compute liveness again." }
}
$nl
"Main entry point:"
{ $subsections destruct-ssa } ;

ABOUT: "compiler.cfg.ssa.destruction"

USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.ssa.destruction.private help.markup help.syntax ;
IN: compiler.cfg.ssa.destruction

HELP: class-element-map
{ $var-description "Maps leaders to equivalence class elements." } ;

HELP: cleanup-cfg
{ $values { "cfg" cfg } }
{ $description "In this step, " { $link ##parallel-copy } " instructions are substituted with more concreete " { $link ##copy } " instructions. " { $link ##phi } " instructions are removed here." } ;

HELP: copies
{ $var-description "Sequence of copies (tuples of { vreg-dst vreg-src}) that maybe can be eliminated later." }
{ $see-also init-coalescing } ;

HELP: maybe-eliminate-copy
{ $values { "vreg1" "vreg" } { "vreg2" "vreg" } }
{ $description "Eliminate a copy if possible." }
{ $see-also must-eliminate-copy } ;

HELP: must-eliminate-copy
{ $values { "vreg1" "vreg" } { "vreg2" "vreg" } }
{ $description "Eliminates a copy." }
{ $see-also maybe-eliminate-copy } ;

ARTICLE: "compiler.cfg.ssa.destruction" "SSA Destruction"
"Because of the design of the register allocator, this pass has three peculiar properties."
{ $list
  "Instead of renaming vreg usages in the CFG, a map from vregs to canonical representatives is computed. This allows the register allocator to use the original SSA names to get reaching definitions."
  { "Useless " { $link ##copy } " instructions, and all " { $link ##phi } " instructions, are eliminated, so the register allocator does not have to remove any redundant operations." }
  { "This pass computes live sets and fills out the " { $slot "gc-roots" } " slots of GC maps with " { $vocab-link "compiler.cfg.liveness" } ", so the linear scan register allocator does not need to compute liveness again." }
} ;

ABOUT: "compiler.cfg.ssa.destruction"

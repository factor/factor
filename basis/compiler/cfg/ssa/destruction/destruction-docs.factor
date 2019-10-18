USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.ssa.destruction.private compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.interference help.markup help.syntax kernel sequences ;
IN: compiler.cfg.ssa.destruction

HELP: cleanup-cfg
{ $values { "cfg" cfg } }
{ $description "In this pass, useless copies are eliminated. " { $link ##phi } " instructions are removed and " { $link ##parallel-copy } " are transformed into regular " { $link ##copy } " instructions. Then for the copy instructions, which are ##copy and " { $link ##tagged>integer } " it is checked to see if the copy is useful. If it is not, the instruction is removed from the cfg." } ;

HELP: destruct-ssa
{ $values { "cfg" cfg } }
{ $description "Main entry point for the SSA destruction compiler pass." } ;

ARTICLE: "compiler.cfg.ssa.destruction" "SSA Destruction"
"SSA destruction compiler pass. It is preceded by " { $vocab-link "compiler.cfg.save-contexts" } " and followed by " { $vocab-link "compiler.cfg.linear-scan" } "."
$nl
"Because of the design of the register allocator, this pass has three peculiar properties."
{ $list
  { "Instead of renaming vreg usages in the CFG, a map from vregs to canonical representatives is computed. This allows the register allocator to use the original SSA names to get reaching definitions. See " { $link leader-map } "." }
  { "Useless " { $link ##copy } " instructions, and all " { $link ##phi } " instructions, are eliminated, so the register allocator does not have to remove any redundant operations." }
  { "This pass computes live sets and fills out the " { $slot "gc-roots" } " slots of GC maps with " { $vocab-link "compiler.cfg.liveness" } ", so the linear scan register allocator does not need to compute liveness again." }
}
$nl
"Main entry point:"
{ $subsections destruct-ssa } ;

ABOUT: "compiler.cfg.ssa.destruction"

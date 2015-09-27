USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.ssa.construction.private help.markup help.syntax ;
IN: compiler.cfg.ssa.construction

HELP: <##phi>
{ $values { "vreg" "vreg" } { "bb" basic-block } { "##phi" ##phi } }
{ $description "Creates a new " { $link ##phi } " instruction given a vreg and a basic block." } ;

HELP: phis
{ $var-description "Maps vregs to " { $link ##phi } " instructions." } ;

HELP: used-vregs
{ $var-description "Worklist of used vregs, to calculate used phis." } ;

HELP: defs
{ $var-description "Maps vregs to sets of basic blocks." } ;

HELP: defs-multi
{ $var-description "Set of vregs defined in more than one basic block." } ;

HELP: inserting-phis
{ $var-description "Maps basic blocks to sequences of " { $link ##phi } " instructions." } ;

HELP: pushed
{ $var-description "Maps vregs to renaming stacks." } ;

HELP: stacks
{ $var-description "Maps vregs to renaming stacks." } ;

ARTICLE: "compiler.cfg.ssa.construction" "SSA construction"
"Iterated dominance frontiers are computed using the DJ Graph method in " { $vocab-link "compiler.cfg.ssa.construction.tdmsc" } "."
$nl
"The renaming algorithm is based on \"Practical Improvements to the Construction and Destruction of Static Single Assignment Form\"."
$nl
"We construct pruned SSA without computing live sets, by building a dependency graph for phi instructions, marking the transitive closure of a vertex as live if it is referenced by some non-phi instruction. Thanks to Cameron Zwarich for the trick."
$nl
"http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.49.9683" ;

ABOUT: "compiler.cfg.ssa.construction"

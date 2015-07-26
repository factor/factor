USING: compiler.cfg.ssa.destruction.coalescing help.markup help.syntax math ;
IN: compiler.cfg.ssa.destruction.leaders

HELP: ?leader
{ $values { "vreg" "vreg" } { "vreg'" "vreg" } }
{ $description "The leader of the vreg or the register itself if it has no other leader." } ;

HELP: leader-map
{ $var-description "A map from vregs to canonical representatives due to coalescing done by SSA destruction. Used by liveness analysis and the register allocator, so we can use the original SSA names to get certain info (reaching definitions, representations). By default, each vreg is its own leader. The data is computed in the " { $vocab-link "compiler.cfg.ssa.destruction" } " compiler pass." }
{ $see-also init-coalescing } ;

ARTICLE: "compiler.cfg.ssa.destruction.leaders" "Leader book-keeping" "This vocab defines words for getting the leaders of vregs." ;

ABOUT: "compiler.cfg.ssa.destruction.leaders"

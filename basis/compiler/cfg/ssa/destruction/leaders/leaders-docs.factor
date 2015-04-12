USING: help.markup help.syntax math ;
IN: compiler.cfg.ssa.destruction.leaders

HELP: leader-map
{ $var-description "A map from vregs to canonical representatives due to coalescing done by SSA destruction. Used by liveness analysis and the register allocator, so we can use the original SSA names to get certain info (reaching definitions, representations)." } ;

ARTICLE: "compiler.cfg.ssa.destruction.leaders" "Leader book-keeping" "This vocab defines words for getting the leaders of vregs." ;

ABOUT: "compiler.cfg.ssa.destruction.leaders"

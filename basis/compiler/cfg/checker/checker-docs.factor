USING: compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.checker

HELP: check-ssa?
{ $var-description "Enables SSA verification after SSA construction, alias analysis, value numbering, copy propagation and dead-code elimination. Failures identify the compiled word and the pass that produced the invalid graph. Disabled by default." } ;

HELP: check-ssa
{ $values { "cfg" cfg } }
{ $description "Checks predecessor caches, phi placement and incoming edges, unique definitions, and dominance of ordinary and phi-edge uses. Expected edges are derived independently before any predecessor repair. Analysis caches created by the checker do not escape its scope." } ;

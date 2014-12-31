USING: assocs compiler.cfg compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.parallel-copy.private help.markup help.syntax math sequences ;
IN: compiler.cfg.parallel-copy

HELP: process-to-do
{ $description "Note that we check if b = loc(b), not b = loc(pred(b)) as the paper suggests. Confirmed by one of the authors at http://www.reddit.com/comments/93253/some_lecture_notes_on_ssa_form/c0bco4f" } ;

HELP: parallel-copy
{ $values { "mapping" { $link assoc } " of { dst src } virtual register pairs" } }
{ $description "Creates " { $link ##copy } " instructions." } ;

HELP: parallel-copy-rep
{ $values { "mapping" { $link assoc } " of { dst src } virtual register pairs" } }
{ $description "Creates " { $link ##copy } " instructions." } ;

ARTICLE: "compiler.cfg.parallel-copy" "Parallel copy"
"Revisiting Out-of-SSA Translation for Correctness, Code Quality, and Efficiency http://hal.archives-ouvertes.fr/docs/00/34/99/25/PDF/OutSSA-RR.pdf, Algorithm 1" ;

ABOUT: "compiler.cfg.parallel-copy"

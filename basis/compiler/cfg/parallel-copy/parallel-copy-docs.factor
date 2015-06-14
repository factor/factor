USING: assocs arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.parallel-copy.private compiler.cfg.registers
help.markup help.syntax kernel math quotations sequences ;
IN: compiler.cfg.parallel-copy

HELP: process-to-do
{ $values { "b" object } { "temp" quotation } { "quot" quotation } }
{ $description "Note that we check if b = loc(b), not b = loc(pred(b)) as the paper suggests. Confirmed by one of the authors at http://www.reddit.com/comments/93253/some_lecture_notes_on_ssa_form/c0bco4f" } ;

HELP: parallel-copy
{ $values { "mapping" { $link assoc } " of { dst src } virtual register pairs" } { "insns" array } }
{ $description "Creates " { $link ##copy } " instructions." } ;

HELP: parallel-copy-rep
{ $values { "mapping" { $link assoc } " of { dst src } virtual register pairs" } { "insns" array } }
{ $description "Creates " { $link ##copy } " instructions. Representation selection must have been run previously." } ;

ARTICLE: "compiler.cfg.parallel-copy" "Parallel copy"
"Revisiting Out-of-SSA Translation for Correctness, Code Quality, and Efficiency http://hal.archives-ouvertes.fr/docs/00/34/99/25/PDF/OutSSA-RR.pdf, Algorithm 1"
$nl
"Generating " { $link ##copy } " instructions:"
{ $subsections parallel-copy parallel-copy-rep } ;

ABOUT: "compiler.cfg.parallel-copy"

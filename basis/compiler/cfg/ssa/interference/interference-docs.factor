USING: compiler.cfg help.markup help.syntax kernel sequences ;
IN: compiler.cfg.ssa.interference

HELP: sets-interfere?
{ $values { "seq1" sequence } { "seq2" sequence } { "merged/f" object } { "?" boolean } }
{ $description "Checks if two sets consisting of " { $link vreg-info } " instances interfere with each other. If they interfere, then copies can not be eliminated." } ;

HELP: vreg-info
{ $class-description
  "Slots:"
  { $slots
    { "vreg" { "The vreg the vreg-info is the info for." } }
    { "bb" { "The " { $link basic-block } " in which the vreg is defined." } }
  }
} ;


ARTICLE: "compiler.cfg.ssa.interference" "Interference testing using SSA properties."
"Interference testing using SSA properties"
$nl
"Based on:"
$nl
"Revisiting Out-of-SSA Translation for Correctness, Code Quality, and Efficiency http://hal.archives-ouvertes.fr/docs/00/34/99/25/PDF/OutSSA-RR.pdf" ;

ABOUT: "compiler.cfg.ssa.interference"

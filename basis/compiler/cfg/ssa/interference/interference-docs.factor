USING: help.markup help.syntax ;
IN: compiler.cfg.ssa.interference

HELP: vreg-info
{ $class-description
  "Slots:"
  { $table
    { { $slot "vreg" } { "The vreg the vreg-info is the info for." } }
  }
} ;


ARTICLE: "compiler.cfg.ssa.interference" "Interference testing using SSA properties."
"Interference testing using SSA properties"
$nl
"Based on:"
$nl
"Revisiting Out-of-SSA Translation for Correctness, Code Quality, and Efficiency http://hal.archives-ouvertes.fr/docs/00/34/99/25/PDF/OutSSA-RR.pdf" ;

ABOUT: "compiler.cfg.ssa.interference"

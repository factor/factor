USING: compiler.cfg.stacks.local help.markup help.syntax math sequences ;
IN: compiler.cfg.stacks

HELP: begin-stack-analysis
{ $description "Initializes a set of variables related to stack analysis of Factor words." }
{ $see-also current-height } ;

HELP: adjust-d
{ $values { "n" number } }
{ $description "Changes the height of the current data stack." } ;

HELP: rs-store
{ $values { "vregs" "a " { $link sequence } " of vregs." } }
{ $description "Stores one or more virtual register values on the retain stack. This modifies the " { $link current-height } " dynamic variable." } ;

HELP: 2inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } }
{ $description "Lifts the two topmost values from the datastack and stores them in virtual registers. The datastacks height is adjusted afterwards." } ;

HELP: 3inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } { "vreg2" "a vreg" } }
{ $description "Lifts the three topmost values from the datastack and stores them in virtual registers. The datastacks height is adjusted afterwards." } ;

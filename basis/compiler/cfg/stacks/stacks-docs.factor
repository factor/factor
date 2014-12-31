USING: compiler.cfg.stacks.local compiler.tree help.markup help.syntax math
sequences ;
IN: compiler.cfg.stacks

HELP: ds-push
{ $values { "vreg" "a virtual register" } }
{ $description "Used when translating the " { $link #push } " SSA node to CFG form for pushing a literal value onto the data stack." } ;

HELP: begin-stack-analysis
{ $description "Initializes a set of variables related to stack analysis of Factor words." }
{ $see-also current-height } ;

HELP: end-stack-analysis
{ $description "Ends the stack analysis of the current cfg." } ;

HELP: adjust-d
{ $values { "n" number } }
{ $description "Changes the height of the current data stack." } ;

HELP: ds-drop
{ $description "Used to signal to the stack analysis that the datastacks height is decreased by one." } ;

HELP: ds-store
{ $values { "vreg" "a " { $link sequence } " of vregs." } }
{ $description "Registers that a sequence of vregs are stored at at each corresponding index of the data stack." } ;

HELP: rs-store
{ $values { "vregs" "a " { $link sequence } " of vregs." } }
{ $description "Stores one or more virtual register values on the retain stack. This modifies the " { $link current-height } " dynamic variable." } ;

HELP: 2inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } }
{ $description "Lifts the two topmost values from the datastack and stores them in virtual registers. The datastacks height is adjusted afterwards." } ;

HELP: 3inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } { "vreg3" "a vreg" } }
{ $description "Lifts the three topmost values from the datastack and stores them in virtual registers. The datastacks height is adjusted afterwards." } ;

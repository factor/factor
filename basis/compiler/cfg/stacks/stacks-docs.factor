USING: compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks.local compiler.tree help.markup help.syntax math
sequences ;
IN: compiler.cfg.stacks

HELP: ds-push
{ $values { "vreg" "a virtual register" } }
{ $description "Used when translating the " { $link #push } " SSA node to CFG form for pushing a literal value onto the data stack." } ;

HELP: begin-stack-analysis
{ $description "Initializes a set of variables related to stack analysis of Factor words." }
{ $see-also height-state } ;

HELP: end-stack-analysis
{ $description "Ends the stack analysis of the current cfg." } ;

HELP: adjust-d
{ $values { "n" number } }
{ $description "Changes the height of the current data stack. This word is called when other instructions which internally adjust the stack height are emitted, such as " { $link ##call } " and " { $link ##alien-invoke } "." } ;

HELP: ds-drop
{ $description "Used to signal to the stack analysis that the datastacks height is decreased by one." } ;

HELP: store-vregs
{ $values
  { "vregs" "a " { $link sequence } " of vregs" }
  { "loc-class" "either " { $link ds-loc } " or " { $link rs-loc } }
}
{ $description "Stores one or more virtual register values on the data or retain stack. The " { $link replace-mapping } " dynamic variable is modified but the " { $link height-state } " is not touched" } ;

HELP: 2inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } }
{ $description "Lifts the two topmost values from the datastack and stores them in virtual registers. The datastacks height is adjusted afterwards." } ;

HELP: 3inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } { "vreg3" "a vreg" } }
{ $description "Lifts the three topmost values from the datastack and stores them in virtual registers. The datastacks height is adjusted afterwards." } ;

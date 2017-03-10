USING: compiler.cfg compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks.local compiler.tree help.markup help.syntax math
sequences ;
IN: compiler.cfg.stacks

HELP: ds-push
{ $values { "vreg" "a virtual register" } }
{ $description "Used when translating the " { $link #push } " SSA node to CFG form. The node pushes a literal value onto the data stack." } ;

HELP: begin-stack-analysis
{ $description "Initializes a set of variables related to global stack analysis of Factor words." }
{ $see-also begin-local-analysis height-state } ;

HELP: end-stack-analysis
{ $values { "cfg" cfg } }
{ $description "Ends the stack analysis of the current cfg. This is the last step of the cfg construction (but comes before all optimization passes)." } ;

HELP: ds-drop
{ $description "Used to signal to the stack analysis that the datastacks height is decreased by one." } ;

HELP: store-vregs
{ $values
  { "vregs" "a " { $link sequence } " of vregs" }
  { "loc-class" "either " { $link ds-loc } " or " { $link rs-loc } }
}
{ $description "Stores one or more virtual register values on the data or retain stack. The " { $link replaces } " dynamic variable is modified but the " { $link height-state } " is not touched" } ;

HELP: 2inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } }
{ $description "Lifts the two topmost values from the datastack and stores them in virtual registers. The datastacks height is decremented by 2." } ;

HELP: 3inputs
{ $values { "vreg1" "a vreg" } { "vreg2" "a vreg" } { "vreg3" "a vreg" } }
{ $description "Lifts the three topmost values from the datastack and stores them in virtual registers. The datastacks height is decremented by 3." } ;

ARTICLE: "compiler.cfg.stacks" "Generating instructions for accessing the data and retain stacks" "This vocab contains utility words for manipulating the analysis data and retain stacks."
$nl
"When nodes in the dataflow IR pushes or pops items from the stacks, instructions for performing those actions aren't immediately emitted. Instead the analysis stacks are manipulated and when the stack analysis phase is complete, optimal stack shuffling code is emitted. This way, exactly the same instructions are emitted for equivalent quotations such as [ dup drop ] and [ ]."
$nl
"Popping from the datastack:"
{ $subsections 2inputs 3inputs ds-drop }
"Pushing to the datastack:"
{ $subsections ds-push store-vregs } ;

ABOUT: "compiler.cfg.stacks"

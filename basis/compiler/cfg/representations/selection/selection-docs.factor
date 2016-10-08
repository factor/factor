USING: help.markup help.syntax math sequences ;
IN: compiler.cfg.representations.selection

HELP: costs
{ $var-description "Maps vreg to representation to cost. The costs for each vreg is represented as a hashtable where the keys are representation singletons and the values the costs of using that representation." } ;

HELP: increase-cost
{ $values { "rep" "representation symbol" } { "scc" "?" } { "factor" integer } }
{ $description "Increase cost of keeping vreg in rep, making a choice of rep less likely. If the rep is not in the cost alist, it means this representation is prohibited." } ;

HELP: inert-tag-untag-insn
{ $class-description "Class of instructions that are binary and inert with respect to tagging. Those instructions often doesn't need untagging and retagging because the operations can be performed on their tagged representations." } ;

HELP: init-costs
{ $description "Initialize cost as 0 for each possibility." } ;

HELP: minimize-costs
{ $values { "costs" sequence } { "representations" sequence } }
{ $description "For every vreg, compute preferred representation, that minimizes costs." } ;

HELP: possibilities
{ $var-description "Hashtable mapping vregs to to their possible representations." } ;

HELP: tagged-vregs
{ $var-description "Vregs which must be tagged at the definition site because there is at least one usage that is not int-rep. If all usages are int-rep it is safe to untag at the definition site." } ;

ARTICLE: "compiler.cfg.representations.selection" "Assign representations to vregs"
"This is the second last step in the representation selection compiler pass. Each vreg is assigned a machine representation which is any of the representations in the " { $vocab-link "cpu.architecture" } ;

ABOUT: "compiler.cfg.representations.selection"

USING: help.markup help.syntax math sequences ;
IN: compiler.cfg.representations.selection

HELP: costs
{ $var-description "Maps vreg to representation to cost." } ;

HELP: increase-cost
{ $values { "rep" "representation symbol" } { "scc" "?" } { "factor" integer } }
{ $description "Increase cost of keeping vreg in rep, making a choice of rep less likely. If the rep is not in the cost alist, it means this representation is prohibited." } ;

HELP: init-costs
{ $description "Initialize cost as 0 for each possibility." } ;

HELP: minimize-costs
{ $values { "costs" sequence } { "representations" sequence } }
{ $description "For every vreg, compute preferred representation, that minimizes costs." } ;

HELP: tagged-vregs
{ $var-description "Vregs which must be tagged at the definition site because there is at least one usage that is not int-rep. If all usages are int-rep it is safe to untag at the definition site." } ;

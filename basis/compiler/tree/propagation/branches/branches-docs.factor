USING: compiler.tree help.markup help.syntax sequences ;
IN: compiler.tree.propagation.branches

HELP: child-constraints
{ $values { "node" node } { "seq" sequence } }
{ $description "For conditionals, an assoc of child node # --> constraint." } ;

HELP: condition-value
{ $var-description "When propagating an " { $link #if } " node, this variable holds the value that is being dispatched on." } ;

HELP: live-branches
{ $values { "#branch" #branch } { "indices" sequence } }
{ $description "Outputs a sequence of true and false values indicating which of the branches that are possibly live." } ;

ARTICLE: "compiler.tree.propagation.branches" "Sparse propagation for branches"
"Sparse propagation for branches" ;

ABOUT: "compiler.tree.propagation.branches"

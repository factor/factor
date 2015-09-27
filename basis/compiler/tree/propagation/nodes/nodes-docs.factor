USING: assocs compiler.tree help.markup help.syntax sequences ;
IN: compiler.tree.propagation.nodes

HELP: annotate-node
{ $values { "node" node } }
{ $description "Initializes the info slot for SSA tree nodes that have it." } ;

HELP: extract-value-info
{ $values { "values" sequence } { "assoc" assoc } }
{ $description "Creates an assoc mapping values to infos for the 'values'." } ;

HELP: propagate-around
{ $values { "node" node } }
{ $description "Performs value propagation for an SSA node." } ;

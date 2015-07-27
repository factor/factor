USING: compiler.tree help.markup help.syntax ;
IN: compiler.tree.propagation.nodes

HELP: annotate-node
{ $values { "node" node } }
{ $description "Initializes the info slot for SSA tree nodes that have it." } ;

HELP: propagate-around
{ $values { "node" node } }
{ $description "Performs value propagation for an SSA node." } ;

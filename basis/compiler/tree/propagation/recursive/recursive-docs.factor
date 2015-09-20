USING: compiler.tree compiler.tree.propagation.info
compiler.tree.propagation.nodes help.markup help.syntax sequences ;
IN: compiler.tree.propagation.recursive

HELP: recursive-phi-infos
{ $values { "node" #recursive } { "infos" sequence } }
{ $description "The sequence of " { $link value-info-state } " that is the input to the recursive block." } ;

ARTICLE: "compiler.tree.propagation.recursive" "Propagation for inline recursive combinators"
"This vocab implements the " { $link propagate-before } ", " { $link annotate-node } " and " { $link propagate-around } " words for recursive tree nodes." ;

ABOUT: "compiler.tree.propagation.recursive"

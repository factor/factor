USING: classes compiler.tree compiler.tree.propagation.info
compiler.tree.propagation.nodes help.markup help.syntax math.intervals
sequences ;
IN: compiler.tree.propagation.recursive

HELP: counter-class
{ $values { "interval" interval } { "class" class } { "class'" class } }
{ $description "The smallest class to use for a counter that iterates the given interval." } ;

HELP: recursive-phi-infos
{ $values { "node" #recursive } { "infos" sequence } }
{ $description "The sequence of " { $link value-info-state } " that is the input to the recursive block." } ;

ARTICLE: "compiler.tree.propagation.recursive" "Propagation for inline recursive combinators"
"This vocab implements the " { $link propagate-before } ", " { $link annotate-node } " and " { $link propagate-around } " words for recursive tree nodes." ;

ABOUT: "compiler.tree.propagation.recursive"

USING: assocs help.markup help.syntax kernel sequences stack-checker.alien
stack-checker.visitor ;
IN: compiler.tree

HELP: #alien-node
{ $class-description "Base class for alien nodes. Its " { $snippet "params" } " slot holds an instance of the " { $link alien-node-params } " class." } ;

HELP: #alien-invoke
{ $class-description "SSA tree node that calls a function in a dynamically linked library." } ;

HELP: #call
{ $class-description "SSA tree node that calls a word." } ;

HELP: #introduce
{ $class-description "SSA tree node that puts an input value from the \"outside\" on the stack." } ;

HELP: #push
{ $class-description "SSA tree node that puts a literal value on the stack." }
{ $notes "A quotation is also a literal." } ;

HELP: #shuffle
{ $class-description "SSA tree node that represents a stack shuffling operation such as " { $link swap } ". It has the following slots:"
  { $table
    { { $slot "mapping" } { "An " { $link assoc } " that shows how the shuffle output values (the keys) correspond to their inputs (the values)." } }
  }
} ;

HELP: node,
{ $values { "node" node } }
{ $description "Emits a node to the " { $link stack-visitor } " variable." } ;

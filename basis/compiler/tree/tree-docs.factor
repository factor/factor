USING: assocs help.markup help.syntax kernel sequences stack-checker.visitor
words ;
IN: compiler.tree

HELP: node
{ $class-description "Base class for all SSA tree nodes." } ;

HELP: #call
{ $class-description "SSA tree node that calls a word. It has the following slots:"
  { $table
    { { $slot "word" } { "The " { $link word } " to call." } }
    { { $slot "in-d" } { "Sequence of input variables to the call. The items are ordered from top to bottom of the stack." } }
    { { $slot "out-d" } { "Output values of the call." } }
    { { $slot "info" } { "An assoc that contains various annotations for the words input and output values. It is set during the propagation pass of the optimizer." } }
  }
} ;

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

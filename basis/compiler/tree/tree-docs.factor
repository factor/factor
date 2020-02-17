USING: alien assocs help.markup help.syntax kernel kernel.private
quotations sequences stack-checker.alien stack-checker.inlining
stack-checker.values stack-checker.visitor words ;
IN: compiler.tree

HELP: node
{ $class-description "Base class for all SSA tree nodes. The node is an " { $link identity-tuple } " which means that two different node instances with the same attributes are not equal." } ;

HELP: #alien-node
{ $class-description "Base class for alien nodes. Its " { $snippet "params" } " slot holds an instance of the " { $link alien-node-params } " class." } ;

HELP: #alien-invoke
{ $class-description "SSA tree node that calls a function in a dynamically linked library." }
{ $see-also alien-invoke } ;

HELP: #alien-callback
{ $class-description "SSA tree node that constructs an alien callback. It is not a subclass of " { $link #alien-node } "." } ;

HELP: #call
{ $class-description "SSA tree node that calls a word. It has the following slots:"
  { $slots
    { "word" { "The " { $link word } " to call." } }
    { "in-d" { "Sequence of input variables to the call. The items are ordered from top to bottom of the stack." } }
    { "out-d" { "Output values of the call." } }
    { "method" { "If the called word is generic and inlined here, then 'method' contains the inlined " { $link quotation } "." } }
    { "body" { "If the called word is generic and inlined, then 'body' is a sequence of SSA nodes built from the inlined method." } }
    { "info" { "If the called word is generic and inlined, then the info slot contains an assoc of value infos for the body of the inlined generic. It is set during the propagation pass of the optimizer." } }
  }
} ;

HELP: #call-recursive
{ $class-description "In a " { $link #recursive } " block of the SSA tree, this node represents a call back to the beginning of the block." }
{ $see-also #recursive } ;

HELP: #declare
{ $class-description "SSA tree node emitted when " { $link declare } " declarations are encountered. It has the following slots:"
  { $slots
    { "declaration" { { $link assoc } " that maps values to the types they are declared as." } }
  }
} ;

HELP: #enter-recursive
{ $class-description "This node works is placed first in the 'child' " { $link sequence } " for " { $link #recursive } " nodes and works like a header for it." }
{ $see-also #recursive #return-recursive } ;

HELP: #if
{ $class-description "SSA tree node that implements conditional branching. It has the following slots:"
  { $slots
    { "children"
      { "A two item " { $link sequence } ". The first item holds the instructions executed if the condition is true and the second those that are executed if it is not true." }
    }
  }
} ;

HELP: #introduce
{ $class-description "SSA tree node that puts an input value from the \"outside\" on the stack. It is used to \"introduce\" data stack parameter whenever they are needed. It has the following slots:"
  { $slots
    { "out-d" { "Array of values of the parameters being introduced." } }
  }
} ;

HELP: #phi
{ $class-description "#phi is a SSA tree node type that unifies two branches in an " { $link #if } "." } ;

HELP: #push
{ $class-description "SSA tree node that puts a literal value on the stack. It has the following slots:"
  { $slots
    { "out-d" { "A one item array containing the " { $link <value> } " of the literal being pushed." } }
  }
}
{ $notes "A " { $link quotation } " is also a literal." } ;

HELP: #recursive
{ $class-description "Instruction which encodes a loop. It has the following slots:"
  { $slots
    { "child" { "A sequence of nodes representing the body of the loop." } }
    { "loop?" { "If " { $link t } ", the recursion is implemented using a jump, otherwise as a call back to the word." } }
  }
}
{ $see-also inline-recursive-word } ;

HELP: #shuffle
{ $class-description "SSA tree node that represents a stack shuffling operation such as " { $link swap } ". It has the following slots:"
  { $slots
    { "mapping" { "An " { $link assoc } " that shows how the shuffle output values (the keys) correspond to their inputs (the values)." } }
  }
} ;

HELP: node,
{ $values { "node" node } }
{ $description "Emits a node to the " { $link stack-visitor } " variable." } ;

ARTICLE: "compiler.tree" "High-level optimizer operating on lexical tree SSA IR"
"Node types:"
{ $subsections
  #call
  #declare
  #shuffle
}
"Nodes for control flow:"
{ $subsections
  #call-recursive
  #enter-recursive
  #recursive
  #return-recursive
  #terminate
}
"Nodes for alien ffi:"
{ $subsections
  #alien-node
  #alien-invoke
  #alien-indirect
  #alien-assembly
  #alien-callback
}
"Nodes for branching:"
{ $subsections
  #dispatch
  #if
  #phi
} ;

ABOUT: "compiler.tree"

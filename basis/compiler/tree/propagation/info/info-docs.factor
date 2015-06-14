USING: compiler.tree help.markup help.syntax sequences ;
IN: compiler.tree.propagation.info

HELP: node-input-infos
{ $values { "node" node } { "seq" sequence } }
{ $description "Lists the value infos for the input variables of an SSA tree node." } ;

HELP: node-output-infos
{ $values { "node" node } { "seq" sequence } }
{ $description "Lists the value infos for the output variables of an SSA tree node." } ;

HELP: value-info-state
{ $class-description "Represents constraints the compiler knows about the input and output variables to an SSA tree node. It has the following slots:"
  { $table
    { { $slot "class" } { "Class of values the variable can take." } }
    { { $slot "interval" } { "Range of values the variable can take." } }
    { { $slot "literal" } { "Literal value, if present." } }
    { { $slot "literal?" } { "Whether the value of the variable is known at compile-time or not." } }
    { { $slot "slots" } { "If the value is a literal tuple or fixed length type, then slots is a " { $link sequence } " of " { $link value-info-state } " encoding what is known about its slots at compile-time." } }
  }
} ;

HELP: value-infos
{ $var-description "Assoc stack of current value --> info mapping" } ;

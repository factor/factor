USING: classes compiler.tree help.markup help.syntax kernel math math.intervals
sequences ;
IN: compiler.tree.propagation.info

HELP: interval>literal
{ $values
  { "class" class }
  { "interval" interval }
  { "literal" "a literal value" }
  { "literal?" boolean }
}
{ $description "If interval has zero length and the class is sufficiently precise, we can turn it into a literal." } ;

HELP: literal-class
{ $values { "obj" object } { "class" class } }
{ $description "Handle forgotten tuples and singleton classes properly." } ;

HELP: node-input-infos
{ $values { "node" node } { "seq" sequence } }
{ $description "Lists the value infos for the input variables of an SSA tree node. For " { $link #call } " nodes, the inputs represents the values on the stack when the word is called." } ;

HELP: node-output-infos
{ $values { "node" node } { "seq" sequence } }
{ $description "Lists the value infos for the output variables of an SSA tree node." } ;

HELP: value-info
{ $values { "value" integer } { "info" value-info-state } }
{ $description "Gets the value info for the given SSA value. If none is found then a null empty interval is returned." } ;

HELP: value-info<=
{ $values { "info1" value-info-state } { "info2" value-info-state } { "?" boolean } }
{ $description "Checks if the first value info is equal to, or smaller than the second one." } ;

HELP: value-info-state
{ $class-description "Represents constraints the compiler knows about the input and output variables to an SSA tree node. It has the following slots:"
  { $slots
    { "class" { "Class of values the variable can take." } }
    { "interval" { "Range of values the variable can take." } }
    { "literal" { "Literal value, if present." } }
    { "literal?" { "Whether the value of the variable is known at compile-time or not." } }
    { "slots" { "If the value is a literal tuple or fixed length type, then slots is a " { $link sequence } " of " { $link value-info-state } " encoding what is known about its slots at compile-time." } }
  }
  "Don't mutate value infos you receive, always construct new ones. We don't declare the slots read-only to allow cloning followed by writing, and to simplify constructors."
} ;

HELP: value-infos
{ $var-description "Assoc stack of current value --> info mapping" } ;

HELP: wrap-interval
{ $values { "interval" interval } { "class" class } { "interval'" interval } }
{ $description "Wraps an interval to the given numeric types interval." } ;

ARTICLE: "compiler.tree.propagation.info" "Value info data type and operations"
"Querying words:"
{ $subsections
  node-input-infos
  node-output-infos
  value-info
}
"Value info operations:"
{ $subsections
  value-info<=
  value-info-union
  value-infos-union
} ;

ABOUT: "compiler.tree.propagation.info"

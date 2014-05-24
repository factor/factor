USING: classes compiler.tree.propagation.info help.markup
help.syntax kernel math math.intervals ;
IN: compiler.tree.propagation.known-words

HELP: binary-op-class
{ $values { "info1" value-info-state } { "info2" value-info-state } { "newclass" class } }
{ $description "Given two value infos return the math class which is large enough for both of them." }
{ $examples
  { $example
    "USING: compiler.tree.propagation.known-words compiler.tree.propagation.info"
    "kernel math prettyprint ;"
    "bignum real [ <class-info> ] bi@ binary-op-class ."
    "real"
  }
} ;

HELP: unary-op-class
{ $values { "info" value-info-state } { "newclass" class } }
{ $description "Returns the smallest math class large enough to hold values of the value infos class." }
{ $see-also binary-op-class } ;

HELP: number-valued
{ $values
  { "class" class } { "interval" interval }
  { "class'" class } { "interval'" interval }
}
{ $description "Ensure that the class is a subclass of " { $link number } "." } ;

HELP: fits-in-fixnum?
{ $values { "interval" interval } { "?" boolean } }
{ $description "Checks if the interval is a subset of the " { $link fixnum } " interval. Used to see if arithmetic may overflow." }
{ $examples
  { $example
    "USING: compiler.tree.propagation.known-words math.intervals prettyprint ;"
    "full-interval fits-in-fixnum? ."
    "f"
  }
} ;

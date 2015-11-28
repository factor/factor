USING: classes classes.builtin compiler.tree
compiler.tree.propagation.info help.markup help.syntax layouts math
slots.private ;
IN: compiler.cfg.intrinsics.slots

HELP: class-tag
{ $values { "class" class } { "tag/f" "a number or f" } }
{ $description "Finds the class number for this class if it is a subclass of a builtin class, or " { $link f } " if it isn't." }
{ $examples
  { $example
    "USING: compiler.cfg.intrinsics.slots math prettyprint ;"
    "complex class-tag ."
    "7"
  }
} ;

HELP: immediate-slot-offset?
{ $values { "value-info" value-info-state } { "?" "true or false" } }
{ $description
  { $link t } " if the value info is a literal " { $link fixnum } " that is small enough to fit into a machine register." }
{ $examples
  { $example
    "USING: compiler.cfg.intrinsics.slots compiler.tree.propagation.info prettyprint ;"
    "33 <literal-info> immediate-slot-offset? ."
    "t"
  }
} ;

HELP: node>set-slot-data
{ $values
  { "#call" #call }
  { "write-barrier?" "whether a write barrier is needed, it always is unless the item to set is an " { $link immediate } }
  { "tag" "a number or f" }
  { "literal" "a literal" }
} { $description "Grabs the data needed from a call node to determine what intrinsic CFG instructions to emit for the " { $link set-slot } " call." } ;

HELP: value-tag
{ $values { "info" value-info-state } { "n/f" number } }
{ $description "Finds the class number for this value-info-states class (an index in the " { $link builtins } " list), or " { $link f } " if it hasn't one." } ;

HELP: emit-set-slot
{ $values { "node" node } }
{ $description "Emits intrinsic code for a " { $link set-slot } " call." } ;

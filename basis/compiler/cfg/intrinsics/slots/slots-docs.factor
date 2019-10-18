USING: classes classes.builtin compiler.cfg.instructions compiler.tree
compiler.tree.propagation.info help.markup help.syntax math layouts sequences
slots.private words ;
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

HELP: value-tag
{ $values { "info" value-info-state } { "n" number } }
{ $description "Finds the class number for this value-info-states class (an index in the " { $link builtins } " list), or " { $link f } " if it hasn't one." } ;

HELP: emit-write-barrier?
{ $values { "infos" "a " { $link sequence } " of " { $link value-info-state } " tuples." } { "?" "true or false" } }
{ $description
  "Whether a given call to " { $link set-slot } " requires a write barrier to be emitted or not. Write barriers are always needed except when the element to set in the slot is known by the compiler to be " { $link immediate } "." }
{ $see-also ##write-barrier } ;

HELP: emit-set-slot
{ $values { "node" node } }
{ $description "Emits intrinsic code for a " { $link set-slot } " call." } ;

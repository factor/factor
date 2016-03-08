USING: classes classes.builtin compiler.cfg compiler.cfg.instructions
compiler.tree compiler.tree.propagation.info help.markup help.syntax
kernel layouts math slots.private ;
IN: compiler.cfg.intrinsics.slots

HELP: class-tag
{ $values { "class" class } { "tag/f" { $maybe number } } }
{ $description "Finds the class number for this class if it is a subclass of a builtin class, or " { $link f } " if it isn't." }
{ $examples
  { $example
    "USING: compiler.cfg.intrinsics.slots math prettyprint ;"
    "complex class-tag ."
    "7"
  }
} ;

HELP: immediate-slot-offset?
{ $values { "object" object } { "?" boolean } }
{ $description
  { $link t } " if the object is a " { $link fixnum } " that is small enough to fit into a machine register. It is used to determine whether immediate versions of the instructions " { $link ##set-slot } " and " { $link ##set-slot-imm } " can be emitted." }
{ $examples
  { $example
    "USING: compiler.cfg.intrinsics.slots compiler.tree.propagation.info prettyprint ;"
    "33 immediate-slot-offset? ."
    "t"
  }
} ;

HELP: node>set-slot-data
{ $values
  { "#call" #call }
  { "write-barrier?" "whether a write barrier is needed, it always is unless the item to set is an " { $link immediate } }
  { "tag" { $maybe number } }
  { "literal" "a literal" }
} { $description "Grabs the data needed from a call node to determine what intrinsic CFG instructions to emit for the " { $link set-slot } " call." } ;

HELP: value-tag
{ $values { "info" value-info-state } { "n/f" { $maybe number } } }
{ $description "Finds the class number for this value-info-states class (an index in the " { $link builtins } " list), or " { $link f } " if it hasn't one." } ;

HELP: emit-set-slot
{ $values
  { "block" basic-block }
  { "#call" #call }
  { "block'" basic-block }
}
{ $description "Emits intrinsic code for a " { $link set-slot } " call." } ;

ARTICLE: "compiler.cfg.intrinsics.slots"
"Generating instructions for slot access"
"This vocab has words for generating intrinsic CFG instructions for slot accessors."
$nl
"Main words, called directly by the compiler through the \"intrinsic\" word property:"
{ $subsections
  emit-set-slot
  emit-slot
} ;

ABOUT: "compiler.cfg.intrinsics.slots"

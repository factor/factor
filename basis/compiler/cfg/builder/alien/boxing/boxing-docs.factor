USING: alien.c-types compiler.cfg.instructions help.markup help.syntax make
math ;
IN: compiler.cfg.builder.alien.boxing

HELP: box
{ $values
  { "vregs" "a one-element sequence containing a virtual register indentifier" }
  { "reps" "a one-element sequence containing a representation symbol" }
  { "c-type" c-type }
  { "dst" "box" }
}
{ $description "Emits a " { $link ##box-alien } " instruction which boxes an alien value contained in the given register." }
{ $examples
  { $unchecked-example
    "USING: compiler.cfg.builder.alien.boxing make prettyprint ;"
    "{ 71 } { int-rep } void* base-type [ box ] { } make nip ."
    "{ T{ ##box-alien { dst 105 } { src 71 } { temp 104 } } }"
  }
}
{ $see-also ##box-alien } ;

HELP: stack-size
{ $values
  { "c-type" c-type }
  { "n" number }
}
{ $description "Calculates how many bytes of stack space an instance of the C type requires." }
{ $examples
  { $unchecked-example
    "USING: compiler.cfg.builder.alien.boxing prettyprint vm ;"
    "context base-type stack-size ."
    "144"
  }
}
{ $see-also heap-size } ;

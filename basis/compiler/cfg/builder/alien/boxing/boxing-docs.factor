USING: alien.c-types compiler.cfg.instructions help.markup help.syntax
math sequences ;
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

HELP: box-return
{ $values
  { "vregs" "vregs that contains the return value of the alien call" }
  { "reps" "representations of the vregs" }
  { "c-type" abstract-c-type }
  { "dst" "vreg in which the boxed value, or a reference to it, will be placed" }
}
{ $description "Emits instructions for boxing the return value from an alien function call." }
{ $examples
  { $unchecked-example
    "USING: compiler.cfg.builder.alien.boxing kernel make prettyprint ;"
    "[ { 10 } { tagged-rep } int base-type box-return drop ] { } make ."
    "{ T{ ##convert-integer { dst 118 } { src 10 } { c-type int } } }"
  }
}
{ $see-also ##box-alien } ;

HELP: flatten-c-type
{ $values { "c-type" abstract-c-type } { "pairs" sequence } }
{ $description "pairs have shape { rep on-stack? f }" } ;

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

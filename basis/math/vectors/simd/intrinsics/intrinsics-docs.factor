USING: help.markup help.syntax kernel sequences ;
IN: math.vectors.simd.intrinsics

HELP: (simd-select)
{ $values { "a" object } { "n" object } { "rep" object } { "x" object } }
{ $description "Word which implements " { $link nth } " for SIMD vectors." }
{ $examples
  { $unchecked-example
    "float-4{ 3 4 9 1 } underlying>> 2 float-4-rep (simd-select)"
    "9.0"
  }
} ;

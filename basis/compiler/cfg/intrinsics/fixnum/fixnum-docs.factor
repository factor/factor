USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax
layouts math quotations words ;
IN: compiler.cfg.intrinsics.fixnum

HELP: fixnum*overflow
{ $values { "x" fixnum } { "y" fixnum } { "z" bignum } }
{ $description "Word called to perform a fixnum multiplication when the product overflows the value storable in " { $link cell } "." }
{ $see-also most-negative-fixnum most-positive-fixnum } ;

HELP: emit-fixnum-comparison
{ $values { "cc" "comparison symbol" } }
{ $description "Emits a " { $link ##compare-integer } " instruction to the make sequence." } ;

HELP: emit-fixnum-overflow-op
{ $values
  { "block" basic-block }
  { "quot" quotation }
  { "word" word }
  { "block'" basic-block }
}
{ $description "Inputs to the final instruction need to be copied because of loc>vreg sync." } ;

HELP: emit-fixnum-shift-general
{ $values
  { "block" basic-block }
  { "block'" basic-block }
}
{ $description "Emits intrinsic code for shifting a " { $link fixnum } ". For positive shifts, " { $link ##shl } " is used, for negative shifts it is more complicated." } ;

ARTICLE: "compiler.cfg.intrinsics.fixnum" "Generating instructions for fixnum arithmetic"
"Combinators:"
{ $subsections
  emit-fixnum-overflow-op
} ;

ABOUT: "compiler.cfg.intrinsics.fixnum"

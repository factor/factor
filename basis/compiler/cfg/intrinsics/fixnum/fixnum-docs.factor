USING: compiler.cfg.instructions help.markup help.syntax layouts math ;
IN: compiler.cfg.intrinsics.fixnum

HELP: fixnum*overflow
{ $values { "x" fixnum } { "y" fixnum } { "z" bignum } }
{ $description "Word called to perform a fixnum multiplication when the product overflows the value storable in " { $link cell } "." }
{ $see-also most-negative-fixnum most-positive-fixnum } ;

HELP: emit-fixnum-comparison
{ $values { "cc" "comparison symbol" } }
{ $description "Emits a " { $link ##compare-integer } " instruction to the make sequence." } ;

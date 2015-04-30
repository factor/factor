USING: compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.intrinsics.fixnum

HELP: emit-fixnum-comparison
{ $values { "cc" "comparison symbol" } }
{ $description "Emits a " { $link ##compare-integer } " instruction to the make sequence." } ;

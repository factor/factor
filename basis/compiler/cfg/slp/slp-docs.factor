USING: help.markup help.syntax ;
IN: compiler.cfg.slp

HELP: automatic-slp?
{ $var-description "Enables automatic straight-line packing of two independent integer expression trees into two 64-bit SIMD lanes. Disabled by default. Recompile target words after changing this setting. This is SLP, not loop vectorization." }
{ $description "Only raw add, subtract, and bitwise AND/OR/XOR operations qualify. Overflow-checking fixnum operations and all floating-point arithmetic remain scalar. Floating-point packing could change the first enabled exception and therefore is excluded even when no rounding reassociation occurs. Target support and a conservative whole-tree packing cost are checked before rewriting." } ;

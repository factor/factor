USING: help.markup help.syntax ;
IN: compiler.tree.propagation.transforms

HELP: one-mod-custom-inlining
{ $values { "inputs" "SSA inputs" } { "quot/f" "an expansion or f" } }
{ $description "Specializes integer remainder with numerator one. Divisors one and minus one yield zero, and other nonzero integer divisors yield one. A zero divisor uses the quotient/remainder operation to preserve platform-specific division-by-zero behavior." } ;

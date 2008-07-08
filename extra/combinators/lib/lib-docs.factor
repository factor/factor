USING: help.syntax help.markup kernel prettyprint sequences
quotations math ;
IN: combinators.lib

HELP: generate
{ $values { "generator" quotation } { "predicate" quotation } { "obj" object } }
{ $description "Loop until the generator quotation generates an object that satisfies predicate quotation." }
{ $unchecked-example
    "! Generate a random 20-bit prime number congruent to 3 (mod 4)"
    "USING: combinators.lib math math.miller-rabin prettyprint ;"
    "[ 20 random-prime ] [ 4 mod 3 = ] generate ."
    "526367"
} ;

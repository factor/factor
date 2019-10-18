USING: help.markup help.syntax math sequences ;
IN: math.combinatorics.bits

HELP: next-permutation-bits
{ $values { "v" integer } { "w" integer } }
{ $description "Generates the next bitwise permutation with the same number of set bits, given a previous lexicographical value." } ;

HELP: all-permutation-bits
{ $values { "bit-count" integer } { "bits" integer } { "seq" sequence } }
{ $description "Generates all permutations of numbers with a given bit-count and number of bits." } ;

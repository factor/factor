USING: help.markup help.syntax ;
IN: math.algebra

HELP: ext-euclidian
{ $values { "a" "a positive integer" } { "b" "a positive integer" } { "gcd" "a positive integer" } { "u" "an integer" } { "v" "an integer" } }
{ $description "Compute the greatest common divisor " { $snippet "gcd" } " of integers " { $snippet "a" } " and " { $snippet "b" } " using the extended Euclidian algorithm. In addition, this word also computes two other values " { $snippet "u" } " and " { $snippet "v" } " such that " { $snippet "a*u + b*v = gcd" } "." } ;

HELP: ring-inverse
{ $values { "a" "a positive integer" } { "b" "a positive integer" } { "i" "a positive integer" } }
{ $description "If " { $snippet "a" } " and " { $snippet "b" } " are coprime, " { $snippet "i" } " is the smallest positive integer such as " { $snippet "a*i = 1" } " in ring " { $snippet "Z/bZ" } "." } ;

HELP: chinese-remainder
{ $values { "aseq" "a sequence of integers" } { "nseq" "a sequence of positive integers" } { "x" "an integer" } }
{ $description "If " { $snippet "nseq" } " integers are pairwise coprimes, " { $snippet "x" } " is the smallest positive integer congruent to each element in " { $snippet "aseq" } " modulo the corresponding element in " { $snippet "nseq" } "." } ;

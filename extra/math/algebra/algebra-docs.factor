USING: help.markup help.syntax ;
IN: math.algebra

HELP: chinese-remainder
{ $values { "aseq" "a sequence of integers" } { "nseq" "a sequence of positive integers" } { "x" "an integer" } }
{ $description "If " { $snippet "nseq" } " integers are pairwise coprimes, " { $snippet "x" } " is the smallest positive integer congruent to each element in " { $snippet "aseq" } " modulo the corresponding element in " { $snippet "nseq" } "." } ;

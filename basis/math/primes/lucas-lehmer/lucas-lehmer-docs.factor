! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: math.primes.lucas-lehmer

HELP: lucas-lehmer
{ $values
    { "p" "a prime number" }
    { "?" boolean }
}
{ $description "Runs the Lucas-Lehmer test on the prime " { $snippet "p" } " and returns " { $link t } " if " { $snippet "(2 ^ p) - 1" } " is prime." }
{ $examples
    { $example "! Test that (2 ^ 61) - 1 is prime:"
               "USING: math.primes.lucas-lehmer prettyprint ;"
               "61 lucas-lehmer ."
               "t"
    }
} ;

ARTICLE: "math.primes.lucas-lehmer" "Lucas-Lehmer Mersenne Primality test"
"The " { $vocab-link "math.primes.lucas-lehmer" } " vocabulary tests numbers of the form " { $snippet "(2 ^ p) - 1" } " for primality, where " { $snippet "p" } " is prime." $nl
"Run the Lucas-Lehmer test:"
{ $subsections lucas-lehmer } ;

ABOUT: "math.primes.lucas-lehmer"

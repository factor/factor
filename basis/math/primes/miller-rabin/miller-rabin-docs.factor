! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences math ;
IN: math.primes.miller-rabin

HELP: miller-rabin
{ $values
    { "n" integer }
    { "?" "a boolean" }
}
{ $description "Returns true if the number is a prime. Calls " { $link miller-rabin* } " with a default of 10 Miller-Rabin tests." } ;

{ miller-rabin miller-rabin* } related-words

HELP: miller-rabin*
{ $values
    { "n" integer } { "numtrials" integer }
    { "?" "a boolean" }
}
{ $description "Performs " { $snippet "numtrials" } " trials of the Miller-Rabin probabilistic primality test algorithm and returns true if prime." } ;

ARTICLE: "math.primes.miller-rabin" "Miller-Rabin probabilistic primality test"
"The " { $vocab-link "math.primes.miller-rabin" } " vocabulary implements the Miller-Rabin probabilistic primality test and utility words that use it in order to generate random prime numbers." $nl
"The Miller-Rabin probabilistic primality test:"
{ $subsection miller-rabin }
{ $subsection miller-rabin* } ;

ABOUT: "math.primes.miller-rabin"

! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences math ;
IN: math.miller-rabin

HELP: find-relative-prime
{ $values
    { "n" integer }
    { "p" integer }
}
{ $description "Returns a number that is relatively prime to " { $snippet "n" } "." } ;

HELP: find-relative-prime*
{ $values
    { "n" integer } { "guess" integer }
    { "p" integer }
}
{ $description "Returns a number that is relatively prime to " { $snippet "n" } ", starting by trying " { $snippet "guess" } "." } ;

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

HELP: next-prime
{ $values
    { "n" integer }
    { "p" integer }
}
{ $description "Tests consecutive numbers for primality with " { $link miller-rabin } " and returns the next prime." } ;

HELP: next-safe-prime
{ $values
    { "n" integer }
    { "q" integer }
}
{ $description "Tests consecutive numbers and returns the next safe prime. A safe prime is desirable in cryptography applications such as Diffie-Hellman and SRP6." } ;

HELP: random-bits*
{ $values
    { "numbits" integer }
    { "n" integer }
}
{ $description "Returns an integer exactly " { $snippet "numbits" } " in length, with the topmost bit set to one." } ;

HELP: random-prime
{ $values
    { "numbits" integer }
    { "p" integer }
}
{ $description "Returns a prime number exactly " { $snippet "numbits" } " bits in length, with the topmost bit set to one." } ;

HELP: random-safe-prime
{ $values
    { "numbits" integer }
    { "p" integer }
}
{ $description "Returns a safe prime number " { $snippet "numbits" } " bits in length, with the topmost bit set to one." } ;

HELP: safe-prime?
{ $values
    { "q" integer }
    { "?" "a boolean" }
}
{ $description "Tests whether the number is a safe prime. A safe prime " { $snippet "p" } " must be prime, as must " { $snippet "(p - 1) / 2" } "." } ;

HELP: unique-primes
{ $values
    { "numbits" integer } { "n" integer }
    { "seq" sequence }
}
{ $description "Generates a sequence of " { $snippet "n" } " unique prime numbers with exactly " { $snippet "numbits" } " bits." } ;

ARTICLE: "math.miller-rabin" "Miller-Rabin probabilistic primality test"
"The " { $vocab-link "math.miller-rabin" } " vocabulary implements the Miller-Rabin probabilistic primality test and utility words that use it in order to generate random prime numbers." $nl
"The Miller-Rabin probabilistic primality test:"
{ $subsection miller-rabin }
{ $subsection miller-rabin* }
"Generating relative prime numbers:"
{ $subsection find-relative-prime }
{ $subsection find-relative-prime* }
"Generating prime numbers:"
{ $subsection next-prime }
{ $subsection random-prime }
"Generating safe prime numbers:"
{ $subsection next-safe-prime }
{ $subsection random-safe-prime } ;

ABOUT: "math.miller-rabin"

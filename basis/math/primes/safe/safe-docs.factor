! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math ;
IN: math.primes.safe

HELP: next-safe-prime
{ $values
    { "n" integer }
    { "q" integer }
}
{ $description "Tests consecutive numbers and returns the next safe prime. A safe prime is desirable in cryptography applications such as Diffie-Hellman and SRP6." } ;

HELP: random-safe-prime
{ $values
    { "numbits" integer }
    { "p" integer }
}
{ $description "Returns a safe prime number " { $snippet "numbits" } " bits in length, with the topmost bit set to one." } ;

HELP: safe-prime?
{ $values
    { "q" integer }
    { "?" boolean }
}
{ $description "Tests whether the number is a safe prime. A safe prime " { $snippet "p" } " must be prime, as must " { $snippet "(p - 1) / 2" } "." } ;


ARTICLE: "math.primes.safe" "Safe prime numbers"
"The " { $vocab-link "math.primes.safe" } " vocabulary implements words to calculate safe prime numbers. Safe primes are of the form " { $snippet "p = 2q + 1" } ", where " { $snippet "p" } ", " { $snippet "q" } " are prime. Safe primes have desirable qualities for cryptographic applications." $nl

"Testing if a number is a safe prime:"
{ $subsections safe-prime? }
"Generating safe prime numbers:"
{ $subsections
    next-safe-prime
    random-safe-prime
} ;

ABOUT: "math.primes.safe"

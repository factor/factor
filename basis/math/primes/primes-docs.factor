USING: help.markup help.syntax kernel math sequences ;
IN: math.primes

{ next-prime prime? } related-words

HELP: next-prime
{ $values { "n" integer } { "p" "a prime number" } }
{ $description "Return the next prime number greater than " { $snippet "n" } "." } ;

HELP: prime?
{ $values { "n" integer } { "?" boolean } }
{ $description "Test if an integer is a prime number." } ;

{ nprimes primes-upto primes-between } related-words

HELP: nprimes
{ $values { "n" "a non-negative integer" } { "seq" sequence } }
{ $description "Return a sequence containing the " { $snippet "n" } " first primes numbers." } ;

HELP: primes-upto
{ $values { "n" integer } { "seq" sequence } }
{ $description "Return a sequence containing all the prime numbers smaller or equal to " { $snippet "n" } "." } ;

HELP: primes-between
{ $values { "low" integer } { "high" integer } { "seq" sequence } }
{ $description "Return a sequence containing all the prime numbers between " { $snippet "low" } " and " { $snippet "high" } "." } ;

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

HELP: random-prime
{ $values
    { "numbits" integer }
    { "p" integer }
}
{ $description "Returns a prime number exactly " { $snippet "numbits" } " bits in length, with the topmost bit set to one." } ;

HELP: unique-primes
{ $values
    { "n" integer }
    { "numbits" integer }
    { "seq" sequence }
}
{ $description "Generates a sequence of " { $snippet "n" } " unique prime numbers with exactly " { $snippet "numbits" } " bits." } ;

ARTICLE: "math.primes" "Prime numbers"
"The " { $vocab-link "math.primes" } " vocabulary implements words related to prime numbers. Several useful vocabularies exist for testing primality. The Sieve of Eratosthenes in " { $vocab-link "math.primes.erato" } " is useful for testing primality below five million. For larger integers, " { $vocab-link "math.primes.miller-rabin" } " is a fast probabilistic primality test. The " { $vocab-link "math.primes.lucas-lehmer" } " vocabulary implements an algorithm for finding huge Mersenne prime numbers." $nl
"Testing if a number is prime:"
{ $subsections prime? }
"Generating prime numbers:"
{ $subsections
    next-prime
    primes-upto
    primes-between
    random-prime
}
"Generating relative prime numbers:"
{ $subsections
    find-relative-prime
    find-relative-prime*
}
"Make a sequence of random prime numbers:"
{ $subsections unique-primes } ;

ABOUT: "math.primes"

USING: help.markup help.syntax math sequences ;
IN: math.primes

{ next-prime prime? } related-words

HELP: next-prime
{ $values { "n" integer } { "p" "a prime number" } }
{ $description "Return the next prime number greater than " { $snippet "n" } "." } ;

HELP: prime?
{ $values { "n" "an integer" } { "?" "a boolean" } }
{ $description "Test if an integer is a prime number." } ;

{ primes-upto primes-between } related-words

HELP: primes-upto
{ $values { "n" "an integer" } { "seq" "a sequence" } }
{ $description "Return a sequence containing all the prime numbers smaller or equal to " { $snippet "n" } "." } ;

HELP: primes-between
{ $values { "low" "an integer" } { "high" "an integer" } { "seq" "a sequence" } }
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
    { "numbits" integer } { "n" integer }
    { "seq" sequence }
}
{ $description "Generates a sequence of " { $snippet "n" } " unique prime numbers with exactly " { $snippet "numbits" } " bits." } ;

ARTICLE: "math.primes" "Prime numbers"
"The " { $vocab-link "math.primes" } " vocabulary implements words related to prime numbers. Serveral useful vocabularies exist for testing primality. The Sieve of Eratosthenes in " { $vocab-link "math.primes.erato" } " is useful for testing primality below five million. For larger integers, " { $vocab-link "math.primes.miller-rabin" } " is a fast probabilstic primality test. The " { $vocab-link "math.primes.lucas-lehmer" } " vocabulary implements an algorithm for finding huge Mersenne prime numbers." $nl
"Testing if a number is prime:"
{ $subsection prime? }
"Generating prime numbers:"
{ $subsection next-prime }
{ $subsection primes-upto }
{ $subsection primes-between }
{ $subsection random-prime }
"Generating relative prime numbers:"
{ $subsection find-relative-prime }
{ $subsection find-relative-prime* }
"Make a sequence of random prime numbers:"
{ $subsection unique-primes } ;

ABOUT: "math.primes"

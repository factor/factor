USING: help.markup help.syntax ;
IN: math.primes

{ next-prime prime? } related-words

HELP: next-prime
{ $values { "n" "an integer not smaller than 2" } { "p" "a prime number" } }
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

USING: help.markup help.syntax ;
IN: math.primes

{ next-prime prime? } related-words

HELP: next-prime
{ $values { "n" "a positive integer" } { "p" "a prime number" } }
{ $description "Return the next prime number greater than " { $snippet "n" } "." } ;

HELP: prime?
{ $values { "n" "an integer" } { "?" "a boolean" } }
{ $description "Test if an integer is a prime number." } ;

{ lprimes lprimes-from primes-upto primes-between } related-words

HELP: lprimes
{ $values { "list" "a lazy list" } }
{ $description "Return a sorted list containing all the prime numbers." } ;

HELP: lprimes-from
{ $values { "n" "an integer" } { "list" "a lazy list" } }
{ $description "Return a sorted list containing all the prime numbers greater or equal to " { $snippet "n" } "." } ;

HELP: primes-upto
{ $values { "n" "an integer" } { "seq" "a sequence" } }
{ $description "Return a sequence containing all the prime numbers smaller or equal to " { $snippet "n" } "." } ;

HELP: primes-between
{ $values { "low" "an integer" } { "high" "an integer" } { "seq" "a sequence" } }
{ $description "Return a sequence containing all the prime numbers between " { $snippet "low" } " and " { $snippet "high" } "." } ;

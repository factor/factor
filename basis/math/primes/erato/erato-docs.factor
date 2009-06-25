USING: help.markup help.syntax ;
IN: math.primes.erato

HELP: sieve
{ $values { "n" "the greatest odd number to consider" } { "arr" "a bit array" } }
{ $description "Apply Eratostene sieve up to " { $snippet "n" } ". Primality can then be tested using " { $link sieve } "." } ;

HELP: marked-prime?
{ $values { "n" "an integer" } { "arr" "a byte array returned by " { $link sieve } } { "?" "a boolean" } }
{ $description "Check whether a number between 3 and the limit given to " { $link sieve } " has been marked as a prime number."} ;

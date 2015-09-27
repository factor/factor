USING: byte-arrays help.markup help.syntax kernel math ;
IN: math.primes.erato

HELP: sieve
{ $values { "n" integer } { "sieve" byte-array } }
{ $description "Apply Eratostene sieve up to " { $snippet "n" }
". " { $snippet "n" } " must be greater than 1"
". Primality can then be tested using " { $link marked-prime? } "." } ;

HELP: marked-prime?
{ $values { "n" integer } { "sieve" byte-array } { "?" boolean } }
{ $description "Checks whether " { $snippet "n" } " has been marked as a prime number. "
{ $snippet "sieve" } " must be " { $instance byte-array } " returned by " { $link sieve } ". "
{ $snippet "n" } " must be between 2 and the limit given to " { $link sieve } "." } ;

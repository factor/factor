USING: help.markup help.syntax ;
IN: math.erato

HELP: <erato>
{ $values { "n" "a positive number" } { "erato" "a prime numbers generator" } }
{ $description "Build a prime numbers generator for primes between 2 and " { $snippet "n" } " (inclusive)." } ;

HELP: next-prime
{ $values { "erato" "a generator" } { "prime/f" "a prime number or f" } }
{ $description "Compute the next prime number using the given generator. If there are no more prime numbers under the limit used when building the generator, f is returned instead." } ;

HELP: lerato
{ $values { "n" "a positive number" } { "lazy-list" "a lazy prime numbers generator" } }
{ $description "Builds a lazy list containing the prime numbers between 2 and " { $snippet "n" } " (inclusive). Lazy lists are described in " { $link "lazy-lists" } "." } ;

USING: help.markup help.syntax math sequences ;
IN: math.primes.factors

{ divisors factors group-factors unique-factors } related-words

HELP: factors
{ $values { "n" "a positive integer" } { "seq" sequence } }
{ $description { "Return an ordered list of a number's prime factors, possibly repeated, using the Pollard Rho Brent algorithm in the " { $vocab-link "math.primes.pollard-rho-brent" } " vocabulary." } }
{ $examples { $example "USING: math.primes.factors prettyprint ;" "300 factors ." "{ 2 2 3 5 5 }" } } ;

HELP: group-factors
{ $values { "n" "a positive integer" } { "seq" sequence } }
{ $description { "Return a sequence of pairs representing each prime factor in the number and its corresponding power (multiplicity)." } }
{ $examples { $example "USING: math.primes.factors prettyprint ;" "300 group-factors ." "{ { 2 2 } { 3 1 } { 5 2 } }" } } ;

HELP: unique-factors
{ $values { "n" "a positive integer" } { "seq" sequence } }
{ $description { "Return an ordered list of a number's unique prime factors." } }
{ $examples { $example "USING: math.primes.factors prettyprint ;" "300 unique-factors ." "{ 2 3 5 }" } } ;

HELP: totient
{ $values { "n" "a positive integer" } { "t" integer } }
{ $description { "Return the number of integers between 1 and " { $snippet "n-1" } " that are relatively prime to " { $snippet "n" } "." } } ;

HELP: divisors
{ $values { "n" "a positive integer" } { "seq" sequence } }
{ $description { "Return the ordered list of divisors of " { $snippet "n" } ", including 1 and " { $snippet "n" } "." } } ;

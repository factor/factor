USING: help.markup help.syntax ;
IN: math.primes.factors

{ factors count-factors unique-factors } related-words

HELP: factors
{ $values { "n" "a positive integer" } { "seq" "a sequence" } }
{ $description { "Factorize an integer and return an ordered list of factors, possibly repeated." } } ;

HELP: count-factors
{ $values { "n" "a positive integer" } { "seq" "a sequence" } }
{ $description { "Return a sequence of pairs representing each factor in the number and its corresponding power." } } ;

HELP: unique-factors
{ $values { "n" "a positive integer" } { "seq" "a sequence" } }
{ $description { "Return an ordered list of unique prime factors." } } ;

HELP: totient
{ $values { "n" "a positive integer" } { "t" "an integer" } }
{ $description { "Return the number of integers between 1 and " { $snippet "n-1" } " relatively prime to " { $snippet "n" } "." } } ;

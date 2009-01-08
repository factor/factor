USING: help.markup help.syntax ;
IN: math.primes.erato

HELP: sieve
{ $values { "n" "the greatest odd number to consider" } { "arr" "a bit array" } }
{ $description "Return a bit array containing a primality bit for every odd number between 3 and " { $snippet "n" } " (inclusive). " { $snippet ">index" } " can be used to retrieve the index of an odd number to be tested." } ;

HELP: >index
{ $values { "n" "an odd number" } { "i" "the corresponding index" } }
{ $description "Retrieve the index corresponding to the odd number on the stack." } ;

{ sieve >index } related-words

USING: help.markup help.syntax math random.backend ;
IN: random

ARTICLE: "random-numbers" "Generating random integers"
"The " { $vocab-link "random" } " vocabulary implements the ``Mersenne Twister'' pseudo-random number generator algorithm."
{ $subsection random } ;

ABOUT: "random-numbers"

HELP: seed-random
{ $values { "tuple" "a random number generator" } { "seed" "an integer between 0 and 2^32-1" } }
{ $description "Seed the random number generator." }
{ $notes "Not supported on all random number generators." } ;

HELP: random-32*
{ $values { "tuple" "a random number generator" } { "r" "an integer between 0 and 2^32-1" } }
{ $description "Generates a random 32-bit unsigned integer." } ;

HELP: random-bytes*
{ $values { "n" "an integer" } { "tuple" "a random number generator" } { "bytes" "a sequence of random bytes" } }
{ $description "Generates a byte-array of random bytes." } ;

HELP: random
{ $values { "seq" "a sequence" } { "elt" "a random element" } }
{ $description "Outputs a random element of the sequence. If the sequence is empty, always outputs " { $link f } "." }
{ $notes "Since integers are sequences, passing an integer " { $snippet "n" } " yields a random integer in the interval " { $snippet "[0,n)" } "." } ;

HELP: random-bytes
{ $values { "n" "an integer" } { "bytes" "a random integer" } }
{ $description "Outputs an integer with n bytes worth of bits." } ;

HELP: random-bits
{ $values { "n" "an integer" } { "r" "a random integer" } }
{ $description "Outputs an random integer n bits in length." } ;

HELP: with-random
{ $values { "tuple" "a random generator" } { "quot" "a quotation" } }
{ $description "Calls the quotation with the random generator in a dynamic variable.  All random numbers will be generated using this random generator." } ;

HELP: with-secure-random
{ $values { "quot" "a quotation" } }
{ $description "Calls the quotation with the secure random generator in a dynamic variable.  All random numbers will be generated using this random generator." } ;

{ with-random with-secure-random } related-words

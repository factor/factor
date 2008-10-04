USING: help.markup help.syntax math kernel sequences ;
IN: random

HELP: seed-random
{ $values { "tuple" "a random number generator" } { "seed" "an integer between 0 and 2^32-1" } }
{ $description "Seed the random number generator." }
{ $notes "Not supported on all random number generators." } ;

HELP: random-32*
{ $values { "tuple" "a random number generator" } { "r" "an integer between 0 and 2^32-1" } }
{ $description "Generates a random 32-bit unsigned integer." } ;

HELP: random-bytes*
{ $values { "n" "an integer" } { "tuple" "a random number generator" } { "byte-array" "a sequence of random bytes" } }
{ $description "Generates a byte-array of random bytes." } ;

HELP: random
{ $values { "obj" object } { "elt" "a random element" } }
{ $description "Outputs a random element of the input object. If the object is an integer, an input of zero always returns a zero, a negative integer throws an error, and positive integers yield a random integer in the interval " { $snippet "[0,n)" } ". On a sequence, an empty sequence always outputs " { $link f } " while any other sequence outputs a random element." }
{ $notes "Since integers are sequences, passing an integer " { $snippet "n" } " yields a random integer in the interval " { $snippet "[0,n)" } "." } ;

HELP: random-bytes
{ $values { "n" "an integer" } { "byte-array" "a random integer" } }
{ $description "Outputs an integer with n bytes worth of bits." }
{ $examples 
    { $unchecked-example "USING: prettyprint random ;"
               "5 random-bytes ."
               "B{ 135 50 185 119 240 }"
    }
} ;

HELP: random-bits
{ $values { "n" "an integer" } { "r" "a random integer" } }
{ $description "Outputs an random integer n bits in length." } ;

HELP: with-random
{ $values { "tuple" "a random generator" } { "quot" "a quotation" } }
{ $description "Calls the quotation with the random generator in a dynamic variable.  All random numbers will be generated using this random generator." } ;

HELP: with-secure-random
{ $values { "quot" "a quotation" } }
{ $description "Calls the quotation with the secure random generator in a dynamic variable.  All random numbers will be generated using this random generator." } ;

HELP: with-system-random
{ $values { "quot" "a quotation" } }
{ $description "Calls the quotation with the system's random generator in a dynamic variable.  All random numbers will be generated using this random generator." } ;

{ with-random with-secure-random with-system-random } related-words

HELP: delete-random
{ $values
     { "seq" sequence }
     { "elt" object } }
{ $description "Delete a random number from a sequence using " { $link delete-nth } " and returns the deleted object." } ;

ARTICLE: "random-protocol" "Random protocol"
"A random number generator must implement one of these two words:"
{ $subsection random-32* }
{ $subsection random-bytes* }
"Optional, to seed a random number generator:"
{ $subsection seed-random } ;

ARTICLE: "random" "Generating random integers"
"The " { $vocab-link "random" } " vocabulary contains a protocol for generating random or pseudorandom numbers. The ``Mersenne Twister'' pseudorandom number generator algorithm is the default generator stored in " { $link random-generator } "."
"Generate a random object:"
{ $subsection random }
"Combinators to change the random number generator:"
{ $subsection with-random }
{ $subsection with-system-random }
{ $subsection with-secure-random }
"Implementation:"
{ $subsection "random-protocol" }
"Deleting a random element from a sequence:"
{ $subsection delete-random } ;

ABOUT: "random"

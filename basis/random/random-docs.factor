USING: help.markup help.syntax math kernel sequences ;
IN: random

HELP: seed-random
{ $values
    { "tuple" "a random number generator" }
    { "seed" "a seed specific to the random number generator" }
    { "tuple'" "a random number generator" }
}
{ $description "Seed the random number generator. Repeatedly seeding the random number generator should provide the same sequence of random numbers." }
{ $notes "Not supported on all random number generators." } ;

HELP: random-32*
{ $values { "tuple" "a random number generator" } { "r" "an integer between 0 and 2^32-1" } }
{ $description "Generates a random 32-bit unsigned integer." } ;

HELP: random-bytes*
{ $values { "n" "an integer" } { "tuple" "a random number generator" } { "byte-array" "a sequence of random bytes" } }
{ $description "Generates a byte-array of random bytes." } ;

HELP: random
{ $values { "seq" sequence } { "elt" "a random element" } }
{ $description "Outputs a random element of the input sequence. Outputs " { $link f } " if the sequence is empty." }
{ $notes "Since integers are sequences, passing an integer " { $snippet "n" } " outputs an integer in the interval " { $snippet "[0,n)" } "." }
{ $examples
    { $unchecked-example "USING: random prettyprint ;"
        "10 random ."
        "3" }
    { $unchecked-example "USING: random prettyprint ;"
        "SYMBOL: heads"
        "SYMBOL: tails"
        "{ heads tails } random ."
        "heads" }
} ;

HELP: random-32
{ $values { "n" "a 32-bit random integer" } }
{ $description "Outputs 32 random bits. This word is more efficient than calling " { $link random } " because no scaling is done on the output." } ;

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
{ $values { "numbits" integer } { "r" "a random integer" } }
{ $description "Outputs an random integer n bits in length." } ;

HELP: random-bits*
{ $values
    { "numbits" integer }
    { "n" integer }
}
{ $description "Returns an integer exactly " { $snippet "numbits" } " in length, with the topmost bit set to one." } ;


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

HELP: randomize
{ $values
     { "seq" sequence }
     { "seq" sequence }
}
{ $description "Randomizes a sequence in-place with the Fisher-Yates algorithm and returns the sequence." } ;

HELP: sample
{ $values
    { "seq" sequence } { "n" integer }
    { "seq'" sequence }
}
{ $description "Takes " { $snippet "n" } " samples at random without replacement from a sequence. Throws an error if " { $snippet "n" } " is longer than the sequence." }
{ $examples
    { $unchecked-example "USING: random prettyprint ; { 1 2 3 } 2 sample ."
        "{ 3 2 }"
    }
} ;

HELP: delete-random
{ $values
     { "seq" sequence }
     { "elt" object } }
{ $description "Deletes a random number from a sequence using " { $link delete-nth } " and returns the deleted object." } ;

ARTICLE: "random-protocol" "Random protocol"
"A random number generator must implement one of these two words:"
{ $subsection random-32* }
{ $subsection random-bytes* }
"Optional, to seed a random number generator:"
{ $subsection seed-random } ;

ARTICLE: "random" "Generating random integers"
"The " { $vocab-link "random" } " vocabulary contains a protocol for generating random or pseudorandom numbers."
$nl
"The “Mersenne Twister” pseudorandom number generator algorithm is the default generator stored in " { $link random-generator } "."
$nl
"Generate a random object:"
{ $subsection random }
"Efficient 32-bit random numbers:"
{ $subsection random-32 }
"Combinators to change the random number generator:"
{ $subsection with-random }
{ $subsection with-system-random }
{ $subsection with-secure-random }
"Implementation:"
{ $subsection "random-protocol" }
"Randomizing a sequence:"
{ $subsection randomize }
"Sampling a sequences:"
{ $subsection sample }
"Deleting a random element from a sequence:"
{ $subsection delete-random }
"Random numbers with " { $snippet "n" } " bits:"
{ $subsection random-bits }
{ $subsection random-bits* } ;

ABOUT: "random"

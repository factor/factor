USING: help.markup help.syntax math kernel sequences arrays ;
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
{ $values { "obj" object } { "elt" "a random element" } }
{ $description "Outputs a random element of the input object, or outputs " { $link f } " if the object contains no elements." }
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

HELP: random-integers
{ $values { "length" integer } { "n" integer } { "sequence" array } }
{ $description "Outputs an array with " { $snippet "length" } " random integers from [0,n)." }
{ $examples 
    { $unchecked-example "USING: prettyprint random ;"
               "10 100 random-integers ."
               "{ 32 62 71 89 54 12 57 57 10 19 }"
    }
} ;

HELP: random-unit
{ $values { "n" float } }
{ $description "Outputs a random uniform float from [0,1]." } ;

HELP: random-units
{ $values { "length" integer } { "sequence" array } }
{ $description "Outputs an array with " { $snippet "length" } " random uniform floats from [0,1]." }
{ $examples 
    { $unchecked-example "USING: prettyprint random ;"
               "7 random-units ."
               "{
    0.1881956429982787
    0.9063571897519639
    0.9550470241550406
    0.6289397941552234
    0.9441213853903183
    0.7673290082934152
    0.573743749061385
}"
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
     { "randomized" sequence }
}
{ $description "Randomizes a sequence in-place with the Fisher-Yates algorithm and returns the sequence." } ;

HELP: sample
{ $values
    { "seq" sequence } { "n" integer }
    { "seq'" sequence }
}
{ $description "Takes " { $snippet "n" } " samples at random without replacement from a sequence. Throws an error if " { $snippet "n" } " is longer than the sequence." }
{ $examples
    { $unchecked-example "USING: random prettyprint ;"
    "{ 1 2 3 } 2 sample ."
    "{ 3 2 }"
    }
} ;

HELP: delete-random
{ $values
     { "seq" sequence }
     { "elt" object } }
{ $description "Deletes a random number from a sequence using " { $link remove-nth! } " and returns the deleted object." } ;

ARTICLE: "random-protocol" "Random protocol"
"A random number generator must implement one of these two words:"
{ $subsections
    random-32*
    random-bytes*
}
"Optional, to seed a random number generator:"
{ $subsections seed-random } ;

ARTICLE: "random" "Generating random integers"
"The " { $vocab-link "random" } " vocabulary contains a protocol for generating random or pseudorandom numbers."
$nl
"The “Mersenne Twister” pseudorandom number generator algorithm is the default generator stored in " { $link random-generator } "."
$nl
"Generate a random object:"
{ $subsections random }
"Efficient 32-bit random numbers:"
{ $subsections random-32 }
"Combinators to change the random number generator:"
{ $subsections
    with-random
    with-system-random
    with-secure-random
}
"Implementation:"
{ $subsections "random-protocol" }
"Randomizing a sequence:"
{ $subsections randomize }
"Sampling a sequences:"
{ $subsections sample }
"Deleting a random element from a sequence:"
{ $subsections delete-random }
"Sequences of random numbers:"
{ $subsections random-bytes random-integers random-units }
"Random numbers with " { $snippet "n" } " bits:"
{ $subsections
    random-bits
    random-bits*
} ;

ABOUT: "random"

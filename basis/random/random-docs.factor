USING: arrays help.markup help.syntax kernel math quotations random
sequences ;
IN: combinators.random

HELP: seed-random
{ $values
    { "rnd" "a random number generator" }
    { "seed" "a seed specific to the random number generator" }
}
{ $description "Seed the random number generator. Repeatedly seeding the random number generator should provide the same sequence of random numbers." }
{ $notes "Not supported on all random number generators." } ;

HELP: random-32*
{ $values { "rnd" "a random number generator" } { "n" "an integer between 0 and 2^32-1" } }
{ $description "Generates a random 32-bit unsigned integer." } ;

HELP: random-32
{ $values { "n" "a 32-bit random integer" } }
{ $description "Outputs 32 random bits. This word is more efficient than calling " { $link random } " because no scaling is done on the output." } ;

{ random-32* random-32 } related-words

HELP: random-bytes*
{ $values { "n" integer } { "rnd" "a random number generator" } { "byte-array" "a sequence of random bytes" } }
{ $description "Generates a byte-array of " { $snippet "n" } " random bytes." } ;

HELP: random-bytes
{ $values { "n" integer } { "byte-array" "a sequence of random bytes" } }
{ $description "Generates a byte-array of " { $snippet "n" } " random bytes." }
{ $examples
    { $unchecked-example "USING: prettyprint random ;"
               "5 random-bytes ."
               "B{ 135 50 185 119 240 }"
    }
} ;

{ random-bytes* random-bytes } related-words

HELP: random*
{ $values { "obj" object } { "rnd" "a random number generator" } { "elt" "a random element" } }
{ $description "Outputs a random element of the input object, or outputs " { $link f } " if the object contains no elements." } ;

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

HELP: randoms-as
{ $values { "length" integer } { "obj" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "Outputs a sequence of the same type as " { $snippet "exemplar" } " with " { $snippet "length" } " random values generated from " { $snippet "obj" } "." }
{ $examples
    { $unchecked-example "USING: prettyprint random ranges ;"
               "10 CHAR: A CHAR: Z [a..b] \"\" randoms-as ."
               "\"KEIYFPBAWJ\""
    }
} ;

HELP: randoms
{ $values { "length" integer } { "obj" object } { "seq" array } }
{ $description "Outputs an array with " { $snippet "length" } " random values generated from " { $snippet "obj" } "." }
{ $examples
    { $unchecked-example "USING: prettyprint random ;"
               "10 100 randoms ."
               "{ 32 62 71 89 54 12 57 57 10 19 }"
    }
} ;

{ random* random randoms randoms-as } related-words

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
{ $values { "numbits" integer } { "n" "a random integer" } }
{ $description "Outputs a random integer " { $snippet "numbits" } " bits in length." } ;

HELP: random-bits-exact
{ $values { "numbits" integer } { "n" "a random integer" } }
{ $description "Returns an integer exactly " { $snippet "numbits" } " bits in length, with the topmost bit set to one." } ;

HELP: with-random
{ $values { "rnd" "a random number generator" } { "quot" quotation } }
{ $description "Calls the quotation with the random number generator in a dynamic variable. All random numbers will be generated using this random number generator." } ;

HELP: with-secure-random
{ $values { "quot" quotation } }
{ $description "Calls the quotation with the secure random number generator in a dynamic variable. All random numbers will be generated using this random number generator." } ;

HELP: with-system-random
{ $values { "quot" quotation } }
{ $description "Calls the quotation with the system's random number generator in a dynamic variable. All random numbers will be generated using this random number generator." } ;

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
"The \"Mersenne Twister\" pseudorandom number generator algorithm is the default generator stored in " { $link random-generator } "."
$nl
"Generate random object(s):"
{ $subsections random randoms }
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
{ $subsections random-bytes random-units }
"Random numbers with " { $snippet "n" } " bits:"
{ $subsections
    random-bits
    random-bits-exact
} ;

ABOUT: "random"

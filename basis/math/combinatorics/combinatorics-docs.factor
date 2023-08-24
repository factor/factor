USING: help.markup help.syntax math math.combinatorics
math.combinatorics.private math.order sequences ;
IN: math.combinatorics

HELP: factorial
{ $values { "n" "a non-negative integer" } { "n!" integer } }
{ $description "Outputs the product of all positive integers less than or equal to " { $snippet "n" } "." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "4 factorial ." "24" }
} ;

HELP: nPk
{ $values { "n" "a non-negative integer" } { "k" "a non-negative integer" } { "nPk" integer } }
{ $description "Outputs the total number of unique permutations of size " { $snippet "k" } " (order does matter) that can be taken from a set of size " { $snippet "n" } "." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "10 4 nPk ." "5040" }
} ;

HELP: nCk
{ $values { "n" "a non-negative integer" } { "k" "a non-negative integer" } { "nCk" integer } }
{ $description "Outputs the total number of unique combinations of size " { $snippet "k" } " (order does not matter) that can be taken from a set of size " { $snippet "n" } ". Commonly written as \"n choose k\"." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "10 4 nCk ." "210" }
} ;

HELP: permutation
{ $values { "n" "a non-negative integer" } { "seq" sequence } { "seq'" sequence } }
{ $description "Outputs the " { $snippet "nth" } " lexicographical permutation of " { $snippet "seq" } "." }
{ $notes "Permutations are 0-based and a bounds error will be thrown if " { $snippet "n" } " is larger than " { $snippet "seq length factorial 1 -" } "." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "1 { 0 1 2 } permutation ." "{ 0 2 1 }" }
    { $example "USING: math.combinatorics prettyprint ;"
        "5 { \"apple\" \"banana\" \"orange\" } permutation ." "{ \"orange\" \"banana\" \"apple\" }" }
} ;

HELP: <permutations>
{ $values { "seq" sequence } { "permutations" sequence } }
{ $description "An efficient sequence containing the lexicographical permutations of " { $snippet "seq" } "." } ;

HELP: <k-permutations>
{ $values { "seq" sequence } { "k" integer } { "permutations" sequence } }
{ $description "An efficient sequence containing the " { $snippet "k" } " lexicographical permutations of " { $snippet "seq" } "." } ;

HELP: all-permutations
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Outputs a sequence containing all permutations of " { $snippet "seq" } " in lexicographical order." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "{ 0 1 2 } all-permutations ." "{ { 0 1 2 } { 0 2 1 } { 1 0 2 } { 1 2 0 } { 2 0 1 } { 2 1 0 } }" }
} ;

HELP: each-permutation
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ) } } }
{ $description "Applies the quotation to each permutation of " { $snippet "seq" } " in order." } ;

HELP: inverse-permutation
{ $values { "seq" sequence } { "permutation" sequence } }
{ $description "Outputs a sequence of indices representing the lexicographical permutation of " { $snippet "seq" } "." }
{ $notes "All items in " { $snippet "seq" } " must be comparable by " { $link <=> } "." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "\"dcba\" inverse-permutation ." "{ 3 2 1 0 }" }
    { $example "USING: math.combinatorics prettyprint ;"
        "{ 12 56 34 78 } inverse-permutation ." "{ 0 2 1 3 }" }
} ;

HELP: combination
{ $values { "m" "a non-negative integer" } { "seq" sequence } { "k" "a non-negative integer" } { "seq'" sequence } }
{ $description "Outputs the " { $snippet "mth" } " lexicographical combination of " { $snippet "seq" } " choosing " { $snippet "k" } " elements." }
{ $notes "Combinations are 0-based and a bounds error will be thrown if " { $snippet "m" } " is larger than " { $snippet "seq length k nCk" } "." }
{ $examples
    { $example "USING: math.combinatorics sequences prettyprint ;"
        "6 7 <iota> 4 combination ." "{ 0 1 3 6 }" }
    { $example "USING: math.combinatorics prettyprint ;"
        "0 { \"a\" \"b\" \"c\" \"d\" } 2 combination ." "{ \"a\" \"b\" }" }
} ;

HELP: <combinations>
{ $values { "seq" sequence } { "k" "a non-negative integer" } { "combinations" sequence } }
{ $description "An efficient sequence containing the combinations of " { $snippet "seq" } " choosing " { $snippet "k" } " elements." } ;

HELP: all-combinations
{ $values { "seq" sequence } { "k" "a non-negative integer" } { "seq'" sequence } }
{ $description "Outputs a sequence containing all combinations of " { $snippet "seq" } " choosing " { $snippet "k" } " elements, in lexicographical order." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "{ \"a\" \"b\" \"c\" \"d\" } 2 all-combinations ."
"{
    { \"a\" \"b\" }
    { \"a\" \"c\" }
    { \"a\" \"d\" }
    { \"b\" \"c\" }
    { \"b\" \"d\" }
    { \"c\" \"d\" }
}" } } ;

HELP: each-combination
{ $values { "seq" sequence } { "k" "a non-negative integer" } { "quot" { $quotation ( ... elt -- ... ) } } }
{ $description "Applies the quotation to each combination of " { $snippet "seq" } " choosing " { $snippet "k" } " elements, in order." } ;

HELP: factoradic
{ $values { "n" integer } { "factoradic" sequence } }
{ $description "Converts a positive integer " { $snippet "n" } " to factoradic form. The factoradic of an integer is its representation based on a mixed radix numerical system that corresponds to the values of " { $snippet "n" } " factorial." }
{ $examples { $example "USING: math.combinatorics.private prettyprint ;" "859 factoradic ." "{ 1 1 0 3 0 1 0 }" } } ;

HELP: >permutation
{ $values { "factoradic" sequence } { "permutation" sequence } }
{ $description "Converts an integer represented in factoradic form into its corresponding unique permutation (0-based)." }
{ $notes "For clarification, the following two statements are equivalent:" { $code "10 factoradic >permutation" "{ 1 2 0 0 } >permutation" } }
{ $examples { $example "USING: math.combinatorics.private prettyprint ;" "{ 0 0 0 0 } >permutation ." "{ 0 1 2 3 }" } } ;

HELP: next-permutation
{ $values { "seq" sequence } }
{ $description "Rearranges the elements in " { $snippet "seq" } " into the lexicographically next greater permutation of elements." }
{ $notes "Performs an in-place modification of " { $snippet "seq" } "." }
{ $examples { $example "USING: math.combinatorics prettyprint ;" "\"ABC\" next-permutation ." "\"ACB\"" } } ;

HELP: all-unique-permutations
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Outputs a sequence containing all " { $strong "unique" } " permutations of " { $snippet "seq" } " in lexicographical order." }
{ $examples
    { $example "USING: math.combinatorics prettyprint ;"
        "{ 1 1 2 } all-unique-permutations ."
        "{ { 1 1 2 } { 1 2 1 } { 2 1 1 } }" }
} ;

HELP: each-unique-permutation
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ) } } }
{ $description "Applies the quotation to each " { $strong "unique" } " permutation of " { $snippet "seq" } " in order." } ;

HELP: all-subsets
{ $values { "seq" sequence } { "subsets" sequence } }
{ $description
    "Returns all the subsets of a sequence."
}
{ $examples
    { $example
        "USING: math.combinatorics prettyprint ;"
        "{ 1 2 3 } all-subsets ."
        "{ { } { 1 } { 2 } { 3 } { 1 2 } { 1 3 } { 2 3 } { 1 2 3 } }"
    }
} ;

HELP: all-selections
{ $values { "seq" sequence } { "n" integer } { "seq'" sequence } }
{ $description
    "Returns all the ways to take n (possibly the same) items from the "
    "sequence of items."
}
{ $examples
    { $example
        "USING: math.combinatorics prettyprint ;"
        "{ 1 2 } 2 all-selections ."
        "{ { 1 1 } { 1 2 } { 2 1 } { 2 2 } }"
    }
} ;

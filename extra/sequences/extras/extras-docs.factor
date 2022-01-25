USING: arrays help.markup help.syntax kernel math multiline
quotations sequences ;
IN: sequences.extras

HELP: pad-center
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "padded" "a new sequence" } }
{ $description "Outputs a new sequence consisting of " { $snippet "seq" } " padded on the left and right with enough repetitions of " { $snippet "elt" } " to have the result be of length " { $snippet "n" } "." }
{ $examples { $example "USING: io sequences sequences.extras ;" "{ \"ab\" \"quux\" } [ 5 CHAR: - pad-center print ] each" "-ab--\nquux-" } } ;

HELP: ?supremum
{ $values
    { "seq/f" { $maybe sequence } }
    { "elt/f" { $maybe object } }
}
{ $description "Outputs the greatest element of " { $snippet "seq" } ", ignoring any " { $link POSTPONE: f } " elements in it. If " { $snippet "seq" } " is empty or " { $link POSTPONE: f } ", returns " { $link POSTPONE: f } "." }
{ $examples
    { $example "USING: prettyprint sequences.extras ;"
    "{ 1 f 3 2 } ?supremum ."
    "3" }
} ;

HELP: ?infimum
{ $values
    { "seq/f" { $maybe sequence } }
    { "elt/f" { $maybe object } }
}
{ $description "Outputs the least element of " { $snippet "seq" } ", ignoring any " { $link POSTPONE: f } " elements in it. If " { $snippet "seq" } " is empty or " { $link POSTPONE: f } ", returns " { $link POSTPONE: f } "." }
{ $examples
    { $example "USING: prettyprint sequences.extras ;"
    "{ 1 f 3 2 } ?infimum ."
    "1" }
} ;

{ ?supremum ?infimum } related-words

HELP: 2count
{ $values
    { "seq1" sequence }
    { "seq2" sequence }
    { "quot" { $quotation ( ... elt1 elt2 -- ... ? ) } }
    { "n" integer } }
{ $description "Efficiently counts how many pairwise elements of " { $snippet "seq1" } " and " { $snippet "seq2" } " that the predicate quotation matches." }
{ $examples
    { $example "USING: kernel prettyprint sequences.extras ;" "{ 1 2 3 } { 3 2 1 } [ = ] 2count ." "1" } }
{ $see-also count } ;

HELP: 2each-index
{ $values
    { "seq1" sequence }
    { "seq2" sequence }
    { "quot" { $quotation ( ... elt1 elt2 index -- ... ) } } }
{ $description "Applies " { $snippet "quot" } " to each pair of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } ", providing the index of the elements at the top of the stack." }
{ $see-also 2each each-index } ;

HELP: 2map!
{ $values
    { "seq1" sequence }
    { "seq2" sequence }
    { "quot" { $quotation ( ... elt1 elt2 -- ... newelt ) } } }
{ $description "Applies the quotation to each pair of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } ", yielding a new element, and storing it back into " { $snippet "seq1" } ". Returns " { $snippet "seq1" } "." }
{ $see-also 2map map! } ;

HELP: 2map-index
{ $values
    { "seq1" sequence }
    { "seq2" sequence }
    { "quot" { $quotation ( ... elt1 elt2 index -- ... newelt ) } }
    { "newseq" sequence } }
{ $description "Calls the quotation with each pair of elements of the two sequences and their index on the stack, with the index on the top of the stack. Collects the outputs of the quotation and outputs them into a new sequence of the same type as the first sequence." }
{ $see-also 2map map-index } ;

HELP: count*
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "%" rational } }
{ $description "Outputs the fraction of elements in the sequence for which the predicate quotation matches." }
{ $examples { $example "USING: math ranges prettyprint sequences.extras ;" "100 [1..b] [ even? ] count* ." "1/2" } } ;

HELP: collapse
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "elt" object }
    { "seq'" sequence } }
{ $description "Generate a new sequence where all runs of elements for which the predicate returns true are replaced by a single instance of " { $snippet "elt" } "." }
{ $see-also compact }
{ $examples
    "Collapse multiple spaces in a string down to a single space"
    { $example "USING: kernel prettyprint sequences.extras ;" "\"   Hello,    crazy    world   \" [ CHAR: \\s = ] \" \" collapse ." "\" Hello, crazy world \"" } } ;

HELP: compact
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "elt" object }
    { "seq'" sequence } }
{ $description "Generate a new sequence where all runs of elements for which the predicate returns true are replaced by a single instance of " { $snippet "elt" } ". Runs at the beginning or end of the sequence for which the predicate returns true are removed." }
{ $see-also collapse }
{ $examples
    "Collapse multiple spaces in a string down to a single space"
    { $example "USING: kernel prettyprint sequences.extras ;" "\"   Hello,    crazy    world   \" [ CHAR: \\s = ] \" \" compact ." "\"Hello, crazy world\"" } } ;

HELP: <evens>
{ $values { "seq" sequence } { "evens" evens } }
{ $description "Create a virtual sequence whose elements consist of the even-indexed elements from the original sequence." }
{ $notes "Because sequences are zero-indexed, this collection includes the first, third, fifth, etc. elements of the actual sequence which can be counterintuitive." }
{ $see-also <odds> } ;

HELP: find-all
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "elts" "the indices of the matching elements" } }
{ $description "Similar to " { $link find } ", but finds all of the indices and elements that match the provided quotation, not just the first." }
{ $notes "The result is provided as an array of arrays, whose first value is the index and whose second value is the element." } ;

HELP: first=
{ $values
    { "seq" sequence }
    { "elt" object }
    { "?" boolean } }
{ $description "Checks whether the first element of " { $snippet "seq" } " is equal to " { $snippet "elt" } "." } ;

HELP: first?
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "?" boolean } }
{ $description "Tests whether the first element of " { $snippet "seq" } " satisfies the provided predicate." } ;

HELP: fourth=
{ $values
    { "seq" sequence }
    { "elt" object }
    { "?" boolean } }
{ $description "Checks whether the fourth element of " { $snippet "seq" } " is equal to " { $snippet "elt" } "." } ;

HELP: fourth?
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "?" boolean } }
{ $description "Tests whether the fourth element of " { $snippet "seq" } " satisfies the provided predicate." } ;

HELP: <odds>
{ $values { "seq" sequence } { "odds" odds } }
{ $description "Create a virtual sequence whose elements consist of the odd-indexed elements from the original sequence." }
{ $notes "Because sequences are zero-indexed, this collection includes the second, fourth, sixth, etc. elements of the actual sequence which can be counterintuitive." }
{ $see-also <evens> } ;

HELP: >resizable
{ $values { "seq" sequence } { "accum" sequence } }
{ $description "Converts a sequence into the nearest resizable equivalent, preserving its contents." } ;

HELP: second=
{ $values
    { "seq" sequence }
    { "elt" object }
    { "?" boolean } }
{ $description "Checks whether the second element of " { $snippet "seq" } " is equal to " { $snippet "elt" } "." } ;

HELP: second?
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "?" boolean } }
{ $description "Tests whether the second element of " { $snippet "seq" } " satisfies the provided predicate." } ;

HELP: subseq*
{ $values
     { "from" integer } { "to" integer } { "seq" sequence } { "subseq" sequence } }
{ $description "Outputs a new sequence using positions relative to one or both ends of the sequence. Positive values describes offsets relative to the start of the sequence, negative values relative to the end. Values of " { $link f } " for " { $snippet "from" } " indicate the beginning of the sequence, while an " { $link f } " for " { $snippet "to" } " indicates the end of the sequence." }
{ $notes "Both " { $snippet "from" } " and " { $snippet "to" } " can be safely set to values outside the length of the sequence. Also, " { $snippet "from" } " can safely reference a smaller or greater index position than " { $snippet "to" } "." }
{ $examples
    "Using a negative relative index:"
    { $example "USING: prettyprint sequences.extras ; 2 -1 \"abcdefg\" subseq* ."
               "\"cdef\""
    }
    "Using optional indices:"
    { $example "USING: prettyprint sequences.extras ; f -4 \"abcdefg\" subseq* ."
               "\"abc\""
    }
    "Using larger-than-necessary indices:"
    { $example "USING: prettyprint sequences.extras ; 0 10 \"abcdefg\" subseq* ."
               "\"abcdefg\""
    }
    "Trimming from either end of the sequence."
    { $example "USING: prettyprint sequences.extras ; 1 -1 \"abcdefg\" subseq* ."
               "\"bcdef\""
    }
} ;

HELP: third=
{ $values
    { "seq" sequence }
    { "elt" object }
    { "?" boolean } }
{ $description "Checks whether the third element of " { $snippet "seq" } " is equal to " { $snippet "elt" } "." } ;

HELP: third?
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "?" boolean } }
{ $description "Tests whether the third element of " { $snippet "seq" } " satisfies the provided predicate." } ;

HELP: unsurround
{ $values
    { "newseq" sequence }
    { "seq2" sequence }
    { "seq3" sequence }
    { "seq1" sequence } }
{ $description "Reverses the result of a " { $link surround } " call, stripping off the prefix " { $snippet "seq2" } " and suffix " { $snippet "seq3" } " to restore the original sequence " { $snippet "seq" } "." }
{ $see-also surround } ;

HELP: start-all
{ $values
     { "seq" sequence } { "subseq" sequence } { "indices" sequence } }
{ $description "Outputs the starting indices of the non-overlapping occurrences of " { $snippet "subseq" } " in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: prettyprint sequences.extras ;"
               "\"ABABA\" \"ABA\" start-all ."
               "{ 0 }"
    }
    { $example "USING: prettyprint sequences.extras ;"
               "\"ABAABA\" \"ABA\" start-all ."
      "{ 0 3 }"
    }
 } ;

HELP: start-all*
{ $values
    { "seq" sequence } { "subseq" sequence } { "indices" sequence } }
{ $description "Outputs the starting indices of the possibly overlapping occurrences of " { $snippet "subseq" } " in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: prettyprint sequences.extras ;"
               "\"ABABA\" \"ABA\" start-all* ."
               "{ 0 2 }"
    } } ;

HELP: arg-max
{ $values { "seq" sequence } { "n" integer } }
{ $description "Outputs the sequence with the largest item." } ;

HELP: arg-min
{ $values { "seq" sequence } { "n" integer } }
{ $description "Outputs the sequence with the smallest item." } ;

{ arg-max arg-min } related-words

HELP: count-subseq
{ $values
    { "seq" sequence } { "subseq" sequence } { "n" integer } }
{ $description "Outputs the number of non-overlapping occurrences of " { $snippet "subseq" } " in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: prettyprint sequences.extras ;"
               "\"ABABA\" \"ABA\" count-subseq ."
               "1"
    } } ;


HELP: count-subseq*
{ $values
    { "seq" sequence } { "subseq" sequence } { "n" integer } }
{ $description "Outputs the number of possibly overlapping occurrences of " { $snippet "subseq" } " in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: prettyprint sequences.extras ;"
               "\"ABABA\" \"ABA\" count-subseq* ."
               "2"
    } } ;

{ start-all start-all* count-subseq count-subseq* } related-words

HELP: loop>array
{ $values
    { "quot" quotation }
    { "array" array }
}
{ $description "Call the " { $snippet "quot" } ", which should output an object or " { $snippet "f" } ", and collect the objects in " { $snippet "array" } " until " { $snippet "quot" } " outputs " { $snippet "f" } "." }
{ $examples
    { $example "USING: sequences.extras prettyprint io.encodings.binary"
    "io.streams.byte-array io ;"
        "B{ 10 20 30 } binary ["
        "   [ read1 ] loop>array"
        "] with-byte-reader ."
        "{ 10 20 30 }"
    }
} ;

HELP: loop>array*
{ $values
    { "quot" quotation }
    { "array" array }
}
{ $description "Call the " { $snippet "quot" } ", which should output an object and a " { $snippet "bool" } ", and collect the objects in " { $snippet "array" } " until " { $snippet "quot" } " outputs " { $snippet "f" } ". Do collect the last object." }
{ $examples
    { $example "USING: sequences.extras prettyprint io.encodings.binary"
               "random random.mersenne-twister kernel math ;"
    "123 <mersenne-twister> ["
    "   ["
    "      10 random dup 5 >"
    "   ] loop>array* ."
    "] with-random"
    "{ 6 7 2 }"
    }
} ;

HELP: loop>array**
{ $values
    { "quot" quotation }
    { "array" array }
}
{ $description "Call the " { $snippet "quot" } ", which should output an object and a " { $snippet "bool" } ", and collect the objects in " { $snippet "array" } " until " { $snippet "quot" } " outputs " { $snippet "f" } ". Do not collect the last object." }
{ $examples
    { $example "USING: sequences.extras prettyprint io.encodings.binary"
               "random random.mersenne-twister kernel math ;"
    "123 <mersenne-twister> ["
    "   ["
    "      10 random dup 5 >"
    "   ] loop>array** ."
    "] with-random"
    "{ 6 7 }"
    }
} ;


HELP: loop>sequence
{ $values
    { "quot" quotation } { "exemplar" object }
    { "seq" sequence }
}
{ $description "Call " { $snippet "quot" } ", which should output an object or " { $snippet "f" } ", and collect the objects in " { $snippet "seq" } " of type " { $snippet "exemplar" } " until " { $snippet "quot" } " outputs " { $snippet "f" } "." }
{ $examples
    { $example "USING: sequences.extras prettyprint io.encodings.binary"
    "io.streams.byte-array io ;"
        "B{ 10 20 30 } binary ["
        "   [ read1 ] V{ } loop>sequence"
        "] with-byte-reader ."
        "V{ 10 20 30 }"
    }
} ;

HELP: loop>sequence*
{ $values
    { "quot" quotation } { "exemplar" object }
    { "seq" sequence }
}
{ $description "Call " { $snippet "quot" } ", which should output an object and a " { $snippet "bool" } ", and collect the objects in " { $snippet "seq" } " of type " { $snippet "exemplar" } " until " { $snippet "quot" } " outputs " { $snippet "f" } ". Do collect the last object." }
{ $examples
    { $example "USING: sequences.extras prettyprint io.encodings.binary"
               "random random.mersenne-twister kernel math ;"
    "! Get random numbers until one of them is greater than 5"
    "! but also output the last number"
    "123 <mersenne-twister> ["
    "   ["
    "      10 random dup 5 >"
    "   ] V{ } loop>sequence*"
    "] with-random ."
    "V{ 6 7 2 }"
    }
} ;

HELP: loop>sequence**
{ $values
    { "quot" quotation } { "exemplar" object }
    { "seq" sequence }
}
{ $description "Call " { $snippet "quot" } ", which should output an object and a " { $snippet "bool" } ", and collect the objects in " { $snippet "seq" } " of type " { $snippet "exemplar" } " until " { $snippet "quot" } " outputs " { $snippet "f" } ". Do not collect the last object." }
{ $examples
    { $example "USING: sequences.extras prettyprint io.encodings.binary"
               "random random.mersenne-twister kernel math ;"
    "! Get random numbers until one of them is greater than 5"
    "! but also output the last number"
    "123 <mersenne-twister> ["
    "   ["
    "      10 random dup 5 >"
    "   ] V{ } loop>sequence**"
    "] with-random ."
    "V{ 6 7 }"
    }
} ;

{
    loop>array loop>array* loop>array**
    loop>sequence loop>sequence* loop>sequence**
    zero-loop>array zero-loop>sequence
} related-words

HELP: zero-loop>array
{ $values
    { "quot" quotation }
    { "seq" sequence }
}
{ $description "Call " { $snippet "quot" } ", which takes an integer starting from zero and incrementing on every loop, and should output an object, and collect the objects in " { $snippet "array" } " until " { $snippet "quot" } " outputs " { $snippet "f" } "." }
{ $examples
    "Example:"
    { $example "USING: sequences.extras prettyprint math.text.english math kernel ;"
        "[ dup 5 < [ number>text ] [ drop f ] if ] zero-loop>array ."
        [[ { "zero" "one" "two" "three" "four" }]]
    }
} ;

HELP: zero-loop>sequence
{ $values
    { "quot" quotation } { "exemplar" object }
    { "seq" sequence }
}
{ $description "Call the " { $snippet "quot" } ", which takes an integer starting from zero and incrementing on every loop, and should output an object or " { $snippet "f" } ", and collect the objects in " { $snippet "array" } " until " { $snippet "quot" } " outputs " { $snippet "f" } "." }
{ $examples
    "Example:"
    { $example "USING: sequences.extras prettyprint math.text.english math kernel ;"
        "[ dup 5 < [ number>text ] [ drop f ] if ] V{ } zero-loop>sequence ."
        [[ V{ "zero" "one" "two" "three" "four" }]]
    }
} ;

HELP: find-pred
{ $values seq: sequence quot: quotation pred: quotation calc/f: object i/f: object elt/f: object }
{ $description A version of \ find that saves the calculation done by the first quotation and returns the calulation, element, and index if the calculation matches a predicate quotation. }
{ $examples
    [=[ USING: math kernel sequences.extras prettyprint ;
        { 4 5 6 } [ sq ] [ 20 > ] find-pred [ . ] tri@
        25\n5\n1
    ]=]
} ;

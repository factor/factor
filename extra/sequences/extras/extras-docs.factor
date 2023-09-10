USING: arrays help.markup help.syntax kernel math multiline
quotations sequences vectors assocs strings ;
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

HELP: percent-of
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "%" rational } }
{ $description "Outputs the fraction of elements in the sequence for which the predicate quotation matches." }
{ $examples { $example "USING: math ranges prettyprint sequences.extras ;" "100 [1..b] [ even? ] percent-of ." "1/2" } } ;

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
{ $description "Outputs the index of the element with the largest value in " { $snippet "seq" } "." } ;

HELP: arg-min
{ $values { "seq" sequence } { "n" integer } }
{ $description "Outputs the index of the element with the smallest value in " { $snippet "seq" } "." } ;

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

HELP: (collect-with-previous)
{ $values
    { "quot" quotation } { "into" object }
    { "quot'" quotation }
} ;

HELP: (each-integer-with-previous)
{ $values
    { "prev" object } { "i" integer } { "n" integer } { "quot" quotation }
} ;

HELP: (start-all)
{ $values
    { "seq" sequence } { "subseq" object } { "increment" object }
    { "indices" object }
} ;

HELP: 2map-into
{ $values
    { "seq1" sequence } { "seq2" sequence } { "quot" quotation } { "into" object }
}
{ $description "Applies the quotation to each pair of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "into" } "." } ;

HELP: 2map-sum
{ $values
    { "seq1" sequence } { "seq2" sequence } { "quot" quotation }
    { "n" integer }
}
{ $description "Applies the quotation to each pair of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } ". The resulting sequence is summed." } ;

HELP: 2nested-each
{ $values
    { "seq1" sequence } { "seq2" sequence } { "quot" quotation }
}
{ $description "Applies quotation to all pairs of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } ". Order is the same as a nested for loop." } ;

HELP: 2nested-map
{ $values
    { "seq1" sequence } { "seq2" sequence } { "quot" quotation }
    { "seq" sequence }
}
{ $description "Applies quotation to all pairs of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } ", yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } ". Order is the same as a nested for loop." } ;

HELP: 3each-from
{ $values
    { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" quotation } { "i" integer }
} ;

HELP: 3map-reduce
{ $values
    { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "map-quot" object } { "reduce-quot" object }
    { "result" object }
}
{ $description "Applies " { $snippet "map-quot" } " to each triple of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } ". The resultant sequence is then reduced with " { $snippet "reduce-quot" } "." } ;

HELP: 3nested-each
{ $values
    { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" quotation }
}
{ $description "Applies quotation to all triples of elements from " { $snippet "seq1" } ", " { $snippet "seq2" } " and " { $snippet "seq3" } ". Order is the same as a nested for loop." } ;

HELP: 3nested-map
{ $values
    { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" quotation }
    { "seq" sequence }
}
{ $description "Applies quotation to all triples of elements from " { $snippet "seq1" } ", " { $snippet "seq2" } " and " { $snippet "seq3" } " in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } ". Order is the same as a nested for loop." } ;

HELP: <step-slice>
{ $values
    { "from/f" { $maybe integer } } { "to/f" { $maybe integer } } { "step" object } { "seq" sequence }
    { "step-slice" slice }
}
{ $description "Outputs a new virtual sequence sharing storage with the subrange of elements in " { $snippet "seq" } " with indices starting from and including " { $snippet "from/f" } ", and up to but not including " { $snippet "to/f" } ", with step " { $snippet "step" } "."
  $nl
  "If " { $link f } "is given in place of " { $snippet "from/f" } ", it is taken as 0."
  $nl
  "If " { $link f } "is given in place of " { $snippet "to/f" } ", it is taken as the length of " { $snippet "seq" } "." }
;

HELP: <zip-index>
{ $values
    { "seq" sequence }
    { "virtual-zip-index" object }
}
{ $description "Outputs a new virtual sequence which pairs the elements of " { $snippet "seq" } " with their 0-based indices." } ;

HELP: >string-list
{ $values
    { "seq" sequence }
    { "seq'" sequence }
}
{ $description "Surrounds each element of " { $snippet "seq" } " in quotes and joins the sequence with commas."  } ;

HELP: ?<slice>
{ $values
    { "from/f" { $maybe integer } } { "to/f" { $maybe integer } } { "sequence" sequence }
    { "slice" slice }
}
{ $description "Outputs a new virtual sequence sharing storage with the subrange of elements in " { $snippet "seq" } " with indices starting from and including " { $snippet "from/f" } ", and up to but not including " { $snippet "to/f" } ". If either of these is not specified, they are substituted with the array's bounds: 0 and its length." } ;

HELP: ?first2
{ $values
    { "seq" sequence }
    { "first/f" object } { "second/f" object }
}
{ $description "Pushes the first two elements of " { $snippet "seq" } ". Pushes " { $snippet "f" } " for missing elements." } ;

HELP: ?first3
{ $values
    { "seq" sequence }
    { "first/f" object } { "second/f" object } { "third/f" object }
}
{ $description "Pushes the first three elements of " { $snippet "seq" } ". Pushes " { $snippet "f" } " for missing elements." } ;

HELP: ?first4
{ $values
    { "seq" sequence }
    { "first/f" object } { "second/f" object } { "third/f" object } { "fourth/f" object }
}
{ $description "Pushes the first four elements of " { $snippet "seq" } ". Pushes " { $snippet "f" } " for missing elements." } ;

HELP: ?heap-pop-value>array
{ $values
    { "heap" object }
    { "array" array }
}
{ $description "Pushes the value at the top of " { $snippet "heap" } " as a single element array. Returns an empty array if the heap is empty." } ;

HELP: ?span-slices
{ $values
    { "slice1/f" { $maybe slice } } { "slice2/f" { $maybe slice } }
    { "slice" slice }
}
{ $description "Create a virtual sequence spanning the length covered by " { $snippet "slice1" } " and " { $snippet "slice2" } ". Slices must refer to the same sequence. If " { $snippet "f" } "is one of the inputs, it is omitted." } ;

HELP: ?trim
{ $values
    { "seq" sequence } { "quot" quotation }
    { "seq/newseq" object }
}
{ $description "Similar to " { $link trim } ", but sequences that do not require trimming are left as is." } ;

HELP: ?trim-head
{ $values
    { "seq" sequence } { "quot" quotation }
    { "seq/newseq" object }
}
{ $description "Similar to " { $link trim-head } ", but sequences that do not require trimming are left as is." } ;

HELP: ?trim-tail
{ $values
    { "seq" sequence } { "quot" quotation }
    { "seq/newseq" object }
}
{ $description "Similar to " { $link trim-tail } ", but sequences that do not require trimming are left as is." } ;

HELP: all-longest
{ $values
    { "seqs" object }
    { "seqs'" object }
}
{ $description "Pushes a sequence containing all of the sequences in " { $snippet "seqs" } " that have the longest length." } ;

HELP: all-rotations
{ $values
    { "seq" sequence }
    { "seq'" sequence }
}
{ $description "Pushes a sequence containing all the rotations of " { $snippet "seq" } ", including the original array." } ;

HELP: all-shortest
{ $values
    { "seqs" object }
    { "seqs'" object }
}
{ $description "Pushes a sequence containing all of the sequences in " { $snippet "seqs" } " that have the shortest length." } ;

HELP: all-subseqs
{ $values
    { "seq" sequence }
    { "seqs" object }
}
{ $description "Pushes a sequence containing all subsequences in " { $snippet "seq" } " excluding the empty sequence." } ;

HELP: appender
{ $values
    { "quot" quotation }
    { "appender" quotation } { "accum" vector }
}
{ $description "Given a quotation " { $snippet "quot" } ", creates an appender quotation and empty vector to append new sequences to it. The appender quotation will apply " { $snippet "quot" } " to its argument before appending it to the vector." } ;

HELP: appender-for
{ $values
    { "quot" quotation } { "exemplar" object }
    { "appender" object } { "accum" object }
}
{ $description "Given a quotation " { $snippet "quot" } ", creates an appender quotation and empty vector with a maximum storage limit the size of " { $snippet "exemplar" } ". The appender quotation will apply " { $snippet "quot" } " to its argument before appending it to the vector." } ;

HELP: arg-sort
{ $values
    { "seq" sequence }
    { "indices" object }
}
{ $description "Given a sequence " { $snippet "seq" } ", push a sequence of indices that when indexed into, sort the given sequence." } ;

HELP: arg-where
{ $values
    { "seq" sequence } { "quot" quotation }
    { "indices" object }
}
{ $description "Push a sequence of all indices in " { $snippet "seq" } " where " { $snippet "quot" } "applied to the element at each index is true." } ;

HELP: assoc-zip-with
{ $values
    { "quot" quotation } { "alist" "an array of key/value pairs" }
}
{ $description "Applies " { $snippet "quot" } " to each key-value pair in the given assoc, pushing a new assoc with the key-value pairs as keys, and the values computed by " { $snippet "quot" } " as values." } ;

HELP: change-last
{ $values
    { "seq" sequence } { "quot" quotation }
}
{ $description "Applies " { $snippet "quot" } " to the last element of a sequence, modifying it in place." } ;

HELP: change-last-unsafe
{ $values
    { "seq" sequence } { "quot" quotation }
}
{ $description "Applies " { $snippet "quot" } " to the last element of a sequence, modifying it in place. Does not check if the array has a last element." } ;

HELP: change-nths
{ $values
    { "indices" object } { "seq" sequence } { "quot" quotation }
}
{ $description "Applies " { $snippet "quot" } " to the locations present in " { $snippet "indices" } " in sequence " { $snippet "seq" } ", modifying it in place." } ;

HELP: collect-with-previous
{ $values
    { "n" integer } { "quot" quotation } { "into" object }
} ;

HELP: count-head
{ $values
    { "seq" sequence } { "quot" quotation }
    { "n" integer }
}
{ $description "Count the number of values at the beginning of " { $snippet "seq" } " that return a truthy value when passed into " { $snippet "quot" } "." } ;

HELP: count-tail
{ $values
    { "seq" sequence } { "quot" quotation }
    { "n" integer }
}
{ $description "Count the number of values from the end of " { $snippet "seq" } " that return a truthy value when passed into " { $snippet "quot" } "." } ;

HELP: count=
{ $values
    { "seq" sequence } { "quot" quotation } { "n" integer }
    { "?" boolean }
}
{ $description "Returns " { $link t } " if the sequence has exactly " { $snippet "n" } " elements where " { $snippet "quot" } " returns true, otherwise returns " { $link f } "." } ;


HELP: cut-when
{ $values
    { "seq" sequence } { "quot" quotation }
    { "before" object } { "after" object }
}
{ $description "Cut the given sequence before the first element of " { $snippet "seq" } " that returns a truthy value when passed into " { $snippet "quot" } "." } ;

HELP: drop-while
{ $values
    { "seq" sequence } { "quot" quotation }
    { "tail-slice" object }
}
{ $description "Remove all values at the beginning of " { $snippet "seq" } " that return a truthy value when passed into " { $snippet "quot" } ". Return a virtual sequence containing those elements." } ;

HELP: each-index-from
{ $values
    { "seq" sequence } { "quot" quotation } { "i" integer }
} ;

HELP: each-integer-with-previous
{ $values
    { "n" integer } { "quot" quotation }
} ;

HELP: each-prior
{ $values
    { "seq" sequence } { "quot" quotation }
} ;

HELP: each-subseq
{ $values
    { "seq" sequence } { "quot" quotation }
} ;

HELP: ensure-same-underlying
{ $values
    { "slice1" slice } { "slice2" slice }
} ;

HELP: even-indices
{ $values
    { "seq" sequence }
    { "seq'" sequence }
}
{ $description "Push a sequence containing the even-indexed elements in " { $snippet "seq" } "." } ;

HELP: evens
{ $class-description "The class of virtual sequences which contain the even-indexed elements of a given sequence." } ;

HELP: extract!
{ $values
    { "seq" sequence } { "quot" quotation }
} ;

HELP: filter-all-subseqs
{ $values
    { "seq" sequence } { "quot" quotation }
}
{ $description "Perform a filter on all the subsequences of the given sequence, and push a sequence containing the subsequences that satisfy the condition given by " { $snippet "quot" } "." } ;

HELP: filter-all-subseqs-range
{ $values
    { "seq" sequence } { "range" object } { "quot" quotation }
}
{ $description "Perform a filter on all the subsequences of the given sequence that have length within " { $snippet "range" } ", and push a sequence containing the subsequences that satisfy the condition given by " { $snippet "quot" } "." } ;

HELP: filter-index
{ $values
    { "seq" sequence } { "quot" quotation }
    { "seq'" sequence }
}
{ $description "Perform a " { $link filter } " on the given sequence, with the index provided as an additional argument to " { $snippet "quot" } "." } ;

HELP: filter-index-as
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" object }
    { "seq'" sequence }
}
{ $description "Perform a " { $link filter-as } " on the given sequence, with the index provided as an additional argument to " { $snippet "quot" } ". Outputs a sequence of the same class as " { $snippet "exemplar" } "." } ;

HELP: filter-length
{ $values
    { "seq" sequence } { "n" integer }
    { "seq'" sequence }
}
{ $description "Push a sequence that contains all elements of " { $snippet "seq" } " that have length " { $snippet "n" } "." } ;

HELP: filter-map
{ $values
    { "seq" sequence } { "filter-quot" object } { "map-quot" object }
    { "newseq" sequence }
}
{ $description "Filter the given sequence with " { $snippet "filter-quot" } ", then perform a map on the filtered sequence with " { $snippet "map-quot" } "." } ;

HELP: filter-map-as
{ $values
    { "seq" sequence } { "filter-quot" object } { "map-quot" object } { "exemplar" object }
    { "newseq" sequence }
}
{ $description "Filter the given sequence with " { $snippet "filter-quot" } ", then perform a map on the filtered sequence with " { $snippet "map-quot" } ". Outputs a sequence of the same class as " { $snippet "exemplar" } "." } ;

HELP: find-last-index
{ $values
    { "seq" sequence } { "quot" quotation }
    { "i" integer } { "elt" object }
}
{ $description "A simpler variant of " { $link find-last-index-from } ", with starting index set to 0." } ;

HELP: find-last-index-from
{ $values
    { "n" integer } { "seq" sequence } { "quot" quotation }
    { "i" integer } { "elt" object }
}
{ $description "Similar to " { $snippet "find-from" } ", except " { $snippet "quot" } " is given the index of each element, and the index of the found element is pushed along with the found element." } ;

HELP: find-pred-loop
{ $values
    { "i" integer } { "n" integer } { "seq" sequence } { "quot" quotation }
    { "calc/f" object } { "i/f" { $maybe integer } } { "elt/f" object }
} ;

HELP: harvest!
{ $values
    { "seq" sequence }
    { "newseq" sequence }
}
{ $description "Outputs a new sequence with all empty sequences removed. Modifies " { $snippet "seq" } "in place." } ;

HELP: harvest-as
{ $values
    { "seq" sequence } { "exemplar" object }
    { "newseq" sequence }
}
{ $description "Outputs a new sequence with all empty sequences removed. Resulting sequence is the same class as " { $snippet "exemplar" } "." } ;

HELP: head*-as
{ $values
    { "seq" sequence } { "n" integer } { "exemplar" object }
    { "seq'" sequence }
}
{ $description "A version of " { $link head* } " where " { $snippet "seq'" } " is the same class as " { $snippet "exemplar" } "." } ;

HELP: head-as
{ $values
    { "seq" sequence } { "n" integer } { "exemplar" object }
    { "seq'" sequence }
}
{ $description "A version of " { $link head } " where " { $snippet "seq'" } " is the same class as " { $snippet "exemplar" } "." } ;

HELP: heap>pairs
{ $values
    { "heap" object }
    { "pairs" object }
}
{ $description "Collect the pairs inside a heap into a sequence. Ordering of the sequence is based on the ordering of the heap." } ;

HELP: index-selector
{ $values
    { "quot" quotation }
    { "selector" object } { "accum" object }
} ;

HELP: index-selector-as
{ $values
    { "quot" quotation } { "exemplar" object }
    { "selector" object } { "accum" object }
} ;

HELP: infimum-by*
{ $values
    { "seq" sequence } { "quot" quotation }
    { "i" integer } { "elt" object }
}
{ $description "A variant of " { $link infimum-by } " that pushes the index of the least element along with the least element." } ;

HELP: insert-nth!
{ $values
    { "elt" object } { "n" integer } { "seq" sequence }
}
{ $description "A variant of " { $link insert-nth } " that modifies " { $snippet "seq" } " in place." } ;

HELP: interleaved
{ $values
    { "seq" sequence } { "glue" object }
    { "newseq" sequence }
}
{ $description "Insert " { $link glue } " between every pair of elements in " { $snippet "seq" } "." } ;

HELP: interleaved-as
{ $values
    { "seq" sequence } { "glue" object } { "exemplar" object }
    { "newseq" sequence }
}
{ $description "Insert " { $link glue } " between every pair of elements in " { $snippet "seq" } ". Resulting sequence will be the same class as " { $snippet "exemplar" } "." } ;

HELP: iterate-heap-while
{ $values
    { "heap" object } { "quot1" quotation } { "quot2" quotation }
    { "obj/f" { $maybe object } } { "loop?" object }
} ;

HELP: last=
{ $values
    { "seq" sequence } { "elt" object }
    { "?" boolean }
}
{ $description "Check if the last element of " { $snippet "seq" } " is equal to " { $snippet "elt" } "." } ;

HELP: last?
{ $values
    { "seq" sequence } { "quot" quotation }
    { "?" boolean }
}
{ $description "Check if the last element of " { $snippet "seq" } " satisfies the condition given by " { $snippet "quot" } "." } ;

HELP: longest-subseq
{ $values
    { "seq1" sequence } { "seq2" sequence }
    { "subseq" object }
}
{ $description "Pushes the longest subsequence of " { $snippet "seq" } "." } ;

HELP: map-concat
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence }
}
{ $description "Perform a " { $link map } " on the given sequence with " { $snippet "quot" } ", then perform a " { $link concat } " on the result." } ;

HELP: map-concat-as
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" object }
    { "newseq" sequence }
}
{ $description "A version of " { $link map-concat } " where the resultant sequence has the same class as " { $snippet "exemplar" } } ;

HELP: map-filter
{ $values
    { "seq" sequence } { "map-quot" object } { "filter-quot" object }
    { "subseq" object }
}
{ $description "Perform a " { $link map } " on the given sequence with " { $snippet "map-quot" } ", then perform a " { $link filter } " on the result with " { $snippet "filter-quot" } "." } ;

HELP: map-filter-as
{ $values
    { "seq" sequence } { "map-quot" object } { "filter-quot" object } { "exemplar" object }
    { "subseq" object }
}
{ $description "A version of " { $link map-filter } " where the resultant sequence has the same class as " { $snippet "exemplar" } } ;

HELP: map-find-index
{ $values
    { "seq" sequence } { "quot" quotation }
    { "result" object } { "i" integer } { "elt" object }
}
{ $description "A version of " { $link map-find } " where the index of the found element, if any, is returned." } ;

HELP: map-find-last-index
{ $values
    { "seq" sequence } { "quot" quotation }
    { "result" object } { "i" integer } { "elt" object }
}
{ $description "A version of " { $link map-find-index } " where the index of the found element, if any, is returned." } ;

HELP: map-from
{ $values
    { "seq" sequence } { "quot" quotation } { "from" integer }
    { "newseq" sequence }
}
{ $description "A version of " { $link map } " that maps the slice of " { $snippet "seq" } " beginning at index " { $snippet "i" } "." } ;

HELP: map-from-as
{ $values
    { "seq" sequence } { "quot" quotation } { "from" integer } { "exemplar" object }
    { "newseq" sequence }
}
{ $description "A version of " { $link map-from } " where the resultant sequence has the same class as " { $snippet "exemplar" } } ;

HELP: map-harvest
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence }
}
{ $description "A version of " { $link map } " with all empty sequences removed from the result." } ;

HELP: map-if
{ $values
    { "seq" sequence } { "if-quot" object } { "map-quot" object }
    { "newseq" sequence }
}
{ $description "A version of " { $link map } " where " { $snippet "map-quot" } " is applied only if " { $snippet "if-quot" } " returns true for a given element." } ;

HELP: map-index!
{ $values
    { "seq" sequence } { "quot" quotation }
}
{ $description "A version of " { $link map-index } " which modifies " { $snippet "seq" } " in place." } ;

HELP: map-integers-with
{ $values
    { "len" object } { "quot" quotation } { "exemplar" object }
    { "newseq" sequence }
} ;

HELP: map-like
{ $values
    { "seq" sequence } { "exemplar" object }
    { "seq'" sequence }
} ;

HELP: map-prior
{ $values
    { "seq" sequence } { "quot" quotation }
    { "seq'" sequence }
} ;

HELP: map-prior-as
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" object }
    { "seq'" sequence }
} ;

HELP: map-product
{ $values
    { "seq" sequence } { "quot" quotation }
    { "n" integer }
}
{ $description "Like " { $code "map product" } ", but without creating an intermediate sequence." } ;

HELP: map-sift
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence }
}
{ $description "A version of " { $link map } " with all instances of " { $link f } " removed from the result." } ;

HELP: map-with-previous
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence }
} ;

HELP: map-with-previous-as
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" object }
    { "newseq" sequence }
} ;

HELP: map-zip-swap
{ $values
    { "quot" quotation }
    { "alist" "an array of key/value pairs" }
} ;

HELP: max-subarray-sum
{ $values
    { "seq" sequence }
    { "sum" object }
}
{ $description "Output the maximum subarray sum of the sequence." } ;

HELP: merge-slices
{ $values
    { "slice1" slice } { "slice2" slice }
    { "slice/*" object }
} ;

HELP: nth-of
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" "the element at the " { $snippet "n" } "th index" } }
{ $contract "Outputs the " { $snippet "n" } "th element of the sequence. Elements are numbered from zero, so the last element has an index one less than the length of the sequence. All sequences support this operation." }
{ $errors "Throws a " { $link bounds-error } " if the index is negative, or greater than or equal to the length of the sequence." } ;

HELP: nth*
{ $values
    { "n" integer } { "seq" sequence }
    { "elt" object }
}
{ $description "Pushes the nth element of the sequence if it exists, otherwise pushes sequence length - 1." } ;

HELP: nth=
{ $values
    { "n" integer } { "seq" sequence } { "elt" object }
    { "?" boolean }
}
{ $description "Check if the nth element of " { $snippet "seq" } " is equal to " { $snippet "elt" } "." } ;

HELP: nth?
{ $values
    { "n" integer } { "seq" sequence } { "quot" quotation }
    { "?" boolean }
}
{ $description "Check if the nth element of " { $snippet "seq" } " satisfies the condition given by " { $snippet "quot" } "." } ;

HELP: ??nth
{ $values { "n" integer } { "seq" sequence } { "elt/f" { $maybe object } } { "?" boolean } }
{ $description "A forgiving version of " { $link nth } ". If the index is out of bounds, or if the sequence is " { $link f } ", simply outputs " { $link f } ". Also outputs a boolean to distinguish between the sequence containing an " { $link f } " or an out of bounds index." } ;

HELP: odd-indices
{ $values
    { "seq" sequence }
    { "seq'" sequence }
}
{ $description "Push a sequence containing the odd-indexed elements in " { $snippet "seq" } "." } ;

HELP: odds
{ $class-description "The class of virtual sequences which contain the odd-indexed elements of a given sequence." } ;

HELP: one?
{ $values
    { "seq" sequence } { "quot" quotation }
    { "?" boolean }
} ;

HELP: ordered-slices-overlap?
{ $values
    { "slice-lt" object } { "slice-gt" object }
    { "?" boolean }
} ;

HELP: ordered-slices-range
{ $values
    { "slice-lt" object } { "slice-gt" object }
    { "to" integer } { "from" integer }
} ;

HELP: ordered-slices-touch?
{ $values
    { "slice-lt" object } { "slice-gt" object }
    { "?" boolean }
} ;

HELP: pad-longest
{ $values
    { "seq1" sequence } { "seq2" sequence } { "elt" object }
}
{ $description "Perform " { $link pad-tail } " on both sequences, padding with " { $snippet "elt" } " to the longest length between the two." } ;

HELP: prepend-lines-with-spaces
{ $values
    { "str" string }
    { "str'" string }
}
{ $description "Prepend four spaces to each line in " { $snippet "str" } "." } ;

HELP: push-if*
{ $values
    { "elt" object } { "quot" quotation } { "accum" object }
} ;

HELP: push-if-index
{ $values
    { "elt" object } { "i" integer } { "quot" quotation } { "accum" object }
} ;

HELP: reduce-from
{ $values
    { "seq" sequence } { "identity" object } { "quot" quotation } { "from" integer }
    { "result" object }
} ;

HELP: remove-first
{ $values
    { "obj" object } { "seq" sequence }
    { "seq'" sequence }
}
{ $description "Remove the first occurrence of " { $snippet "obj" } " in  " { $snippet "seq" } "." } ;

HELP: remove-first!
{ $values
    { "obj" object } { "seq" sequence }
}
{ $description "A version of " { $link remove-first } " that modifies " { $snippet "seq" } " in place." } ;

HELP: remove-last
{ $values
    { "obj" object } { "seq" sequence }
    { "seq'" sequence }
}
{ $description "Remove the last occurrence of " { $snippet "obj" } " in  " { $snippet "seq" } "." } ;

HELP: remove-last!
{ $values
    { "obj" object } { "seq" sequence }
}
{ $description "A version of " { $link remove-last } " that modifies " { $snippet "seq" } " in place." } ;

HELP: replicate-into
{ $values
    { "seq" sequence } { "quot" quotation }
} ;

HELP: reverse-as
{ $values
    { "seq" sequence } { "exemplar" object }
    { "newseq" sequence }
}
{ $description "A version of " { $link reverse } " where " { $snippet "seq'" } " is the same class as " { $snippet "exemplar" } "." } ;

HELP: rotate
{ $values
    { "seq" sequence } { "n" integer }
    { "seq'" sequence }
}
{ $description "Move the first " { $snippet "n" } " elements of " { $snippet "seq" } " to the end." } ;

HELP: rotate!
{ $values
    { "seq" sequence } { "n" integer }
}
{ $description "A version of " { $link rotate } " that modifies " { $snippet "seq" } " in place." } ;

HELP: round-robin
{ $values
    { "seq" sequence }
    { "newseq" sequence }
}
{ $description "List all elements of " { $snippet "seq" } " in column-major order." } ;

HELP: safe-subseq
{ $values
    { "from" integer } { "to" integer } { "seq" sequence }
    { "subseq" object }
}
{ $description "A safe version of " { $link subseq } "." } ;

HELP: selector*
{ $values
    { "quot" quotation }
    { "selector" object } { "accum" object }
} ;

HELP: selector-as*
{ $values
    { "quot" quotation } { "exemplar" object }
    { "selector" object } { "accum" object }
} ;

HELP: sequence-index-operator-last
{ $values
    { "n" integer } { "seq" sequence } { "quot" quotation }
    { "quot'" quotation }
} ;

HELP: sequence>slice
{ $values
    { "sequence" sequence }
    { "slice" slice }
}
{ $description "Create a virtual sequence that represents the given sequence." } ;

HELP: set-nths
{ $values
    { "value" object } { "indices" object } { "seq" sequence }
}
{ $description "Set the elements at all given indices to " { $snippet "value" } ". modifies " { $snippet "seq" } " in place." } ;

HELP: set-nths-unsafe
{ $values
    { "value" object } { "indices" object } { "seq" sequence }
}
{ $description "Unsafe version of " { $link set-nths } } ;

HELP: shorten*
{ $values
    { "vector" object } { "n" integer }
    { "seq" sequence }
} ;

HELP: sift!
{ $values
    { "seq" { "a resizable mutable " { $link sequence } } }
    { "seq'" { "a resizable mutable " { $link sequence } } }
}
{ $description "Removes all instances of " { $link f } " from a sequence." }
{ $notes "The sequence " { $snippet "seq" } " MUST be growable. See " { $link "growable" } "." }
{ $side-effects "seq" }
{ $examples
    { $example
        "USING: prettyprint sequences.extras ;"
        "V{ 2 f \"a\" f { } f } sift! ."
        "V{ 2 \"a\" { } }"
    }
}
{ $see-also sift filter! filter harvest! harvest } ;

HELP: sift-as
{ $values
    { "seq" sequence } { "exemplar" object }
    { "newseq" sequence }
} ;

HELP: slice-order-by-from
{ $values
    { "slice1" slice } { "slice2" slice }
    { "slice-lt" object } { "slice-gt" object }
} ;

HELP: slice-when
{ $values
    { "seq" sequence } { "quot" quotation }
    { "seq'" sequence }
} ;

HELP: slices-don't-touch
{ $values
    { "slice1" slice } { "slice2" slice }
}
{ $description "Throws a " { $link slices-don't-touch } " error." }
{ $error-description "" } ;

HELP: slices-overlap?
{ $values
    { "slice1" slice } { "slice2" slice }
    { "?" boolean }
} ;

HELP: slices-touch?
{ $values
    { "slice1" slice } { "slice2" slice }
    { "?" boolean }
} ;

HELP: slurp-heap-while-map
{ $values
    { "heap" object } { "quot1" quotation } { "quot2" quotation }
    { "seq" sequence }
} ;

HELP: span-slices
{ $values
    { "slice1" slice } { "slice2" slice }
    { "slice" slice }
}
{ $description "Create a virtual sequence spanning the length covered by " { $snippet "slice1" } " and " { $snippet "slice2" } ". Slices must refer to the same sequence." } ;

HELP: supremum-by*
{ $values
    { "seq" sequence } { "quot" quotation }
    { "i" integer } { "elt" object }
} ;

HELP: tail*-as
{ $values
    { "seq" sequence } { "n" integer } { "exemplar" object }
    { "seq'" sequence }
} ;

HELP: tail-as
{ $values
    { "seq" sequence } { "n" integer } { "exemplar" object }
    { "seq'" sequence }
} ;

HELP: take-while
{ $values
    { "seq" sequence } { "quot" quotation }
    { "head-slice" object }
} ;

HELP: trim-as
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" object }
    { "newseq" sequence }
} ;

HELP: underlying-mismatch
{ $values
    { "slice1" slice } { "slice2" slice }
}
{ $description "Throws an " { $link underlying-mismatch } " error." }
{ $error-description "" } ;

HELP: unordered-slices-overlap?
{ $values
    { "slice1" slice } { "slice2" slice }
    { "?" boolean }
} ;

HELP: unordered-slices-range
{ $values
    { "slice1" slice } { "slice2" slice }
    { "to" integer } { "from" integer }
} ;

HELP: unordered-slices-touch?
{ $values
    { "slice1" slice } { "slice2" slice }
    { "?" boolean }
} ;

HELP: until-empty
{ $values
    { "seq" sequence } { "quot" quotation }
} ;

HELP: with-string-lines
{ $values
    { "str" string } { "quot" quotation }
    { "str'" string }
} ;

HELP: exchange-subseq
{ $values
    { "len" { "a non-negative " { $link integer } } }
    { "pos1" { "a non-negative " { $link integer } } }
    { "pos2" { "a non-negative " { $link integer } } }
    { "seq" { "a mutable " { $link sequence } } }
}
{ $description "Exchanges the contents of subsequences "
{ $snippet "[pos1, pos1+len)" } " and " { $snippet "[pos2, pos2+len)" } " in "
{ $snippet "seq" } ". Overlapping ranges are allowed. If either of the ranges exceeds the "
{ $snippet "seq" } " length, throws an error before any modifications take place. If "
{ $snippet "len" } " = 1, the behavior is equivalent to " { $link exchange } "." }
{ $examples
    "Non-overlapping ranges:"
    { $example "USING: kernel sequences.extras prettyprint ;"
        "2 0 3 \"01_34_\" [ exchange-subseq ] keep ."
        "\"34_01_\""
    }
    "Overlapping ranges:"
    { $example "USING: kernel sequences.extras prettyprint ;"
        "3 0 2 \"abcdef\" [ exchange-subseq ] keep ."
        "\"cdebaf\""
    }
}
{ $side-effects "seq" }
{ $see-also exchange } ;

USING: help.markup help.syntax kernel sequences strings ;
IN: grouping

ARTICLE: "grouping" "Groups and clumps"
"Splitting a sequence into disjoint, fixed-length subsequences:"
{ $subsections group }
"A virtual sequence for splitting a sequence into disjoint, fixed-length subsequences:"
{ $subsections groups <groups> }
"Splitting a sequence into overlapping, fixed-length subsequences:"
{ $subsections clump }
"Splitting a sequence into overlapping, fixed-length subsequences, wrapping around the end of the sequence:"
{ $subsections circular-clump }
"A virtual sequence for splitting a sequence into overlapping, fixed-length subsequences:"
{ $subsections clumps <clumps> }
"A virtual sequence for splitting a sequence into overlapping, fixed-length subsequences, wrapping around the end of the sequence:"
{ $subsections circular-clumps <circular-clumps> }
"The difference can be summarized as the following:"
{ $list
    { "With groups, the subsequences form the original sequence when concatenated:"
        { $example
            "USING: grouping prettyprint ;"
            "{ 1 2 3 4 } 2 group ."
            "{ { 1 2 } { 3 4 } }"
        }
        { $example
            "USING: grouping prettyprint sequences ;"
            "{ 1 2 3 4 } dup"
            "2 <groups> concat sequence= ."
            "t"
        }
    }
    { "With clumps, collecting the first element of each subsequence but the last one, together with the last subsequence, yields the original sequence:"
        { $example
            "USING: grouping prettyprint ;"
            "{ 1 2 3 4 } 2 clump ."
            "{ { 1 2 } { 2 3 } { 3 4 } }"
        }
        { $example
            "USING: grouping assocs sequences prettyprint ;"
            "{ 1 2 3 4 } dup"
            "2 <clumps> unclip-last [ keys ] dip append sequence= ."
            "t"
        }
    }
    { "With circular clumps, collecting the first element of each subsequence yields the original sequence. Collecting the " { $snippet "n" } "th element of each subsequence would rotate the original sequence " { $snippet "n" } " elements rightward:"
        { $example
            "USING: grouping prettyprint ;"
            "{ 1 2 3 4 } 2 circular-clump ."
            "{ { 1 2 } { 2 3 } { 3 4 } { 4 1 } }"
        }
        { $example
            "USING: grouping assocs sequences prettyprint ;"
            "{ 1 2 3 4 } dup"
            "2 <circular-clumps> keys sequence= ."
            "t"
        }
        { $example
            "USING: grouping prettyprint ;"
            "{ 1 2 3 4 }"
            "2 <circular-clumps> [ second ] { } map-as ."
            "{ 2 3 4 1 }"
        }
    }
}
$nl
"A combinator built using clumps:"
{ $subsections monotonic? }
"Testing how elements are related:"
{ $subsections all-eq? all-equal? } ;

ABOUT: "grouping"

HELP: groups
{ $class-description "Instances are virtual sequences whose elements are disjoint fixed-length subsequences of an underlying sequence. Groups are mutable and resizable if the underlying sequence is mutable and resizable, respectively."
$nl
"New groups are created by calling " { $link <groups> } "." } ;

HELP: group
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "array" "a sequence of sequences" } }
{ $description "Splits the sequence into disjoint groups of " { $snippet "n" } " elements and collects the groups into a new array." }
{ $notes "If the sequence length is not a multiple of " { $snippet "n" } ", the final subsequence in the list will be shorter than " { $snippet "n" } " elements." }
{ $examples
    { $example "USING: grouping prettyprint ;" "{ 3 1 3 3 7 } 2 group ." "{ { 3 1 } { 3 3 } { 7 } }" }
} ;

HELP: <groups>
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "groups" groups } }
{ $description "Outputs a virtual sequence whose elements are slices of disjoint subsequences of " { $snippet "n" } " elements from the underlying sequence." }
{ $examples
    { $example
        "USING: arrays kernel prettyprint sequences grouping ;"
        "9 <iota> >array 3 <groups>"
        "dup [ reverse! drop ] each concat >array ."
        "{ 2 1 0 5 4 3 8 7 6 }"
    }
    { $example
        "USING: kernel prettyprint sequences grouping ;"
        "{ 1 2 3 4 5 6 } 3 <groups> second ."
        "T{ slice { from 3 } { to 6 } { seq { 1 2 3 4 5 6 } } }"
    }
} ;

HELP: clumps
{ $class-description "Instances are virtual sequences whose elements are overlapping fixed-length subsequences of an underlying sequence. Clumps are mutable and resizable if the underlying sequence is mutable and resizable, respectively."
$nl
"New clumps are created by calling " { $link <clumps> } "." } ;

HELP: circular-clumps
{ $class-description "Instances are virtual sequences whose elements are overlapping fixed-length subsequences of an underlying sequence, beginning with every element in the original sequence and wrapping around its end. Circular clumps are mutable and resizable if the underlying sequence is mutable and resizable, respectively."
$nl
"New clumps are created by calling " { $link <circular-clumps> } "." } ;

HELP: clump
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "array" "a sequence of sequences" } }
{ $description "Splits the sequence into overlapping clumps of " { $snippet "n" } " elements and collects the clumps into a new array." }
{ $notes "For an empty sequence, the result is an empty sequence. For a non empty sequence with a length smaller than " { $snippet "n" } ", the result will be an empty sequence." }
{ $examples
    { $example "USING: grouping prettyprint ;" "{ 3 1 3 3 7 } 2 clump ." "{ { 3 1 } { 1 3 } { 3 3 } { 3 7 } }" }
} ;

HELP: circular-clump
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "array" "a sequence of sequences" } }
{ $description "Splits the sequence into overlapping clumps of " { $snippet "n" } " elements, wrapping around the end of the sequence, and collects the clumps into a new array." }
{ $notes "For an empty sequence, the result is an empty sequence." }
{ $examples
    { $example "USING: grouping prettyprint ;"
    "{ 3 1 3 3 7 } 2 circular-clump ."
    "{ { 3 1 } { 1 3 } { 3 3 } { 3 7 } { 7 3 } }" }
} ;

HELP: <clumps>
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "clumps" clumps } }
{ $description "Outputs a virtual sequence whose elements are overlapping subsequences of " { $snippet "n" } " elements from the underlying sequence." }
{ $examples
    "Running averages:"
    { $example
        "USING: grouping sequences math prettyprint kernel ;"
        "IN: scratchpad"
        "CONSTANT: share-price { 13/50 51/100 13/50 1/10 4/5 17/20 33/50 3/25 19/100 3/100 }"
        ""
        "share-price 4 <clumps> [ [ sum ] [ length ] bi / ] map ."
        "{ 113/400 167/400 201/400 241/400 243/400 91/200 1/4 }"
    }
    { $example
        "USING: arrays kernel sequences grouping prettyprint ;"
        "{ 1 2 3 4 5 6 } 3 <clumps> second >array ."
        "{ 2 3 4 }"
    }
} ;

HELP: <circular-clumps>
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "clumps" clumps } }
{ $description "Outputs a virtual sequence whose elements are overlapping slices of " { $snippet "n" } " elements from the underlying sequence, starting with each of its elements and wrapping around the end of the sequence." }
{ $examples
    { $example
        "USING: arrays kernel sequences grouping prettyprint ;"
        "{ 1 2 3 4 } 3 <circular-clumps> third >array ."
        "{ 3 4 1 }"
    }
} ;

{ clumps circular-clumps groups } related-words

{ clump circular-clump group } related-words

{ <clumps> <circular-clumps> <groups> } related-words

HELP: monotonic?
{ $values { "seq" sequence } { "quot" { $quotation ( elt1 elt2 -- ? ) } } { "?" boolean } }
{ $description "Applies the relation to successive pairs of elements in the sequence, testing for a truth value. The relation should be a transitive relation, such as a total order or an equality relation." }
{ $examples
    "Testing if a sequence is non-decreasing:"
    { $example "USING: grouping math prettyprint ;" "{ 1 1 2 } [ <= ] monotonic? ." "t" }
    "Testing if a sequence is decreasing:"
    { $example "USING: grouping math prettyprint ;" "{ 9 8 6 7 } [ > ] monotonic? ." "f" }
} ;

HELP: all-equal?
{ $values { "seq" sequence } { "?" boolean } }
{ $description "Tests if all elements in the sequence are equal. Yields true with an empty sequence." } ;

HELP: all-eq?
{ $values { "seq" sequence } { "?" boolean } }
{ $description "Tests if all elements in the sequence are the same identical object. Yields true with an empty sequence." } ;

{ monotonic? all-eq? all-equal? } related-words

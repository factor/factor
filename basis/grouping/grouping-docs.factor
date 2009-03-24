USING: help.markup help.syntax sequences strings ;
IN: grouping

ARTICLE: "grouping" "Groups and clumps"
"Splitting a sequence into disjoint, fixed-length subsequences:"
{ $subsection group }
"A virtual sequence for splitting a sequence into disjoint, fixed-length subsequences:"
{ $subsection groups }
{ $subsection <groups> }
{ $subsection <sliced-groups> }
"Splitting a sequence into overlapping, fixed-length subsequences:"
{ $subsection clump }
"A virtual sequence for splitting a sequence into overlapping, fixed-length subsequences:"
{ $subsection clumps }
{ $subsection <clumps> }
{ $subsection <sliced-clumps> }
"The difference can be summarized as the following:"
{ $list
    { "With groups, the subsequences form the original sequence when concatenated:"
        { $unchecked-example "dup n groups concat sequence= ." "t" }
    }
    { "With clumps, collecting the first element of each subsequence but the last one, together with the last subseqence, yields the original sequence:"
        { $unchecked-example "dup n clumps unclip-last [ [ first ] map ] dip append sequence= ." "t" }
    }
}
"A combinator built using clumps:"
{ $subsection monotonic? }
"Testing how elements are related:"
{ $subsection all-eq? }
{ $subsection all-equal? } ;

ABOUT: "grouping"

HELP: groups
{ $class-description "Instances are virtual sequences whose elements are disjoint fixed-length subsequences of an underlying sequence. Groups are mutable and resizable if the underlying sequence is mutable and resizable, respectively."
$nl
"New groups are created by calling " { $link <groups> } " and " { $link <sliced-groups> } "." } ;

HELP: group
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "array" "a sequence of sequences" } }
{ $description "Splits the sequence into disjoint groups of " { $snippet "n" } " elements and collects the groups into a new array." }
{ $notes "If the sequence length is not a multiple of " { $snippet "n" } ", the final subsequence in the list will be shorter than " { $snippet "n" } " elements." }
{ $examples
    { $example "USING: grouping prettyprint ;" "{ 3 1 3 3 7 } 2 group ." "{ { 3 1 } { 3 3 } { 7 } }" }
} ;

HELP: <groups>
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "groups" groups } }
{ $description "Outputs a virtual sequence whose elements are disjoint subsequences of " { $snippet "n" } " elements from the underlying sequence." }
{ $examples
    { $example
        "USING: arrays kernel prettyprint sequences grouping ;"
        "9 >array 3 <groups> dup reverse-here concat >array ." "{ 6 7 8 3 4 5 0 1 2 }"
    }
    { $example
        "USING: kernel prettyprint sequences grouping ;"
        "{ 1 2 3 4 5 6 } 3 <groups> first ."
        "{ 1 2 3 }"
    }
} ;

HELP: <sliced-groups>
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "groups" groups } }
{ $description "Outputs a virtual sequence whose elements are slices of disjoint subsequences of " { $snippet "n" } " elements from the underlying sequence." }
{ $examples
    { $example
        "USING: arrays kernel prettyprint sequences grouping ;"
        "9 >array 3 <sliced-groups>"
        "dup [ reverse-here ] each concat >array ."
        "{ 2 1 0 5 4 3 8 7 6 }"
    }
    { $example
        "USING: kernel prettyprint sequences grouping ;"
        "{ 1 2 3 4 5 6 } 3 <sliced-groups> second ."
        "T{ slice { from 3 } { to 6 } { seq { 1 2 3 4 5 6 } } }"
    }
} ;

HELP: clumps
{ $class-description "Instances are virtual sequences whose elements are overlapping fixed-length subsequences o an underlying sequence. Clumps are mutable and resizable if the underlying sequence is mutable and resizable, respectively."
$nl
"New clumps are created by calling " { $link <clumps> } " and " { $link <sliced-clumps> } "." } ;

HELP: clump
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "array" "a sequence of sequences" } }
{ $description "Splits the sequence into overlapping clumps of " { $snippet "n" } " elements and collects the clumps into a new array." }
{ $errors "Throws an error if " { $snippet "n" } " is smaller than the length of the sequence." }
{ $examples
    { $example "USING: grouping prettyprint ;" "{ 3 1 3 3 7 } 2 clump ." "{ { 3 1 } { 1 3 } { 3 3 } { 3 7 } }" }
} ;

HELP: <clumps>
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "clumps" clumps } }
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
        "USING: kernel sequences grouping prettyprint ;"
        "{ 1 2 3 4 5 6 } 3 <clumps> second ."
        "{ 2 3 4 }"
    }
} ;

HELP: <sliced-clumps>
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "clumps" clumps } }
{ $description "Outputs a virtual sequence whose elements are overlapping slices of " { $snippet "n" } " elements from the underlying sequence." }
{ $examples
    { $example
        "USING: kernel sequences grouping prettyprint ;"
        "{ 1 2 3 4 5 6 } 3 <sliced-clumps> second ."
        "T{ slice { from 1 } { to 4 } { seq { 1 2 3 4 5 6 } } }"
    }
} ;

{ clumps groups } related-words

{ clump group } related-words

{ <clumps> <groups> } related-words

{ <sliced-clumps> <sliced-groups> } related-words

HELP: monotonic?
{ $values { "seq" sequence } { "quot" { $quotation "( elt elt -- ? )" } } { "?" "a boolean" } }
{ $description "Applies the relation to successive pairs of elements in the sequence, testing for a truth value. The relation should be a transitive relation, such as a total order or an equality relation." }
{ $examples
    "Testing if a sequence is non-decreasing:"
    { $example "USING: grouping math prettyprint ;" "{ 1 1 2 } [ <= ] monotonic? ." "t" }
    "Testing if a sequence is decreasing:"
    { $example "USING: grouping math prettyprint ;" "{ 9 8 6 7 } [ < ] monotonic? ." "f" }
} ;

HELP: all-equal?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if all elements in the sequence are equal. Yields true with an empty sequence." } ;

HELP: all-eq?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if all elements in the sequence are the same identical object. Yields true with an empty sequence." } ;

{ monotonic? all-eq? all-equal? } related-words

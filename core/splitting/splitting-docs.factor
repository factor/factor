USING: help.markup help.syntax sequences strings ;
IN: splitting

ARTICLE: "sequences-split" "Splitting sequences"
"Splitting sequences at occurrences of subsequences:"
{ $subsection ?head }
{ $subsection ?head-slice }
{ $subsection ?tail }
{ $subsection ?tail-slice }
{ $subsection split1 }
{ $subsection split }
"Grouping elements:"
{ $subsection group }
"A virtual sequence for grouping elements:"
{ $subsection groups }
{ $subsection <groups> }
{ $subsection <sliced-groups> }
"Splitting a string into lines:"
{ $subsection string-lines } ;

ABOUT: "sequences-split"

HELP: split1
{ $values { "seq" "a sequence" } { "subseq" "a sequence" } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: last-split1
{ $values { "seq" "a sequence" } { "subseq" "a sequence" } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the last occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

{ split1 last-split1 } related-words

HELP: split
{ $values { "seq" "a sequence" } { "separators" "a sequence" } { "pieces" "a new array" } }
{ $description "Splits " { $snippet "seq" } " at each occurrence of an element of " { $snippet "separators" } ", and outputs an array of pieces. The pieces do not include the elements along which the sequence was split." }
{ $examples { $example "USE: splitting" "\"hello world-how are you?\" \" -\" split ." "{ \"hello\" \"world\" \"how\" \"are\" \"you?\" }" } } ;

HELP: groups
{ $class-description "Instances are virtual sequences whose elements are fixed-length subsequences or slices of an underlying sequence. Groups are mutable and resizable if the underlying sequence is mutable and resizable, respectively."
$nl
"New groups are created by calling " { $link <groups> } " and " { $link <sliced-groups> } "." }
{ $see-also group } ;

HELP: group
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "array" "a sequence of sequences" } }
{ $description "Splits the sequence into groups of " { $snippet "n" } " elements and collects the groups into a new array." }
{ $notes "If the sequence length is not a multiple of " { $snippet "n" } ", the final subsequence in the list will be shorter than " { $snippet "n" } " elements." } ;

HELP: <groups>
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "groups" groups } }
{ $description "Outputs a virtual sequence whose elements are subsequences consisting of groups of " { $snippet "n" } " elements from the underlying sequence." }
{ $examples
    { $example
        "USE: splitting"
        "9 >array 3 <groups> dup reverse-here concat >array ." "{ 6 7 8 3 4 5 0 1 2 }"
    }
} ;

HELP: <sliced-groups>
{ $values { "seq" "a sequence" } { "n" "a non-negative integer" } { "groups" groups } }
{ $description "Outputs a virtual sequence whose elements are slices consisting of groups of " { $snippet "n" } " elements from the underlying sequence." }
{ $examples
    { $example
        "USE: splitting"
        "9 >array 3 <sliced-groups>"
        "dup [ reverse-here ] each concat >array ."
        "{ 2 1 0 5 4 3 8 7 6 }"
    }
} ;

{ group <groups> <sliced-groups> } related-words

HELP: ?head
{ $values { "seq" "a sequence" } { "begin" "a sequence" } { "newseq" "a new sequence" } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "seq" } " starts with " { $snippet "begin" } ". If there is a match, outputs the subrange of " { $snippet "seq" } " excluding " { $snippet "begin" } ", and " { $link t } ". If there is no match, outputs " { $snippet "seq" } " and " { $link f } "." } ;

HELP: ?head-slice
{ $values { "seq" "a sequence" } { "begin" "a sequence" } { "newseq" slice } { "?" "a boolean" } }
{ $description "Like " { $link ?head } ", except the resulting sequence is a " { $link slice } "." } ;

HELP: ?tail
{ $values { "seq" "a sequence" } { "end" "a sequence" } { "newseq" "a new sequence" } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "seq" } " ends with " { $snippet "end" } ". If there is a match, outputs the subrange of " { $snippet "seq" } " excluding " { $snippet "end" } ", and " { $link t } ". If there is no match, outputs " { $snippet "seq" } " and " { $link f } "." } ;

HELP: ?tail-slice
{ $values { "seq" "a sequence" } { "end" "a sequence" } { "newseq" slice } { "?" "a boolean" } }
{ $description "Like " { $link ?tail } ", except the resulting sequence is a " { $link slice } "." } ;

HELP: string-lines
{ $values { "str" string } { "seq" "a sequence of strings" } }
{ $description "Splits a string along line breaks." }
{ $examples
    { $example "USE: splitting" "\"Hello\\r\\nworld\\n\" string-lines ." "{ \"Hello\" \"world\" \"\" }" }
} ;

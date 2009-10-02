USING: help.markup help.syntax sequences strings ;
IN: splitting

ARTICLE: "sequences-split" "Splitting sequences"
"Splitting sequences at occurrences of subsequences:"
{ $subsections
    ?head
    ?head-slice
    ?tail
    ?tail-slice
    split1
    split1-slice
    split1-last
    split1-last-slice
    split
}
"Splitting a string into lines:"
{ $subsections string-lines } ;

ABOUT: "sequences-split"

HELP: split1
{ $values { "seq" "a sequence" } { "subseq" "a sequence" } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: split1-slice
{ $values { "seq" "a sequence" } { "subseq" "a sequence" } { "before-slice" slice } { "after-slice" slice } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split as slices. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: split1-last
{ $values { "seq" "a sequence" } { "subseq" "a sequence" } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the last occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: split1-last-slice
{ $values { "seq" "a sequence" } { "subseq" "a sequence" } { "before-slice" slice } { "after-slice" slice } }
{ $description "Splits " { $snippet "seq" } " at the last occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split as slices. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

{ split1 split1-slice split1-last split1-last-slice } related-words

HELP: split
{ $values { "seq" "a sequence" } { "separators" "a sequence" } { "pieces" "a new array" } }
{ $description "Splits " { $snippet "seq" } " at each occurrence of an element of " { $snippet "separators" } ", and outputs an array of pieces. The pieces do not include the elements along which the sequence was split." }
{ $examples { $example "USING: prettyprint splitting ;" "\"hello world-how are you?\" \" -\" split ." "{ \"hello\" \"world\" \"how\" \"are\" \"you?\" }" } } ;

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
    { $example "USING: prettyprint splitting ;" "\"Hello\\r\\nworld\\n\" string-lines ." "{ \"Hello\" \"world\" \"\" }" }
} ;

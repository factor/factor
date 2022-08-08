USING: help.markup help.syntax kernel sequences strings ;
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
    split1-when
    split1-when-slice
    split1-last
    split1-last-slice
    split
    split-indices
    split-slice
    split-when
    split-when-slice
}
"Splitting a string into lines:"
{ $subsections split-lines }
"Replacing subsequences with another subsequence:"
{ $subsections replace } ;

ABOUT: "sequences-split"

HELP: split1
{ $values { "seq" sequence } { "subseq" sequence } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: split1-slice
{ $values { "seq" sequence } { "subseq" sequence } { "before-slice" slice } { "after-slice" slice } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split as slices. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: split1-when
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of an element for which " { $snippet "quot" } " gives a true output and outputs the pieces before and after the split." } ;

HELP: split1-when-slice
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "before-slice" slice } { "after-slice" slice } }
{ $description "Splits " { $snippet "seq" } " at the first occurrence of an element for which " { $snippet "quot" } " gives a true output and outputs the pieces before and after the split as slices. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: split1-last
{ $values { "seq" sequence } { "subseq" sequence } { "before" "a new sequence" } { "after" "a new sequence" } }
{ $description "Splits " { $snippet "seq" } " at the last occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

HELP: split1-last-slice
{ $values { "seq" sequence } { "subseq" sequence } { "before-slice" slice } { "after-slice" slice } }
{ $description "Splits " { $snippet "seq" } " at the last occurrence of " { $snippet "subseq" } ", and outputs the pieces before and after the split as slices. If " { $snippet "subseq" } " does not occur in " { $snippet "seq" } ", then " { $snippet "before" } " is just " { $snippet "seq" } " and " { $snippet "after" } " is " { $link f } "." } ;

{ split1 split1-slice split1-last split1-last-slice } related-words

HELP: split-when
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "pieces" "a new array" } }
{ $description "Splits " { $snippet "seq" } " at each occurrence of an element for which " { $snippet "quot" } " gives a true output and outputs an array of pieces. The pieces do not include the elements along which the sequence was split." }
{ $examples { $example "USING: ascii kernel prettyprint splitting ;" "\"hello,world-how.are:you\" [ letter? not ] split-when ." "{ \"hello\" \"world\" \"how\" \"are\" \"you\" }" } } ;

HELP: split-when-slice
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "pieces" "a new array" } }
{ $description "Splits " { $snippet "seq" } " at each occurrence of an element for which " { $snippet "quot" } " gives a true output and outputs an array of pieces as " { $link slice } "s. The pieces do not include the elements along which the sequence was split." } ;

HELP: split-indices
{ $values { "seq" sequence } { "indices" sequence } { "pieces" "a new array" } }
{ $description "Splits a sequence at the given indices." }
{ $examples
  { $example
    "USING: prettyprint splitting ;"
    "\"hello world\" { 3 6 } split-indices ."
    "{ \"hel\" \"lo \" \"world\" }"
  }
} ;

HELP: split
{ $values { "seq" sequence } { "separators" sequence } { "pieces" "a new array" } }
{ $description "Splits " { $snippet "seq" } " at each occurrence of an element of " { $snippet "separators" } " and outputs an array of pieces. The pieces do not include the elements along which the sequence was split." }
{ $examples { $example "USING: prettyprint splitting ;" "\"hello world-how are you?\" \" -\" split ." "{ \"hello\" \"world\" \"how\" \"are\" \"you?\" }" } } ;

HELP: ?head
{ $values { "seq" sequence } { "begin" sequence } { "newseq" "a new sequence" } { "?" boolean } }
{ $description "Tests if " { $snippet "seq" } " starts with " { $snippet "begin" } ". If there is a match, outputs the subrange of " { $snippet "seq" } " excluding " { $snippet "begin" } ", and " { $link t } ". If there is no match, outputs " { $snippet "seq" } " and " { $link f } "." } ;

HELP: ?head-slice
{ $values { "seq" sequence } { "begin" sequence } { "newseq" slice } { "?" boolean } }
{ $description "Like " { $link ?head } ", except the resulting sequence is a " { $link slice } "." } ;

HELP: ?tail
{ $values { "seq" sequence } { "end" sequence } { "newseq" "a new sequence" } { "?" boolean } }
{ $description "Tests if " { $snippet "seq" } " ends with " { $snippet "end" } ". If there is a match, outputs the subrange of " { $snippet "seq" } " excluding " { $snippet "end" } ", and " { $link t } ". If there is no match, outputs " { $snippet "seq" } " and " { $link f } "." } ;

HELP: ?tail-slice
{ $values { "seq" sequence } { "end" sequence } { "newseq" slice } { "?" boolean } }
{ $description "Like " { $link ?tail } ", except the resulting sequence is a " { $link slice } "." } ;

HELP: split-lines
{ $values { "seq" sequence } { "seq'" { $sequence string } } }
{ $description "Splits a string along line breaks." }
{ $examples
    { $example "USING: prettyprint splitting ;" "\"Hello\\r\\nworld\\n\" split-lines ." "{ \"Hello\" \"world\" }" }
} ;

HELP: replace
{ $values { "seq" sequence } { "old" sequence } { "new" sequence } { "new-seq" sequence } }
{ $description "Replaces every occurrence of " { $snippet "old" } " with " { $snippet "new" } " in the " { $snippet "seq" } "." }
{ $examples
    { $example "USING: io splitting ;"
               "\"cool example is cool\" \"cool\" \"silly\" replace print"
               "silly example is silly"
    }
} ;

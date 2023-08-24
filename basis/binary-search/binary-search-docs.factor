IN: binary-search
USING: help.markup help.syntax sequences kernel math.order ;

HELP: search
{ $values { "seq" "a sorted sequence" } { "quot" { $quotation ( ... elt -- ... <=> ) } } { "i" "an index, or " { $link f } } { "elt" "an element, or " { $link f } } }
{ $description "Performs a binary search on a sequence, calling the quotation to decide whether to end the search (" { $link +eq+ } "), search lower (" { $link +lt+ } ") or search higher (" { $link +gt+ } ")."
$nl
"If the sequence is non-empty, outputs the index and value of the closest match, which is either an element for which the quotation output " { $link +eq+ } ", or failing that, the least element for which the quotation output " { $link +lt+ } ", or if there were none of the above, the greatest element for which the quotation output " { $link +gt+ } "."
$nl
"If the sequence is empty, outputs " { $link f } " " { $link f } "." }
{ $notes "If the sequence has at least one element, this word always outputs a valid index, because it finds the closest match, not necessarily an exact one. In this respect its behavior differs from " { $link find } "." }
{ $examples
    "Searching for an integer in a sorted array:"
    { $example
        "USING: binary-search kernel math.order prettyprint ;"
        "{ -130 -40 10 90 160 170 280 } [ 50 >=< ] search [ . ] bi@"
        "2\n10"
    }
    "Frequently, the quotation passed to " { $link search } " is constructed by " { $link curry } " or " { $link with } " in order to make the search key a parameter:"
    { $example
        "USING: binary-search kernel math.order prettyprint ;"
        "50 { -130 -40 10 90 160 170 280 } [ <=> ] with search [ . ] bi@"
        "2\n10"
    }
} ;

{ find find-from find-last find-last-from search } related-words

HELP: sorted-index
{ $values { "obj" object } { "seq" "a sorted sequence" } { "i" "an index, or " { $link f } } }
{ $description "Outputs the index of the element closest to " { $snippet "elt" } " in the sequence. See " { $link search } " for details." }
{ $notes "If the sequence has at least one element, this word always outputs a valid index, because it finds the closest match, not necessarily an exact one. In this respect its behavior differs from " { $link index } "." } ;

{ index index-from last-index last-index-from sorted-index } related-words

HELP: sorted-member?
{ $values { "obj" object } { "seq" "a sorted sequence" } { "?" boolean } }
{ $description "Tests if the sorted sequence contains " { $snippet "elt" } ". Equality is tested with " { $link = } "." } ;

{ member? sorted-member? } related-words

HELP: sorted-member-eq?
{ $values { "obj" object } { "seq" "a sorted sequence" } { "?" boolean } }
{ $description "Tests if the sorted sequence contains " { $snippet "elt" } ". Equality is tested with " { $link eq? } "." } ;

{ member-eq? sorted-member-eq? } related-words

ARTICLE: "binary-search" "Binary search"
"The " { $emphasis "binary search" } " algorithm allows elements to be located in sorted sequence in " { $snippet "O(log n)" } " time."
{ $subsections search }
"Variants of sequence words optimized for sorted sequences:"
{ $subsections
    sorted-index
    sorted-member?
    sorted-member-eq?
}
{ $see-also "order-specifiers" "sequences-sorting" } ;

ABOUT: "binary-search"

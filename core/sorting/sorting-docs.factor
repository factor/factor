USING: sorting help.markup help.syntax kernel words math
sequences ;

ARTICLE: "sequences-sorting" "Sorting and binary search"
"Sorting and binary search combinators all take comparator quotations with stack effect " { $snippet "( elt1 elt2 -- n )" } " that order the two given elements and output a value whose sign denotes the result:"
{ $list
    { "positive - indicates that " { $snippet "elt1" } " follows " { $snippet "elt2" } }
    { "zero - indicates that " { $snippet "elt1" } " is ordered equivalently to " { $snippet "elt2" } }
    { "negative - indicates that " { $snippet "elt1" } " precedes " { $snippet "elt2" } }
}
"Sorting a sequence with a custom comparator:"
{ $subsection sort }
"Sorting a sequence with common comparators:"
{ $subsection natural-sort }
{ $subsection sort-keys }
{ $subsection sort-values }
"Binary search:"
{ $subsection binsearch }
{ $subsection binsearch* } ;

HELP: sort
{ $values { "seq" "a sequence" } { "quot" "a comparator quotation" } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements into a new sequence of the same class as " { $snippet "seq" } "." } ;

HELP: sort-keys
{ $values { "seq" "an alist" } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements comparing first elements of pairs using the " { $link <=> } " word." } ;

HELP: sort-values
{ $values { "seq" "an alist" } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts the elements comparing second elements of pairs using the " { $link <=> } " word." } ;

HELP: natural-sort
{ $values { "seq" "a sequence of real numbers" } { "sortedseq" "a new sorted sequence" } }
{ $description "Sorts a sequence of objects in natural order using the " { $link <=> } " word." } ;

HELP: sort-pair
{ $values { "a" object } { "b" object } { "c" object } { "d" object } }
{ $description "If " { $snippet "a" } " is greater than " { $snippet "b" } ", exchanges " { $snippet "a" } " with " { $snippet "b" } "." } ;

HELP: midpoint@
{ $values { "seq" "a sequence" } { "n" integer } }
{ $description "Outputs the index of the midpoint of " { $snippet "seq" } "." } ;

HELP: midpoint
{ $values { "seq" "a sequence" } { "elt" object } }
{ $description "Outputs the element at the midpoint of a sequence." } ;

HELP: partition
{ $values { "seq" "a sequence" } { "n" integer } { "slice" slice } }
{ $description "Outputs a slice of the first or second half of the sequence, respectively, depending on the integer's sign." } ;

HELP: binsearch
{ $values { "elt" object } { "seq" "a sorted sequence" } { "quot" "a comparator quotation" } { "i" "the index of the search result" } }
{ $description "Given a sequence that is sorted with respect to the " { $snippet "quot" } " comparator, searches for an element equal to " { $snippet "elt" } ", or failing that, the greatest element smaller than " { $snippet "elt" } ". Comparison is performed with " { $snippet "quot" } "."
$nl
"Outputs f if the sequence is empty. If the sequence has at least one element, this word always outputs a valid index." } ;

HELP: binsearch*
{ $values { "elt" object } { "seq" "a sorted sequence" } { "quot" "a comparator quotation" } { "result" "the search result" } }
{ $description "Variant of " { $link binsearch } " which outputs the found element rather than its index in the sequence."
$nl
"Outputs " { $link f } " if the sequence is empty. If the sequence has at least one element, this word always outputs a sequence element." } ;

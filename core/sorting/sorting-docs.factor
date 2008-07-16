USING: help.markup help.syntax kernel words math
sequences math.order ;
IN: sorting

ARTICLE: "sequences-sorting" "Sorting sequences"
"Sorting combinators all take comparator quotations with stack effect " { $snippet "( elt1 elt2 -- <=> )" } ", where the output value is one of the three " { $link "order-specifiers" } "."
$nl
"Sorting a sequence with a custom comparator:"
{ $subsection sort }
"Sorting a sequence with common comparators:"
{ $subsection natural-sort }
{ $subsection sort-keys }
{ $subsection sort-values } ;

ABOUT: "sequences-sorting"

HELP: sort
{ $values { "seq" "a sequence" } { "quot" "a quotation with stack effect " { $snippet "( obj1 obj2 -- <=> )" } } { "sortedseq" "a new sorted sequence" } }
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

{ <=> compare natural-sort sort-keys sort-values } related-words

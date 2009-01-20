! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math.order quotations
sequences strings ;
IN: sorting.human

HELP: find-numbers
{ $values
     { "string" string }
     { "seq" sequence }
}
{ $description "Splits a string on numbers and returns a sequence of sequences and integers." } ;

HELP: human-<=>
{ $values
     { "obj1" object } { "obj2" object }
     { "<=>" "an ordering specifier" }
}
{ $description "Compares two objects after converting numbers in the string into integers." } ;

HELP: human->=<
{ $values
     { "obj1" object } { "obj2" object }
     { ">=<" "an ordering specifier" }
}
{ $description "Compares two objects using the " { $link human-<=> } " word and inverts the result." } ;

HELP: human-compare
{ $values
     { "obj1" object } { "obj2" object } { "quot" quotation }
     { "<=>" "an ordering specifier" }
}
{ $description "Compares the results of applying the quotation to both objects via <=>." } ;

HELP: human-sort
{ $values
     { "seq" sequence }
     { "seq'" sequence }
}
{ $description "Sorts a sequence of objects by comparing the magnitude of any integers in the input string using the <=> word." } ;

HELP: human-sort-keys
{ $values
     { "seq" "an alist" }
     { "sortedseq" "a new sorted sequence" }
}
{ $description "Sorts the elements comparing first elements of pairs using the " { $link human-<=> } " word." } ;

HELP: human-sort-values
{ $values
     { "seq" "an alist" }
     { "sortedseq" "a new sorted sequence" }
}
{ $description "Sorts the elements comparing second elements of pairs using the " { $link human-<=> } " word." } ;

{ <=> >=< human-compare human-sort human-sort-keys human-sort-values } related-words

ARTICLE: "sorting.human" "sorting.human"
"The " { $vocab-link "sorting.human" } " vocabulary sorts by numbers as a human would -- by comparing their magnitudes -- rather than in a lexicographic way. For example, sorting a1, a10, a03, a2 with human sort returns a1, a2, a03, a10, while sorting with natural sort returns a03, a1, a10, a2." $nl
"Comparing two objects:"
{ $subsection human-<=> }
{ $subsection human->=< }
{ $subsection human-compare }
"Sort a sequence:"
{ $subsection human-sort }
{ $subsection human-sort-keys }
{ $subsection human-sort-values }
"Splitting a string into substrings and integers:"
{ $subsection find-numbers } ;

ABOUT: "sorting.human"

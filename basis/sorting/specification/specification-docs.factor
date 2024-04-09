! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations math.order
sequences ;
IN: sorting.specification

HELP: compare-with-spec
{ $values
  { "obj1" object }
  { "obj2" object }
  { "sort-spec" "a sequence of sequences of accessors/quotations and a comparator" }
  { "<=>" { $link +lt+ } ", " { $link +eq+ } " or " { $link +gt+ } }
}
{ $description "Compares two objects using a chain of intrinsic linear orders such that if two objects are " { $link +eq+ } ", then the next ordering is tried." } ;

HELP: sort-with-spec
{ $values
    { "seq" sequence } { "sort-spec" "a sequence of sequences of accessors and a comparator" }
    { "seq'" sequence }
}
{ $description "Sorts a sequence of objects by the sorting specification in " { $snippet "sort-spec" } ". A sorting specification is a sequence of sequences, each consisting of accessors and a comparator." }
{ $examples
    "Sort by slot a, then b descending:"
    { $example
        "USING: accessors math.order prettyprint sorting.specification ;"
        "IN: scratchpad"
        "TUPLE: sort-me a b ;"
        "{"
        "    T{ sort-me f 2 3 } T{ sort-me f 3 2 }"
        "    T{ sort-me f 4 3 } T{ sort-me f 2 1 }"
        "}"
        "{ { a>> <=> } { b>> >=< } } sort-with-spec ."
        "{\n    T{ sort-me { a 2 } { b 3 } }\n    T{ sort-me { a 2 } { b 1 } }\n    T{ sort-me { a 3 } { b 2 } }\n    T{ sort-me { a 4 } { b 3 } }\n}"
    }
} ;

ARTICLE: "sorting.specification" "Sorting by multiple keys"
"The " { $vocab-link "sorting.specification" } " vocabulary can sort objects by multiple keys in ascending or descending order, using subsequent keys as tie-breakers." $nl
"Comparing two objects with a sorting specification:"
{ $subsections compare-with-spec }
"Sorting a sequence of objects with a sorting specification:"
{ $subsections
    sort-with-spec
    sort-keys-with-spec
    sort-values-with-spec
} ;

ABOUT: "sorting.specification"

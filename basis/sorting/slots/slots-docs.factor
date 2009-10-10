! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations math.order
sequences ;
IN: sorting.slots

HELP: compare-slots
{ $values
  { "obj1" object }
  { "obj2" object }
  { "sort-specs" "a sequence of accessors ending with a comparator" }
  { "<=>" { $link +lt+ } " " { $link +eq+ } " or " { $link +gt+ } }
}
{ $description "Compares two objects using a chain of intrinsic linear orders such that if two objects are " { $link +eq+ } ", then the next comparator is tried. The comparators are slot-name/comparator pairs." } ;

HELP: sort-by
{ $values
     { "seq" sequence } { "sort-specs" "a sequence of accessors ending with a comparator" }
     { "seq'" sequence }
}
{ $description "Sorts a sequence of tuples by the sort-specs in " { $snippet "sort-spec" } ". A sort-spec is a sequence of slot accessors ending in a comparator." }
{ $examples
    "Sort by slot a, then b descending:"
    { $example
        "USING: accessors math.order prettyprint sorting.slots ;"
        "IN: scratchpad"
        "TUPLE: sort-me a b ;"
        "{"
        "    T{ sort-me f 2 3 } T{ sort-me f 3 2 }"
        "    T{ sort-me f 4 3 } T{ sort-me f 2 1 }"
        "}"
        "{ { a>> <=> } { b>> >=< } } sort-by ."
        "{\n    T{ sort-me { a 2 } { b 3 } }\n    T{ sort-me { a 2 } { b 1 } }\n    T{ sort-me { a 3 } { b 2 } }\n    T{ sort-me { a 4 } { b 3 } }\n}"
    }
} ;

ARTICLE: "sorting.slots" "Sorting by slots"
"The " { $vocab-link "sorting.slots" } " vocabulary can sort tuples by slot in ascending or descending order, using subsequent slots as tie-breakers." $nl
"Comparing two objects by a sequence of slots:"
{ $subsections compare-slots }
"Sorting a sequence of tuples by a slot/comparator pairs:"
{ $subsections
    sort-by
    sort-keys-by
    sort-values-by
} ;

ABOUT: "sorting.slots"

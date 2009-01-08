! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations math.order
sequences ;
IN: sorting.slots

HELP: compare-slots
{ $values
     { "sort-specs" "a sequence of accessor/comparator pairs" }
     { "<=>" { $link +lt+ } " " { $link +eq+ } " or " { $link +gt+ } }
}
{ $description "Compares two objects using a chain of intrinsic linear orders such that if two objects are " { $link +eq+ } ", then the next comparator is tried. The comparators are slot-name/comparator pairs." } ;

HELP: sort-by-slots
{ $values
     { "seq" sequence } { "sort-specs" "a sequence of accessor/comparator pairs" }
     { "seq'" sequence }
}
{ $description "Sorts a sequence of tuples by the sort-specs in " { $snippet "sort-spec" } ". A sort-spec is a slot accessor and a comparator." }
{ $examples
    "Sort by slot c, then b descending:"
    { $example
        "USING: accessors math.order prettyprint sorting.slots ;"
        "IN: scratchpad"
        "TUPLE: sort-me a b ;"
        "{"
        "    T{ sort-me f 2 3 } T{ sort-me f 3 2 }"
        "    T{ sort-me f 4 3 } T{ sort-me f 2 1 }"
        "}"
        "{ { a>> <=> } { b>> >=< } } sort-by-slots ."
        "{\n    T{ sort-me { a 2 } { b 3 } }\n    T{ sort-me { a 2 } { b 1 } }\n    T{ sort-me { a 3 } { b 2 } }\n    T{ sort-me { a 4 } { b 3 } }\n}"
    }
} ;

ARTICLE: "sorting.slots" "Sorting by slots"
"The " { $vocab-link "sorting.slots" } " vocabulary can sort tuples by slot in ascending or descending order, using subsequent slots as tie-breakers." $nl
"Comparing two objects by a sequence of slots:"
{ $subsection compare-slots }
"Sorting a sequence by a sequence of slots:"
{ $subsection sort-by-slots } ;

ABOUT: "sorting.slots"

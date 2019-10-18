USING: help.markup help.syntax kernel math ;
IN: math.order

HELP: <=>
{ $values { "obj1" object } { "obj2" object } { "<=>" "an ordering specifier" } }
{ $contract
    "Compares two objects using an intrinsic linear order, for example, the natural order for real numbers and lexicographic order for strings."
    $nl
    "The output value is one of the following:"
    { $list
        { { $link +lt+ } " - indicating that " { $snippet "obj1" } " precedes " { $snippet "obj2" } }
        { { $link +eq+ } " - indicating that " { $snippet "obj1" } " is equal to " { $snippet "obj2" } }
        { { $link +gt+ } " - indicating that " { $snippet "obj1" } " follows " { $snippet "obj2" } }
    }
} ;

HELP: >=<
{ $values { "obj1" object } { "obj2" object } { ">=<" "an ordering specifier" } }
{ $description "Compares two objects using the " { $link <=> } " comparator and inverts the output." } ;

{ <=> >=< } related-words

HELP: +lt+
{ $description "Output by " { $link <=> } " when the first object is strictly less than the second object." } ;

HELP: +eq+
{ $description "Output by " { $link <=> } " when the first object is equal to the second object." } ;

HELP: +gt+
{ $description "Output by " { $link <=> } " when the first object is strictly greater than the second object." } ;

HELP: invert-comparison
{ $values { "<=>" "an ordering specifier" } { ">=<" "an ordering specifier" } }
{ $description "Invert the comparison symbol returned by " { $link <=> } "." }
{ $examples
    { $example "USING: math.order prettyprint ;" "+lt+ invert-comparison ." "+gt+" } } ;

HELP: compare
{ $values { "obj1" object } { "obj2" object } { "quot" { $quotation ( obj -- newobj ) } } { "<=>" "an ordering specifier" } }
{ $description "Compares the results of applying the quotation to both objects via " { $link <=> } "." }
{ $examples { $example "USING: kernel math.order prettyprint sequences ;" "\"hello\" \"hi\" [ length ] compare ." "+gt+" }
} ;

HELP: max
{ $values { "obj1" object } { "obj2" object } { "obj" object } }
{ $description "Outputs the greatest of two ordered values." }
{ $notes "If one value is a floating point positive zero and the other is a negative zero, the result is undefined." } ;

HELP: min
{ $values { "obj1" object } { "obj2" object } { "obj" object } }
{ $description "Outputs the smallest of two ordered values." }
{ $notes "If one value is a floating point positive zero and the other is a negative zero, the result is undefined." } ;

HELP: clamp
{ $values { "x" object } { "min" object } { "max" object } { "y" object } }
{ $description "Outputs " { $snippet "x" } " if contained in the interval " { $snippet "[min,max]" } " or else outputs one of the endpoints." } ;

HELP: between?
{ $values { "x" object } { "min" object } { "max" object } { "?" boolean } }
{ $description "Tests if " { $snippet "x" } " is in the interval " { $snippet "[min,max]" } "." }
{ $notes "As per the closed interval notation, the end-points are included in the interval." } ;

HELP: before?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description "Tests if " { $snippet "obj1" } " comes before " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

HELP: after?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description "Tests if " { $snippet "obj1" } " comes after " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

HELP: before=?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description "Tests if " { $snippet "obj1" } " comes before or equals " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

HELP: after=?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description "Tests if " { $snippet "obj1" } " comes after or equals " { $snippet "obj2" } " using an intrinsic total order." }
{ $notes "Implemented using " { $link <=> } "." } ;

{ before? after? before=? after=? } related-words

HELP: [-]
{ $values { "x" real } { "y" real } { "z" real } }
{ $description "Subtracts " { $snippet "y" } " from " { $snippet "x" } ". If the result is less than zero, outputs zero." } ;

ARTICLE: "order-specifiers" "Ordering specifiers"
"Ordering words such as " { $link <=> } " output one of the following values, indicating that of two objects being compared, the first is less than the second, the two are equal, or that the first is greater than the second:"
{ $subsections
    +lt+
    +eq+
    +gt+
} ;

ARTICLE: "math.order.example" "Linear order example"
"A tuple class which defines an ordering among instances by comparing the values of the " { $snippet "id" } " slot:"
{ $code
  "TUPLE: sprite id name bitmap ;"
  "M: sprite <=> [ id>> ] compare ;"
} ;

ARTICLE: "math.order" "Linear order protocol"
"Some classes define an intrinsic order amongst instances. This includes numbers, sequences (in particular, strings), and words."
{ $subsections
    <=>
    >=<
    compare
    invert-comparison
}
"The above words output order specifiers."
{ $subsections "order-specifiers" }
"Utilities for comparing objects:"
{ $subsections
    after?
    before?
    after=?
    before=?
}
"Minimum, maximum, clamping:"
{ $subsections
    min
    max
    clamp
}
"Out of the above generic words, it suffices to implement " { $link <=> } " alone. The others may be provided as an optimization."
{ $subsections "math.order.example" }
{ $see-also "sequences-sorting" } ;

ABOUT: "math.order"

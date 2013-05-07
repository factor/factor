USING: help.markup help.syntax math ;
IN: math.combinators

HELP: when-negative
{ $values { "n" real } { "quot" "the first quotation of an " { $link if-negative } } }
{ $description "When " { $snippet "n" } " is negative, calls the quotation with " { $snippet "n" } "." }
{ $examples
    { $example "USING: math math.combinators prettyprint ;" "-3 [ 1 + ] when-negative ." "-2" }
    { $example "USING: math math.combinators prettyprint ;" "3.5 [ 1 + ] when-negative ." "3.5" }
} ;

HELP: when-positive
{ $values { "n" real } { "quot" "the first quotation of an " { $link if-positive } } }
{ $description "When " { $snippet "n" } " is positive, calls the quotation with " { $snippet "n" } "." }
{ $examples
    { $example "USING: math math.combinators prettyprint ;" "1.5 [ 1 + ] when-positive ." "2.5" }
    { $example "USING: math math.combinators prettyprint ;" "-1 [ 1 + ] when-positive ." "-1" }
} ;

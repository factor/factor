USING: arrays help.markup help.syntax math
sequences.private vectors strings kernel math.order layouts
quotations generic.single ;
IN: math.combinators

HELP: when-negative
{ $values
     { "n" "an integer" } { "true" "a quotation" } { "m" "an integer" } }
{ $description "When the n value is negative, calls the true quotation. The n value is passed to the quotation." }
{ $examples "The following two lines are equivalent."
    { $example "-1 [ 1 + ] when-negative\n-1 dup 0 < [ 1 + ] when"
               "0\n0"
    }     
} ;

HELP: when-positive
{ $values
     { "n" "an integer" } { "true" "a quotation" } { "m" "an integer" } }
{ $description "When the n value is positive, calls the true quotation. The n value is passed to the quotation." }
{ $examples "The following two lines are equivalent."
    { $example "1 [ 1 + ] when-positive\n1 dup 0 > [ 1 + ] when"
               "2\n2"
    }     
} ;
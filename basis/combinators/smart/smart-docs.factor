! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations math sequences
multiline ;
IN: combinators.smart

HELP: input<sequence
{ $values
     { "quot" quotation }
     { "newquot" quotation }
}
{ $description "Infers the number of inputs, " { $snippet "n" } ", to " { $snippet "quot" } " and calls the " { $snippet "quot" } " with the first " { $snippet "n" } " values from a sequence." }
{ $examples
    { $example
        "USING: combinators.smart math prettyprint ;"
        "{ 1 2 3 } [ + + ] input<sequence ."
        "6"
    }
} ;

HELP: output>array
{ $values
     { "quot" quotation }
     { "newquot" quotation }
}
{ $description "Infers the number or outputs from the quotation and constructs an array from those outputs." }
{ $examples
    { $example
        <" USING: combinators combinators.smart math prettyprint ;
9 [
    { [ 1- ] [ 1+ ] [ sq ] } cleave
] output>array .">
    "{ 8 10 81 }"
    }
} ;

HELP: output>sequence
{ $values
     { "quot" quotation } { "exemplar" "an exemplar" }
     { "newquot" quotation }
}
{ $description "Infers the number of outputs from the quotation and constructs a new sequence from those objects of the same type as the exemplar." }
{ $examples
    { $example
        "USING: combinators.smart kernel math prettyprint ;"
        "4 [ [ 1 + ] [ 2 + ] [ 3 + ] tri ] V{ } output>sequence ."
        "V{ 5 6 7 }"
    }
} ;

HELP: reduce-outputs
{ $values
     { "quot" quotation } { "operation" quotation }
     { "newquot" quotation }
}
{ $description "Infers the number of outputs from " { $snippet "quot" } " and reduces them using " { $snippet "operation" } ". The identity for the " { $link reduce } " operation is the first output." }
{ $examples
    { $example
        "USING: combinators.smart kernel math prettyprint ;"
        "3 [ [ 4 * ] [ 4 / ] [ 4 - ] tri ] [ * ] reduce-outputs ."
        "-9"
    }
} ;

HELP: sum-outputs
{ $values
     { "quot" quotation }
     { "n" integer }
}
{ $description "Infers the number of outputs from " { $snippet "quot" } " and returns their sum." }
{ $examples
    { $example
        "USING: combinators.smart kernel math prettyprint ;"
        "10 [ [ 1- ] [ 1+ ] bi ] sum-outputs ."
        "20"
    }
} ;

ARTICLE: "combinators.smart" "Smart combinators"
"The " { $vocab-link "combinators.smart" } " vocabulary implements " { $emphasis "smart combinators" } ". A smart combinator is one whose behavior depends on the static stack effect of an input quotation." $nl
"Smart inputs from a sequence:"
{ $subsection input<sequence }
"Smart outputs to a sequence:"
{ $subsection output>sequence }
{ $subsection output>array }
"Reducing the output of a quotation:"
{ $subsection reduce-outputs }
"Summing the output of a quotation:"
{ $subsection sum-outputs } ;

ABOUT: "combinators.smart"

! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations math sequences
stack-checker ;
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
        "USING: combinators combinators.smart math prettyprint ;
9 [
    { [ 1 - ] [ 1 + ] [ sq ] } cleave
] output>array ."
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
        "10 [ [ 1 - ] [ 1 + ] bi ] sum-outputs ."
        "20"
    }
} ;

HELP: append-outputs
{ $values
     { "quot" quotation }
     { "seq" sequence }
}
{ $description "Infers the number of outputs from " { $snippet "quot" } " and returns a sequence of the outputs appended." }
{ $examples
    { $example
        "USING: combinators.smart prettyprint ;"
        "[ { 1 2 } { \"A\" \"b\" } ] append-outputs ."
        "{ 1 2 \"A\" \"b\" }"
    }
} ;

HELP: append-outputs-as
{ $values
     { "quot" quotation } { "exemplar" sequence }
     { "seq" sequence }
}
{ $description "Infers the number of outputs from " { $snippet "quot" } " and returns a sequence of type " { $snippet "exemplar" } " of the outputs appended." }
{ $examples
    { $example
        "USING: combinators.smart prettyprint ;"
        "[ { 1 2 } { \"A\" \"b\" } ] V{ } append-outputs-as ."
        "V{ 1 2 \"A\" \"b\" }"
    }
} ;

{ append-outputs append-outputs-as } related-words

HELP: drop-outputs
{ $values { "quot" quotation } }
{ $description "Calls a quotation and drops any values it leaves on the stack." } ;

HELP: keep-inputs
{ $values { "quot" quotation } }
{ $description "Calls a quotation and preserves any values it takes off the stack." } ;

{ drop-outputs keep-inputs } related-words

ARTICLE: "combinators.smart" "Smart combinators"
"A " { $emphasis "smart combinator" } " is a macro which reflects on the stack effect of an input quotation. The " { $vocab-link "combinators.smart" } " vocabulary implements a few simple smart combinators which look at the static stack effects of input quotations and generate code which produces or consumes the relevant number of stack values." $nl
"Call a quotation and discard all output values or preserve all input values:"
{ $subsections
    drop-outputs
    keep-inputs
}
"Take all input values from a sequence:"
{ $subsections input<sequence }
"Store all output values to a sequence:"
{ $subsections
    output>sequence
    output>array
}
"Reducing the set of output values:"
{ $subsections reduce-outputs }
"Summing output values:"
{ $subsections sum-outputs }
"Concatenating output values:"
{ $subsections
    append-outputs
    append-outputs-as
}
"New smart combinators can be created by defining " { $link "macros" } " which call " { $link infer } "." ;

ABOUT: "combinators.smart"

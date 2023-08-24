! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.tuple help.markup help.syntax kernel math
quotations sequences stack-checker arrays ;
IN: combinators.smart

HELP: input<sequence
{ $values
    { "seq" sequence }
    { "quot" quotation }
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
    { "array" array }
}
{ $description "Infers the number of outputs from the quotation and constructs an array from those outputs." }
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
    { "seq" sequence }
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

HELP: dropping
{ $values
    { "quot" quotation }
    { "quot'" quotation }
}
{ $description "Outputs a quotation that, when called, will have the effect of dropping the number of inputs to the original quotation." }
{ $examples
    { $example
        "USING: combinators.smart math prettyprint ;
[ + + ] dropping ."
"[ 3 ndrop ]"
    }
} ;

HELP: input<sequence-unsafe
{ $values
    { "seq" sequence }
    { "quot" quotation }
}
{ $description "An unsafe version of " { $link input<sequence-unsafe } "." } ;

HELP: map-reduce-outputs
{ $values
    { "quot" quotation } { "mapper" quotation } { "reducer" quotation }
}
{ $description "Infers the number of outputs from " { $snippet "quot" } " and, treating those outputs as a sequence, calls " { $link map-reduce } " on them." }
{ $examples
    { $example
"USING: math combinators.smart prettyprint ;
[ 1 2 3 ] [ sq ] [ + ] map-reduce-outputs ."
"14"
    }
} ;

HELP: nullary
{ $values
    { "quot" quotation }
}
{ $description "Infers the number of inputs to a quotation and drops them from the stack." }
{ $examples
    { $code
        "USING: combinators.smart kernel math ;
1 2 [ + ] nullary"
    }
} ;

HELP: preserving
{ $values
    { "quot" quotation }
}
{ $description "Calls a quotation and leaves any consumed inputs on the stack beneath the quotation's outputs." }
{ $examples
    { $example
        "USING: combinators.smart kernel math prettyprint ;
1 2 [ + ] preserving [ . ] tri@"
"1
2
3"
    }
} ;

HELP: smart-apply
{ $values
    { "quot" quotation } { "n" integer }
}
{ $description "Applies a quotation to the datastack " { $snippet "n" } " times, starting lower on the stack and working up in increments of the number of inferred inputs to the quotation." }
{ $examples
    { $example
        "USING: combinators.smart prettyprint math kernel ;
1 2 3 4 [ + ] 2 smart-apply [ . ] bi@"
"3
7"
    }
} ;

HELP: smart-if
{ $values
    { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "A version of " { $link if } " that takes three quotations, where the first quotation is a predicate that preserves any inputs it consumes." } ;

HELP: smart-if*
{ $values
    { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "A version of " { $link if } " that takes three quotations, where the first quotation is a predicate that preserves any inputs it consumes, the second is the " { $snippet "true" } " branch, and the third is the " { $snippet "false" } " branch. If the " { $snippet "true" } " branch is taken, the values are left on the stack and the quotation is called. If the " { $snippet "false" } " branch is taken, the number of inputs inferred from predicate quotation is dropped and the quotation is called." } ;

HELP: smart-unless
{ $values
    { "pred" quotation } { "false" quotation }
}
{ $description "A version of " { $link unless } " that takes two quotations, where the first quotation is a predicate that preserves any inputs it consumes and the second is the " { $snippet "false" } " branch." } ;

HELP: smart-unless*
{ $values
    { "pred" quotation } { "false" quotation }
}
{ $description "A version of " { $link unless } " that takes two quotations, where the first quotation is a predicate that preserves any inputs it consumes and the second is the " { $snippet "false" } " branch. If the " { $snippet "true" } " branch is taken, the values are left on the stack. If the " { $snippet "false" } " branch is taken, the number of inputs inferred from predicate quotation is dropped and the quotation is called." } ;

HELP: smart-when
{ $values
    { "pred" quotation } { "true" quotation }
}
{ $description "A version of " { $link when } " that takes two quotations, where the first quotation is a predicate that preserves any inputs it consumes and the second is the " { $snippet "true" } " branch." } ;

HELP: smart-when*
{ $values
    { "pred" quotation } { "true" quotation }
}
{ $description "A version of " { $link when } " that takes two quotations, where the first quotation is a predicate that preserves any inputs it consumes and the second is the " { $snippet "true" } " branch. If the " { $snippet "true" } " branch is taken, the values are left on the stack and the quotation is called. If the " { $snippet "false" } " branch is taken, the number of inputs inferred from predicate quotation is dropped." } ;

HELP: smart-with
{ $values
    { "param" object } { "obj" object } { "quot" { $quotation "( param ..a -- ..b )" } } { "curry" curry } }
{ $description "A version of " { $link with } " that puts the parameter before any inputs the quotation uses." } ;

HELP: smart-reduce
{ $values { "reduce-quots" sequence } }
{ $description "A version of " { $link reduce } " that takes a sequence of " { $snippet "{ identity reduce-quot }" } " pairs, returning the " { $link reduce } " result for each pair." } ;

HELP: smart-map-reduce
{ $values { "map-reduce-quots" sequence } }
{ $description "A version of " { $link map-reduce } " that takes a sequence of " { $snippet "{ map-quot reduce-quot }" } " pairs, returning the " { $link map-reduce } " result for each pair." } ;

HELP: smart-2reduce
{ $values { "2reduce-quots" sequence } }
{ $description "A version of " { $link 2reduce } " that takes a sequence of " { $snippet "{ identity 2reduce-quot }" } " pairs, returning the " { $link 2reduce } " result for each pair." } ;

HELP: smart-2map-reduce
{ $values { "2map-reduce-quots" sequence } }
{ $description "A version of " { $link 2map-reduce } " that takes a sequence of " { $snippet "{ 2map-quot 2reduce-quot }" } " pairs, returning the " { $link 2map-reduce } " result for each pair." } ;

HELP: smart-loop
{ $values { "quot" { $quotation ( ..a -- ..b ? ) } } }
{ $description "A version of " { $link loop } " that runs until the " { $snippet "quot" } " returns " { $link f } " and leaves the result of the quotation on the stack." } ;

ARTICLE: "combinators.smart" "Smart combinators"
"A " { $emphasis "smart combinator" } " is a macro which reflects on the stack effect of an input quotation. The " { $vocab-link "combinators.smart" } " vocabulary implements a few simple smart combinators which look at the static stack effects of input quotations and generate code which produces or consumes the relevant number of stack values." $nl
"Take all input values from a sequence:"
{ $subsections
    input<sequence
    input<sequence-unsafe
}
"Store all output values to a sequence:"
{ $subsections
    output>sequence
    output>array
}
"Reducing the set of output values:"
{ $subsections
    reduce-outputs
    map-reduce-outputs
}
"Applying a quotation to groups of elements on the stack:"
{ $subsections smart-apply }
"Summing output values:"
{ $subsections sum-outputs }
"Concatenating output values:"
{ $subsections
    append-outputs
    append-outputs-as
}
"Drop the outputs after calling a quotation:"
{ $subsections drop-outputs }
"Cause a quotation to act as a no-op and drop the inputs:"
{ $subsection nullary }
"Preserve the inputs below or above the outputs of the quotation:"
{ $subsections preserving keep-inputs }
"Versions of if that infer how many inputs to keep from the predicate quotation:"
{ $subsections smart-if smart-when smart-unless }
"Versions of if* that infer how many inputs to keep from the predicate quotation:"
{ $subsections smart-if* smart-when* smart-unless* }
"New smart combinators can be created by defining " { $link "macros" } " which call " { $link infer } "." ;

ABOUT: "combinators.smart"

! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup kernel sequences quotations
math arrays combinators ;
IN: sequences.generalizations

HELP: nsequence
{ $values { "n" integer } { "seq" "an exemplar" } }
{ $description "A generalization of " { $link 2sequence } ", "
{ $link 3sequence } ", and " { $link 4sequence } " "
"that constructs a sequence from the top " { $snippet "n" } " elements of the stack."
}
{ $examples
    { $example "USING: prettyprint sequences.generalizations ;" "CHAR: f CHAR: i CHAR: s CHAR: h 4 \"\" nsequence ." "\"fish\"" }
} ;

HELP: narray
{ $values { "n" integer } }
{ $description "A generalization of " { $link 1array } ", "
{ $link 2array } ", " { $link 3array } " and " { $link 4array } " "
"that constructs an array from the top " { $snippet "n" } " elements of the stack."
}
{ $examples
    "Some core words expressed in terms of " { $link narray } ":"
    { $table
        { { $link 1array } { $snippet "1 narray" } }
        { { $link 2array } { $snippet "2 narray" } }
        { { $link 3array } { $snippet "3 narray" } }
        { { $link 4array } { $snippet "4 narray" } }
    }
} ;

{ nsequence narray } related-words

HELP: firstn
{ $values { "n" integer } }
{ $description "A generalization of " { $link first } ", "
{ $link first2 } ", " { $link first3 } " and " { $link first4 } " "
"that pushes the first " { $snippet "n" } " elements of a sequence on the stack."
}
{ $examples
    "Some core words expressed in terms of " { $link firstn } ":"
    { $table
        { { $link first } { $snippet "1 firstn" } }
        { { $link first2 } { $snippet "2 firstn" } }
        { { $link first3 } { $snippet "3 firstn" } }
        { { $link first4 } { $snippet "4 firstn" } }
    }
} ;

HELP: ?firstn
{ $values { "n" integer } }
{ $description "A generalization of " { $link ?first } " that pushes the first " { $snippet "n" } " elements of a sequence on the stack, or " { $link f } " if the sequence is shorter than the requested number of elements." }
{ $examples
    "Some core words expressed in terms of " { $link ?firstn } ":"
    { $table
        { { $link ?first } { $snippet "1 ?firstn" } }
    }
} ;

HELP: set-firstn
{ $values { "n" integer } }
{ $description "A generalization of " { $link set-first } " "
"that sets the first " { $snippet "n" } " elements of a sequence from the top " { $snippet "n" } " elements of the stack." } ;

HELP: lastn
{ $values { "seq" sequence } { "n" integer } { "elts..." { $snippet "n" } " elements on the datastack" } }
{ $description "A generalization of " { $link last } " and " { $link last2 }
" that pushes the last " { $snippet "n" } " elements of a sequence on the stack." }
{ $examples
    "Some core words expressed in terms of " { $link lastn } ":"
    { $table
        { { $link last } { $snippet "1 lastn" } }
        { { $link last2 } { $snippet "2 lastn" } }
    }
} ;

HELP: ?lastn
{ $values { "seq" sequence } { "n" integer } { "elts..." { $snippet "n" } " elements on the datastack" } }
{ $description "A generalization of " { $link ?last } " that pushes the last " { $snippet "n" } " elements of a sequence on the stack, or " { $link f } " if the sequence is shorter than the requested number of elements." }
{ $examples
    "Some core words expressed in terms of " { $link ?lastn } ":"
    { $table
        { { $link ?last } { $snippet "1 ?lastn" } }
    }
} ;

HELP: set-lastn
{ $values { "elts..." { $snippet "n" } " elements on the datastack" } { "seq" sequence } { "n" integer } }
{ $description "A generalization of " { $link set-last }
" that sets the last " { $snippet "n" } " elements of a sequence from the top " { $snippet "n" } " elements of the stack." } ;

HELP: nappend
{ $values
    { "n" integer }
    { "seq" sequence }
}
{ $description "Outputs a new sequence consisting of the elements of the top " { $snippet "n" } " sequences from the datastack in turn." }
{ $errors "Throws an error if any of the sequences contain elements that are not permitted in the sequence type of the first sequence." }
{ $examples
    { $example "USING: math prettyprint sequences.generalizations ;"
               "{ 1 2 } { 3 4 } { 5 6 } { 7 8 } 4 nappend ."
               "{ 1 2 3 4 5 6 7 8 }"
    }
} ;

HELP: nappend-as
{ $values
    { "n" integer } { "exemplar" sequence }
    { "seq" sequence }
}
{ $description "Outputs a new sequence of type " { $snippet "exemplar" } " consisting of the elements of the top " { $snippet "n" } " sequences from the datastack in turn." }
{ $errors "Throws an error if any of the sequences contain elements that are not permitted in the sequence type of the first sequence." }
{ $examples
    { $example "USING: math prettyprint sequences.generalizations ;"
               "{ 1 2 } { 3 4 } { 5 6 } { 7 8 } 4 V{ } nappend-as ."
               "V{ 1 2 3 4 5 6 7 8 }"
    }
} ;

{ nappend nappend-as } related-words

HELP: neach
{ $values { "seq..." { $snippet "n" } " sequences on the datastack" } { "quot" { $quotation ( element... -- ) } } { "n" integer } }
{ $description "A generalization of " { $link each } ", " { $link 2each } ", and " { $link 3each } " that can iterate over any number of sequences in parallel." } ;

HELP: nmap
{ $values { "seq..." { $snippet "n" } " sequences on the datastack" } { "quot" { $quotation ( element... -- result ) } } { "n" integer } { "result" "a sequence of the same type as the first " { $snippet "seq" } } }
{ $description "A generalization of " { $link map } ", " { $link 2map } ", and " { $link 3map } " that can map over any number of sequences in parallel." } ;

HELP: nmap-as
{ $values { "seq..." { $snippet "n" } " sequences on the datastack" } { "quot" { $quotation ( element... -- result ) } } { "exemplar" sequence } { "n" integer } { "result" "a sequence of the same type as " { $snippet "exemplar" } } }
{ $description "A generalization of " { $link map-as } ", " { $link 2map-as } ", and " { $link 3map-as } " that can map over any number of sequences in parallel." } ;

HELP: mnmap
{ $values { "m*seq" { $snippet "m" } " sequences on the datastack" } { "quot" { $quotation ( m*element -- result*n ) } } { "m" integer } { "n" integer } { "result*n" { $snippet "n" } " sequences of the same type as the first " { $snippet "seq" } } }
{ $description "A generalization of " { $link map } ", " { $link 2map } ", and " { $link 3map } " that can map over any number of sequences in parallel and provide any number of output sequences." } ;

HELP: mnmap-as
{ $values { "m*seq" { $snippet "m" } " sequences on the datastack" } { "quot" { $quotation ( m*element -- result*n ) } } { "n*exemplar" { $snippet "n" } " sequences on the datastack" } { "m" integer } { "n" integer } { "result*n" { $snippet "n" } " sequences on the datastack of the same types as the " { $snippet "exemplar" } "s" } }
{ $description "A generalization of " { $link map-as } ", " { $link 2map-as } ", and " { $link 3map-as } " that can map over any number of sequences in parallel and provide any number of output sequences of distinct types." } ;

HELP: nproduce
{ $values { "pred" { $quotation ( -- ? ) } } { "quot" { $quotation "( -- obj1 obj2 ... objn )" } } { "n" integer } { "seq..." { $snippet "n" } " arrays on the datastack" } }
{ $description "A generalization of " { $link produce } " that generates " { $snippet "n" } " arrays in parallel by calling " { $snippet "quot" } " repeatedly until " { $snippet "pred" } " outputs false." } ;

HELP: nproduce-as
{ $values { "pred" { $quotation ( -- ? ) } } { "quot" { $quotation "( -- obj1 obj2 ... objn )" } } { "exemplar..." { $snippet "n" } " sequences on the datastack" } { "n" integer } { "seq..." { $snippet "n" } " sequences on the datastack of the same types as the " { $snippet "exemplar" } "s" } }
{ $description "A generalization of " { $link produce-as } " that generates " { $snippet "n" } " sequences in parallel by calling " { $snippet "quot" } " repeatedly until " { $snippet "pred" } " outputs false." } ;

HELP: nmap-reduce
{ $values { "map-quot" { $quotation ( element... -- intermediate ) } } { "reduce-quot" { $quotation ( prev intermediate -- next ) } } { "n" integer } }
{ $description "A generalization of " { $link map-reduce } " that can be applied to any number of sequences." } ;

HELP: nall?
{ $values { "seqs..." { $snippet "n" } " sequences on the datastack" } { "quot" { $quotation ( element... -- ? ) } } { "n" integer } { "?" boolean } }
{ $description "A generalization of " { $link all? } " that can be applied to any number of sequences." } ;

HELP: nfind
{ $values { "seqs..." { $snippet "n" } " sequences on the datastack" } { "quot" { $quotation ( element... -- ? ) } } { "n" integer } { "i" integer } { "elts..." { $snippet "n" } " elements on the datastack" } }
{ $description "A generalization of " { $link find } " that can be applied to any number of sequences." } ;

HELP: nany?
{ $values { "seqs..." { $snippet "n" } " sequences on the datastack" } { "quot" { $quotation ( element... -- ? ) } } { "n" integer } { "?" boolean } }
{ $description "A generalization of " { $link any? } " that can be applied to any number of sequences." } ;

ARTICLE: "sequences.generalizations" "Generalized sequence words"
"The " { $vocab-link "sequences.generalizations" } " vocabulary defines generalized versions of various sequence operations."
{ $subsections
    narray
    nsequence
    firstn
    set-firstn
    nappend
    nappend-as
}
"Generalized " { $link "sequences-combinators" } ":"
{ $subsections
    neach
    nmap
    nmap-as
    mnmap
    mnmap-as
    nproduce
    nproduce-as
} ;

ABOUT: "sequences.generalizations"

! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math sequences sequences.private ;
IN: sequences.unrolled

HELP: unrolled-collect
{ $values
    { "n" integer } { "quot" { $quotation ( n -- value ) } } { "into" sequence }
}
{ $description "Unrolled version of " { $link collect } ". " { $snippet "n" } " must be a compile-time constant." } ;

HELP: unrolled-each
{ $values
    { "seq" sequence } { "len" integer } { "quot" { $quotation ( x -- ) } }
}
{ $description "Unrolled version of " { $link each } " that iterates over the first " { $snippet "len" } " elements of " { $snippet "seq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-2each
{ $values
    { "xseq" sequence } { "yseq" sequence } { "len" integer } { "quot" { $quotation ( x y -- ) } }
}
{ $description "Unrolled version of " { $link 2each } " that iterates over the first " { $snippet "len" } " elements of " { $snippet "xseq" } " and " { $snippet "yseq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-each-index
{ $values
    { "seq" sequence } { "len" integer } { "quot" { $quotation ( x i -- ) } }
}
{ $description "Unrolled version of " { $link each-index } " that iterates over the first " { $snippet "len" } " elements of " { $snippet "seq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-each-integer
{ $values
    { "n" integer } { "quot" { $quotation ( i -- ) } }
}
{ $description "Unrolled version of " { $link each-integer } ". " { $snippet "n" } " must be a compile-time constant." } ;

HELP: unrolled-map
{ $values
    { "seq" sequence } { "len" integer } { "quot" { $quotation ( x -- newx ) } }
    { "newseq" sequence }
}
{ $description "Unrolled version of " { $link map } " that maps over the first " { $snippet "len" } " elements of " { $snippet "seq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-map-as
{ $values
    { "seq" sequence } { "len" integer } { "quot" { $quotation ( x -- newx ) } } { "exemplar" sequence }
    { "newseq" sequence }
}
{ $description "Unrolled version of " { $link map-as } " that maps over the first " { $snippet "len" } " elements of " { $snippet "seq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-2map
{ $values
    { "xseq" sequence } { "yseq" sequence } { "len" integer } { "quot" { $quotation ( x y -- newx ) } } { "newseq" sequence }
}
{ $description "Unrolled version of " { $link 2map } " that iterates over the first " { $snippet "len" } " elements of " { $snippet "xseq" } " and " { $snippet "yseq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-2map-as
{ $values
    { "xseq" sequence } { "yseq" sequence } { "len" integer } { "quot" { $quotation ( x y -- newx ) } } { "exemplar" sequence } { "newseq" sequence }
}
{ $description "Unrolled version of " { $link 2map-as } " that iterates over the first " { $snippet "len" } " elements of " { $snippet "xseq" } " and " { $snippet "yseq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-map-index
{ $values
    { "seq" sequence } { "len" integer } { "quot" { $quotation ( x i -- newx ) } }
    { "newseq" sequence }
}
{ $description "Unrolled version of " { $link map-index } " that maps over the first " { $snippet "len" } " elements of " { $snippet "seq" } ". " { $snippet "len" } " must be a compile-time constant. If " { $snippet "seq" } " has fewer than " { $snippet "len" } " elements, raises an " { $link unrolled-bounds-error } "." } ;

HELP: unrolled-map-integers-as
{ $values
    { "n" integer } { "quot" { $quotation ( n -- value ) } } { "exemplar" sequence } { "newseq" sequence }
}
{ $description "Unrolled version of " { $link map-integers-as } ". " { $snippet "n" } " must be a compile-time constant." } ;

ARTICLE: "sequences.unrolled" "Unrolled sequence iteration combinators"
"The " { $vocab-link "sequences.unrolled" } " vocabulary provides versions of some of the " { $link "sequences-combinators" } " that unroll their loops, that is, expand to a constant number of repetitions of a quotation rather than an explicit loop. These unrolled combinators all require a constant integer value to indicate the number of unrolled iterations to perform."
$nl
"Unrolled versions of high-level iteration combinators:"
{ $subsections
    unrolled-each
    unrolled-each-index
    unrolled-2each
    unrolled-map
    unrolled-map-index
    unrolled-map-as
    unrolled-2map
    unrolled-2map-as
}
"Unrolled versions of low-level iteration combinators:"
{ $subsections
    unrolled-each-integer
    unrolled-map-integers-as
    unrolled-collect
} ;

ABOUT: "sequences.unrolled"

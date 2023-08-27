! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs classes help.markup help.syntax kernel math
quotations strings ;
IN: combinators.tuple

HELP: 1make-tuple
{ $values
    { "x" object } { "class" class } { "assoc" "a list of " { $link string } "/" { $link quotation } " pairs" }
    { "tuple" tuple }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on " { $snippet "x" } ", assigning the result of each call to the slot named by the corresponding key. The quotations must have the effect " { $snippet "( x -- slot-value )" } ". The order in which the quotations are called is undefined." }
{ $examples
    { $example
        "USING: combinators.tuple math prettyprint ;"
        "IN: scratchpad"
        "TUPLE: demo x y z ;"
        "5 demo {"
        "   { \"x\" [ 10 + ] }"
        "   { \"y\" [ 100 / ] }"
        "} 1make-tuple ."
        "T{ demo { x 15 } { y 1/20 } }"
    }
} ;

HELP: 2make-tuple
{ $values
    { "x" object } { "y" object } { "class" class } { "assoc" assoc }
    { "tuple" tuple }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on " { $snippet "x" } " and " { $snippet "y" } ", assigning the result of each call to the slot named by the corresponding key. The quotations must have the effect " { $snippet "( x y -- slot-value )" } ". The order in which the quotations are called is undefined." } ;

HELP: 3make-tuple
{ $values
    { "x" object } { "y" object } { "z" object } { "class" class } { "assoc" "a list of " { $link string } "/" { $link quotation } " pairs" }
    { "tuple" tuple }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } ", assigning the result of each call to the slot named by the corresponding key. The quotations must have the effect " { $snippet "( x y z -- slot-value )" } ". The order in which the quotations are called is undefined." } ;

HELP: nmake-tuple
{ $values
    { "class" class } { "assoc" "a list of " { $link string } "/" { $link quotation } " pairs" } { "n" integer }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on the top " { $snippet "n" } " values on the datastack below " { $snippet "class" } ", assigning the result of each call to the slot named by the corresponding key. The order in which the quotations are called is undefined." } ;

{ 1make-tuple 2make-tuple 3make-tuple nmake-tuple } related-words

ARTICLE: "combinators.tuple" "Tuple-constructing combinators"
"The " { $vocab-link "combinators.tuple" } " vocabulary provides combinators that construct " { $link tuple } " objects. These provide additional functionality above and beyond built-in " { $link "tuple-constructors" } "."
{ $subsections
    1make-tuple
    2make-tuple
    3make-tuple
    nmake-tuple
} ;

ABOUT: "combinators.tuple"

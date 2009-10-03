! (c)2009 Joe Groff bsd license
USING: assocs classes help.markup help.syntax kernel math
quotations strings ;
IN: combinators.tuple

HELP: 2make-tuple
{ $values
    { "x" object } { "y" object } { "class" class } { "assoc" assoc }
    { "tuple" tuple }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on " { $snippet "x" } " and " { $snippet "y" } ", assigning the result of each call to the slot named by the corresponding key. The quotations must have the effect " { $snippet "( x y -- slot-value )" } ". The order in which the quotations is called is undefined." } ;

HELP: 3make-tuple
{ $values
    { "x" object } { "y" object } { "z" object } { "class" class } { "assoc" "a list of " { $link string } "/" { $link quotation } " pairs" }
    { "tuple" tuple }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } ", assigning the result of each call to the slot named by the corresponding key. The quotations must have the effect " { $snippet "( x y z -- slot-value )" } ". The order in which the quotations is called is undefined." } ;

HELP: make-tuple
{ $values
    { "x" object } { "class" class } { "assoc" "a list of " { $link string } "/" { $link quotation } " pairs" }
    { "tuple" tuple }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on " { $snippet "x" } ", assigning the result of each call to the slot named by the corresponding key. The quotations must have the effect " { $snippet "( x -- slot-value )" } ". The order in which the quotations is called is undefined." } ;

HELP: nmake-tuple
{ $values
    { "class" class } { "assoc" "a list of " { $link string } "/" { $link quotation } " pairs" } { "n" integer }
}
{ $description "Constructs a " { $link tuple } " of " { $snippet "class" } " by calling the quotations making up the values of " { $snippet "assoc" } " on the top " { $snippet "n" } " values on the datastack below " { $snippet "class" } ", assigning the result of each call to the slot named by the corresponding key. The order in which the quotations is called is undefined." } ;

{ make-tuple 2make-tuple 3make-tuple nmake-tuple } related-words

ARTICLE: "combinators.tuple" "Tuple-constructing combinators"
"The " { $vocab-link "combinators.tuple" } " vocabulary provides dataflow combinators that construct " { $link tuple } " objects."
{ $subsections
    make-tuple
    2make-tuple
    3make-tuple
    nmake-tuple
} ;

ABOUT: "combinators.tuple"

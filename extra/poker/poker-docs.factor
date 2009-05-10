USING: help.markup help.syntax strings ;
IN: poker

HELP: <hand>
{ $values { "str" string } { "hand" "a new " { $link hand } } }
{ $description "Creates a new poker hand containing the cards specified in " { $snippet "str" } "." }
{ $examples
    { $example "USING: kernel math.order poker prettyprint ;"
        "\"AC KC QC JC TC\" \"7C 6D 5H 4S 2C\" [ <hand> ] bi@ <=> ." "+lt+" }
    { $example "USING: kernel poker prettyprint ;"
        "\"TC 9C 8C 7C 6C\" \"TH 9H 8H 7H 6H\" [ <hand> ] bi@ = ." "t" }
}
{ $notes "Cards may be specified in any order. Hands are directly comparable to each other on the basis of their computed value. Two hands are considered equal when they would tie in a game (despite being composed of different cards)." } ;

HELP: best-hand
{ $values { "str" string } { "hand" "a new " { $link hand } } }
{ $description "Creates a new poker hand containing the best possible combination of the cards specified in " { $snippet "str" } "." }
{ $examples
    { $example "USING: kernel poker prettyprint ;"
        "\"AS KD JC KH 2D 2S KC\" best-hand >value ." "\"Full House\"" }
} ;

HELP: >cards
{ $values { "hand" hand } { "str" string } }
{ $description "Outputs a string representation of a hand's cards." }
{ $examples
    { $example "USING: poker prettyprint ;"
        "\"AC KC QC JC TC\" <hand> >cards ." "\"AC KC QC JC TC\"" }
} ;

HELP: >value
{ $values { "hand" hand } { "str" string } }
{ $description "Outputs a string representation of a hand's value." }
{ $examples
    { $example "USING: poker prettyprint ;"
        "\"AC KC QC JC TC\" <hand> >value ." "\"Straight Flush\"" }
}
{ $notes "This should not be used as a basis for hand comparison." } ;

HELP: <deck>
{ $values { "deck" "a new " { $link deck } } }
{ $description "Creates a standard deck of 52 cards." } ;

HELP: shuffle
{ $values { "deck" deck } { "deck" "a shuffled " { $link deck } } }
{ $description "Shuffles the cards in " { $snippet "deck" } ", in-place, using the Fisher-Yates algorithm." } ;

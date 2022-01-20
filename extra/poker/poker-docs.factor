USING: help.markup help.syntax math sequences ;
IN: poker

HELP: best-holdem-hand
{ $values { "hand" sequence } { "n" integer } { "cards" sequence } }
{ $description "Creates a new poker hand containing the best possible combination of the cards specified in " { $snippet "seq" } "." }
{ $examples
    { $example "USING: kernel poker prettyprint ;"
        "HAND{ AS KD JC KH 2D 2S KC } best-holdem-hand drop value>hand-name ."
        "\"Full House\""
    }
} ;

HELP: <deck>
{ $values { "deck" sequence } }
{ $description "Returns a vector containing a standard, shuffled deck of 52 cards." } ;

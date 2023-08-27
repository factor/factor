! Copyright (c) 2009, 2020 Samuel Tardieu, Alexander Ilin.
! See See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations sequences ;
IN: backtrack

ABOUT: "backtrack"

ARTICLE: "backtrack" "Simple backtracking non-determinism"
"The " { $vocab-link "backtrack" } " vocabulary implements simple non-determinism by selecting an element of a sequence, performing a test and backtracking to select the next element if the test fails."
$nl
"Find a first successful element:"
{ $subsections if-amb }
"Find all combinations of successful elements:"
{ $subsections amb-all bag-of }
"Select elements from a sequence:"
{ $subsections amb amb-lazy }
{ $examples
    "Let's solve the following puzzle: a farmer has some chickens and some cows for a total of 30 animal, and the animals have 74 legs in total."
    { $unchecked-example
        ": check ( chickens cows -- ? )"
        "    [ + 30 = ] [ 4 * swap 2 * + 74 = ] 2bi and ;"
        ""
        "["
        "    1 30 [a..b] amb 1 30 [a..b] amb"
        "    [ check must-be-true ] [ 2array ] 2bi"
        "] bag-of ."
        "V{ { 23 7 } }"
    }
    "The output means there is only one solution: the farmer has 23 chickens and 7 cows. If we want to only find the first solution, the following approach could be used:"
    { $unchecked-example
        ": check ( chickens cows -- ? )"
        "    [ + 30 = ] [ 4 * swap 2 * + 74 = ] 2bi and ;"
        ""
        "["
        "    1 30 [a..b] amb 1 30 [a..b] amb"
        "    2dup check must-be-true"
        "    \"%d chickens, %d cows\\n\" printf"
        "    t"
        "] [ \"No solution.\" print ] if-amb drop"
        "23 chickens, 7 cows"
    }
    "See more examples here: " { $url "https://re.factorcode.org/tags/backtrack.html" }
} ;

HELP: fail
{ $description "Signal that the current alternative is not acceptable. This will cause either backtracking to occur, or a failure to be signalled, as explained in the " { $link amb } " word description." }
{ $see-also amb cut-amb }
;

HELP: amb
{ $values
  { "seq" "the alternatives" }
  { "elt" "one of the alternatives" }
}
{ $description "The amb (ambiguous) word saves the state of the current computation (through the " { $vocab-link "continuations" } " vocabulary) and returns the first alternative. When " { $link fail } " is invoked, the saved state will be restored and the next alternative will be returned. When there are no more alternatives, " { $link fail } " will go up one level to the location of the previous " { $link amb } " call. If there are no more calls up the chain, an error will be signalled." }
{ $see-also fail cut-amb }
;

HELP: cut-amb
{ $description "Reset the amb system. Calling this word resets the whole stack of " { $link amb } " calls and should not be done lightly." }
{ $see-also amb fail }
;

HELP: amb-execute
{ $values
  { "seq" "a list of words" }
}
{ $description "Execute the first word in the list, and go to the next one if " { $link fail } " is called." } ;

HELP: if-amb
{ $values
  { "true" { $quotation ( -- ? ) } }
  { "false" quotation }
  { "?" boolean }
}
{ $description "Execute the first quotation and return " { $link t } " if it returns " { $link t } " itself. If it fails with " { $link fail } " or returns " { $link f } ", then the second quotation is executed and " { $link f } " is returned." } ;

HELP: amb-all
{ $values
  { "quot" { $quotation ( -- ) } }
}
{ $description "Execute all the alternatives in the quotation by calling " { $link fail } " repeatedly at the end." }
{ $see-also bag-of fail }
;

HELP: bag-of
{ $values
  { "quot" { $quotation ( -- result ) } }
  { "seq" sequence }
}
{ $description "Execute all the alternatives in the quotation and collect the results." }
{ $see-also amb-all } ;

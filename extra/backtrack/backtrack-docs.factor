! Copyright (c) 2009 Samuel Tardieu.
! See See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations sequences ;
IN: backtrack

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
{ $description "Execute the first quotation and returns " { $link t } " if it returns " { $link t } " itself. If it fails with " { $link fail } " or returns " { $link f } ", then the second quotation is executed and " { $link f } " is returned." } ;

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

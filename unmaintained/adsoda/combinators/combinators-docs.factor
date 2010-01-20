! Copyright (C) 2008 Jeff Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel sequences ;
IN: adsoda.combinators

HELP: among
{ $values
     { "array" array } { "n" "number of value to select" }
     { "array" array }
}
{ $description "returns an array containings every possibilities of n choices among a given sequence" } ;

HELP: columnize
{ $values
     { "array" array }
     { "array" array }
}
{ $description "flip a sequence into a sequence of 1 element sequences" } ;

HELP: concat-nth
{ $values
     { "seq1" sequence } { "seq2" sequence }
     { "seq" sequence }
}
{ $description "merges 2 sequences of sequences appending corresponding elements" } ;

HELP: do-cycle
{ $values
     { "array" array }
     { "array" array }
}
{ $description "Copy the first element at the end of the sequence in order to close the cycle." } ;


ARTICLE: "adsoda.combinators" "Combinators"
{ $vocab-link "adsoda.combinators" }
;

ABOUT: "adsoda.combinators"

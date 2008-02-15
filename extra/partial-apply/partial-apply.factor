
USING: kernel sequences quotations math parser
       shuffle combinators.cleave combinators.lib sequences.lib ;

IN: partial-apply

! Basic conceptual implementation. Todo: get it to compile.

: apply-n ( obj quot i -- quot ) 1+ [ -nrot ] curry swap compose curry ;

SYMBOL: _

SYMBOL: ~

: blank-positions ( quot -- seq )
  [ length 2 - ] [ _ indices ] bi [ - ] map-with ;
  
: partial-apply ( pattern -- quot )
  [ blank-positions length nrev ]
  [ peek 1quotation ]
  [ blank-positions ]
  tri
  [ apply-n ] each ;

: $[ \ ] [ >quotation ] parse-literal \ partial-apply parsed ; parsing


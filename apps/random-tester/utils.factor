USING: kernel math sequences namespaces errors hashtables words
arrays parser compiler syntax io optimizer inference tools
prettyprint ;
IN: random-tester

: pick-one ( seq -- elt )
    [ length random-int ] keep nth ;

! HASHTABLES
: random-hash-entry ( hash -- key value )
    hash>alist pick-one first2 ;

: coin-flip ( -- bool ) 2 random-int zero? ;
: do-one ( seq -- ) pick-one call ; inline

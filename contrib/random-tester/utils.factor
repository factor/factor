USING: kernel math sequences namespaces errors hashtables words
arrays parser compiler syntax io optimizer inference tools
prettyprint ;
IN: random-tester

: nth-rand ( seq -- elem ) [ length random-int ] keep nth ;

! HASHTABLES
: random-hash-entry ( hash -- key value )
    hash>alist nth-rand first2 ;

! ARRAYS
: 4array ( a b c d -- seq ) 2array >r 2array r> append ;

: coin-flip ( -- bool ) 2 random-int 1 = ;

! UNCOMPILABLES
: do-one ( seq -- ) nth-rand call ;

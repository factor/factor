USING: kernel math sequences namespaces errors hashtables words arrays parser
       compiler syntax lists io math-contrib ;
USING: optimizer compiler-frontend compiler-backend inference
       inspector prettyprint ;
IN: random-tester


! HASHTABLES
: random-hash-entry ( hash -- key value ) hash>alist nth-rand first2 ;

! ARRAYS
: 4array ( a b c d -- seq ) 2array >r 2array r> append ;

: coin-flip ( -- bool ) 2 random-int 1 = ;

! UNCOMPILABLES
: do-one ( seq -- ) nth-rand call ;




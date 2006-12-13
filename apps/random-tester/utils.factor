USING: kernel math sequences namespaces errors hashtables words
arrays parser compiler syntax io optimizer inference shuffle
tools prettyprint ;
IN: random-tester

: pick-one ( seq -- elt )
    [ length random-int ] keep nth ;

! HASHTABLES
: random-hash-entry ( hash -- key value )
    hash>alist pick-one first2 ;

: coin-flip ( -- bool ) 2 random-int zero? ;
: do-one ( seq -- ) pick-one call ; inline

: nzero-array ( seq -- )
    dup length >r 0 r> [ pick set-nth ] each-with drop ;
    
: zero-array
    [ drop 0 ] map ;

TUPLE: p-list seq max counter ;
: make-p-list ( seq -- tuple )
    dup length [ 1- ] keep zero-array <p-list> ;

: inc-seq ( seq max -- )
    2dup [ < ] curry find-last over -1 = [
        3drop nzero-array
    ] [
        nipd 1+ 2over swap set-nth
        1+ over length rot <slice> nzero-array
    ] if ;

: get-permutation ( tuple -- seq )
    [ p-list-seq ] keep p-list-counter [ swap nth ] map-with ;

: p-list-next ( tuple -- seq )
    [ get-permutation ] keep 
    [ p-list-counter ] keep p-list-max inc-seq ;

: permutations ( seq -- seq )
    ;


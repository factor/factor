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

TUPLE: p-list seq max count count-vec ;
: make-p-list ( seq n -- tuple )
    >r dup length [ 1- ] keep r>
    [ ^ 0 swap 2array ] keep
    zero-array <p-list> ;

: inc-seq ( seq max -- )
    2dup [ < ] curry find-last over -1 = [
        3drop nzero-array
    ] [
        nipd 1+ 2over swap set-nth
        1+ over length rot <slice> nzero-array
    ] if ;

: inc-count ( tuple -- )
    [ p-list-count first2 >r 1+ r> 2array ] keep
    set-p-list-count ;

: get-permutation ( tuple -- seq )
    [ p-list-seq ] keep p-list-count-vec [ swap nth ] map-with ;

: p-list-next ( tuple -- seq/f )
    dup p-list-count first2 < [
        [
            [ get-permutation ] keep 
            [ p-list-count-vec ] keep p-list-max
            inc-seq
        ] keep inc-count
    ] [
        drop f
    ] if ;

: (permutations) ( tuple -- )
    dup p-list-next [ , (permutations) ] [ drop ] if* ;

: permutations ( seq n -- seq )
    make-p-list
    [
        (permutations)
    ] { } make ;

: (each-permutation) ( tuple quot -- )
    over p-list-next [
        [ rot drop swap call ] 3keep
        drop (each-permutation)
    ] [
        2drop
    ] if* ; inline

: each-permutation ( seq n quot -- )
    >r make-p-list r> (each-permutation) ;


USING: arrays assocs combinators.lib continuations kernel
math math.functions memoize namespaces quotations random sequences
sequences.private shuffle ;

IN: random-tester.utils

: %chance ( n -- ? )
    100 random > ;

: 10% ( -- ? ) 10 %chance ;
: 20% ( -- ? ) 20 %chance ;
: 30% ( -- ? ) 30 %chance ;
: 40% ( -- ? ) 40 %chance ;
: 50% ( -- ? ) 50 %chance ;
: 60% ( -- ? ) 60 %chance ;
: 70% ( -- ? ) 70 %chance ;
: 80% ( -- ? ) 80 %chance ;
: 90% ( -- ? ) 90 %chance ;

: call-if ( quot ? -- ) [ call ] [ drop ] if ; inline

: with-10% ( quot -- ) 10% call-if ; inline
: with-20% ( quot -- ) 20% call-if ; inline
: with-30% ( quot -- ) 30% call-if ; inline
: with-40% ( quot -- ) 40% call-if ; inline
: with-50% ( quot -- ) 50% call-if ; inline
: with-60% ( quot -- ) 60% call-if ; inline
: with-70% ( quot -- ) 70% call-if ; inline
: with-80% ( quot -- ) 80% call-if ; inline
: with-90% ( quot -- ) 90% call-if ; inline

: random-hash-key keys random ;
: random-hash-value [ random-hash-key ] keep at ;

: do-one ( seq -- ) random call ; inline

TUPLE: p-list seq max count count-vec ;

: reset-array ( seq -- )
    [ drop 0 ] over map-into ;

C: <p-list> p-list

: make-p-list ( seq n -- tuple )
    >r dup length [ 1- ] keep r>
    [ ^ 0 swap 2array ] keep
    0 <array> <p-list> ;

: inc-seq ( seq max -- )
    2dup [ < ] curry find-last over [
        nipd 1+ 2over swap set-nth
        1+ over length rot <slice> reset-array
    ] [
        3drop reset-array
    ] if ;

: inc-count ( tuple -- )
    [ p-list-count first2 >r 1+ r> 2array ] keep
    set-p-list-count ;

: (get-permutation) ( seq index-seq -- newseq )
    [ swap nth ] map-with ;

: get-permutation ( tuple -- seq )
    [ p-list-seq ] keep p-list-count-vec (get-permutation) ;

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
    make-p-list [ (permutations) ] { } make ;

: (each-permutation) ( tuple quot -- )
    over p-list-next [
        [ rot drop swap call ] 3keep
        drop (each-permutation)
    ] [
        2drop
    ] if* ; inline

: each-permutation ( seq n quot -- )
    >r make-p-list r> (each-permutation) ;


MEMO: builder-permutations ( n -- seq )
    { compose curry } swap permutations
    [ >quotation ] map ; foldable

: all-quot-permutations ( seq -- newseq )
    dup length 1- builder-permutations
    swap [ 1quotation ] map dup length permutations
    [ swap [ >r seq>stack r> call ] curry* map ] curry* map ;

! clear { map sq 10 } all-quot-permutations [ [ [ [ [ call ] keep datastack length 2 = [ . .s nl ] when ] catch ] in-thread drop ] each ] each

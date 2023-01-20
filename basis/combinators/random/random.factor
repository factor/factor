! Copyright (C) 2010 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators combinators.short-circuit
kernel math math.order quotations random sequences summary ;
IN: combinators.random

: ifp ( p true false -- ) [ random-unit > ] 2dip if ; inline

: whenp ( p true -- ) [ ] ifp ; inline

: unlessp ( p false -- ) [ [ ] ] dip ifp ; inline

<PRIVATE

: with-drop ( quot -- quot' ) [ drop ] prepend ; inline

: prepare-pair ( pair -- pair' )
    first2 [ [ [ - ] [ < ] 2bi ] curry ] [ with-drop ] bi* 2array ;

ERROR: bad-probabilities assoc ;

M: bad-probabilities summary
    drop "The probabilities do not satisfy the rules stated in the docs." ;

: good-probabilities? ( assoc -- ? )
    dup last pair? [
        keys { [ sum 1 number= ] [ [ 0 1 between? ] all? ] } 1&&
    ] [
        but-last keys { [ sum 0 1 between? ] [ [ 0 1 between? ] all? ] } 1&&
    ] if ;

! Useful for unit-tests (no random part)
: (casep>quot) ( assoc -- quot )
    dup good-probabilities? [
        [ dup pair? [ prepare-pair ] [ with-drop ] if ] map
        cond>quot
    ] [ bad-probabilities ] if ;

MACRO: (casep) ( assoc -- quot ) (casep>quot) ;

: casep>quot ( assoc -- quot )
    (casep>quot) [ random-unit ] prepend ;

: (conditional-probabilities) ( seq i -- p )
    [ dup 0 > [ head [ 1 swap - ] [ * ] map-reduce ] [ 2drop 1 ] if ]
    [ swap nth ] 2bi * ;

: conditional-probabilities ( seq -- seq' )
    dup length <iota> [ (conditional-probabilities) ] with map ;

: (direct>conditional) ( assoc -- assoc' )
    [ keys conditional-probabilities ] [ values ] bi zip ;

: direct>conditional ( assoc -- assoc' )
    dup last pair? [ (direct>conditional) ] [
        unclip-last [ (direct>conditional) ] [ suffix ] bi*
    ] if ;

: call-random>casep ( seq -- assoc )
    [ length recip ] keep [ 2array ] with map ;

PRIVATE>

MACRO: casep ( assoc -- quot ) casep>quot ;

MACRO: casep* ( assoc -- quot ) direct>conditional casep>quot ;

MACRO: call-random ( seq -- quot ) call-random>casep casep>quot ;

MACRO: execute-random ( seq -- quot )
    [ 1quotation ] map call-random>casep casep>quot ;

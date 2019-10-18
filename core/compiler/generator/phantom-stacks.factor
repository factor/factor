! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: arrays generic hashtables inference io kernel math
namespaces prettyprint sequences vectors words ;

SYMBOL: phantom-d
SYMBOL: phantom-r

! A data stack location.
TUPLE: ds-loc n ;

! A retain stack location.
TUPLE: rs-loc n ;

UNION: loc ds-loc rs-loc ;

TUPLE: phantom-stack height ;

C: phantom-stack ( -- stack )
    0 over set-phantom-stack-height
    V{ } clone over set-delegate ;

GENERIC: finalize-height ( stack -- )

GENERIC: <loc> ( n stack -- loc )

: (loc)
    #! Utility for methods on <loc>
    phantom-stack-height - ;

: (finalize-height) ( stack word -- )
    #! We consolidate multiple stack height changes until the
    #! last moment, and we emit the final height changing
    #! instruction here.
    swap [
        phantom-stack-height
        dup zero? [ 2drop ] [ swap execute ] if
        0
    ] keep set-phantom-stack-height ; inline

TUPLE: phantom-datastack ;

C: phantom-datastack
    [ >r <phantom-stack> r> set-delegate ] keep ;

M: phantom-datastack <loc> (loc) <ds-loc> ;

M: phantom-datastack finalize-height
    \ %inc-d (finalize-height) ;

TUPLE: phantom-retainstack ;

C: phantom-retainstack
    [ >r <phantom-stack> r> set-delegate ] keep ;

M: phantom-retainstack <loc> (loc) <rs-loc> ;

M: phantom-retainstack finalize-height
    \ %inc-r (finalize-height) ;

: phantom-locs ( n phantom -- locs )
    #! A sequence of n ds-locs or rs-locs indexing the stack.
    swap <reversed> [ swap <loc> ] map-with ;

: phantom-locs* ( phantom -- locs )
    dup length swap phantom-locs ;

: (each-loc) ( phantom quot -- )
    >r dup phantom-locs* r> 2each ; inline

: each-loc ( quot -- )
    >r phantom-d get r> phantom-r get over
    >r >r (each-loc) r> r> (each-loc) ; inline

: adjust-phantom ( n phantom -- )
    [ phantom-stack-height + ] keep set-phantom-stack-height ;

: phantom-push ( obj stack -- )
    1 over adjust-phantom push ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom nappend ;

GENERIC: cut-phantom ( n phantom -- seq )

M: phantom-stack cut-phantom
    [ delegate cut* swap ] keep set-delegate ;

: phantoms ( -- phantom phantom ) phantom-d get phantom-r get ;

: each-phantom ( quot -- ) phantoms rot 2apply ; inline

: finalize-heights ( -- )
    phantoms [ finalize-height ] 2apply ;

! Phantom stacks hold values, locs, and vregs
UNION: pseudo loc value ;

: live-vregs ( -- seq ) phantoms append [ vreg? ] subset ;

: live-loc? ( current actual -- ? )
    over loc? [ = not ] [ 2drop f ] if ;

: (live-locs) ( phantom -- seq )
    #! Discard locs which haven't moved
    dup phantom-locs* [ 2array ] 2map
    [ first2 live-loc? ] subset
    0 <column> ;

: live-locs ( -- seq )
    [ (live-locs) ] each-phantom append prune ;

! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel kernel.private slots.private math
assocs math.private sequences sequences.private vectors ;
IN: hashtables

TUPLE: hashtable
{ count array-capacity }
{ deleted array-capacity }
{ array array } ;

<PRIVATE

: wrap ( i array -- n )
    length>> 1 fixnum-fast fixnum-bitand ; inline

: hash@ ( key array -- i )
    [ hashcode >fixnum dup fixnum+fast ] dip wrap ; inline

: probe ( array i -- array i )
    2 fixnum+fast over wrap ; inline

: no-key ( key array -- array n ? ) nip f f ; inline

: (key@) ( key array i -- array n ? )
    3dup swap array-nth
    dup ((empty)) eq?
    [ 3drop no-key ] [
        = [ rot drop t ] [ probe (key@) ] if
    ] if ; inline recursive

: key@ ( key hash -- array n ? )
    array>> dup length>> 0 eq?
    [ no-key ] [ 2dup hash@ (key@) ] if ; inline

: <hash-array> ( n -- array )
    1 + next-power-of-2 4 * ((empty)) <array> ; inline

: init-hash ( hash -- )
    0 >>count 0 >>deleted drop ; inline

: reset-hash ( n hash -- )
    swap <hash-array> >>array init-hash ; inline

: (new-key@) ( key keys i -- keys n empty? )
    3dup swap array-nth dup ((empty)) eq? [
        2drop rot drop t
    ] [
        = [
            rot drop f
        ] [
            probe (new-key@)
        ] if
    ] if ; inline recursive

: new-key@ ( key hash -- array n empty? )
    array>> 2dup hash@ (new-key@) ; inline

: set-nth-pair ( value key seq n -- )
    2 fixnum+fast [ set-slot ] 2keep
    1 fixnum+fast set-slot ; inline

: hash-count+ ( hash -- )
    [ 1 + ] change-count drop ; inline

: hash-deleted+ ( hash -- )
    [ 1 + ] change-deleted drop ; inline

: (rehash) ( hash alist -- )
    swap [ swapd set-at ] curry assoc-each ; inline

: hash-large? ( hash -- ? )
    [ count>> 3 fixnum*fast 1 fixnum+fast ]
    [ array>> length>> ] bi fixnum> ; inline

: hash-stale? ( hash -- ? )
    [ deleted>> 10 fixnum*fast ] [ count>> ] bi fixnum> ; inline

: grow-hash ( hash -- )
    [ [ >alist ] [ assoc-size 1 + ] bi ] keep
    [ reset-hash ] keep
    swap (rehash) ;

: ?grow-hash ( hash -- )
    dup hash-large? [
        grow-hash
    ] [
        dup hash-stale? [
            grow-hash
        ] [
            drop
        ] if
    ] if ; inline

PRIVATE>

: <hashtable> ( n -- hash )
    hashtable new [ reset-hash ] keep ; inline

M: hashtable at* ( key hash -- value ? )
    key@ [ 3 fixnum+fast slot t ] [ 2drop f f ] if ;

M: hashtable clear-assoc ( hash -- )
    [ init-hash ] [ array>> [ drop ((empty)) ] change-each ] bi ;

M: hashtable delete-at ( key hash -- )
    [ nip ] [ key@ ] 2bi [
        [ ((tombstone)) dup ] 2dip set-nth-pair
        hash-deleted+
    ] [
        3drop
    ] if ;

M: hashtable assoc-size ( hash -- n )
    [ count>> ] [ deleted>> ] bi - ;

: rehash ( hash -- )
    dup >alist [
    dup clear-assoc
    ] dip (rehash) ;

M: hashtable set-at ( value key hash -- )
    dup ?grow-hash
    2dup new-key@
    [ rot hash-count+ set-nth-pair ]
    [ rot drop set-nth-pair ] if ;

: associate ( value key -- hash )
    2 <hashtable> [ set-at ] keep ;

<PRIVATE

: push-unsafe ( elt seq -- )
    [ length ] keep
    [ underlying>> set-array-nth ]
    [ [ 1 fixnum+fast { array-capacity } declare ] dip (>>length) ]
    2bi ; inline

PRIVATE>

M: hashtable >alist
    [ array>> [ length 2/ iota ] keep ] [ assoc-size <vector> ] bi [
        [
            [
                [ 1 fixnum-shift-fast ] dip
                [ array-nth ] [ [ 1 fixnum+fast ] dip array-nth ] 2bi
            ] dip
            pick tombstone? [ 3drop ] [ [ 2array ] dip push-unsafe ] if
        ] 2curry each
    ] keep { } like ;

M: hashtable clone
    (clone) [ clone ] change-array ;

M: hashtable equal?
    over hashtable? [
        2dup [ assoc-size ] bi@ eq?
        [ assoc= ] [ 2drop f ] if
    ] [ 2drop f ] if ;

! Default method
M: assoc new-assoc drop <hashtable> ;

M: f new-assoc drop <hashtable> ;

: >hashtable ( assoc -- hashtable )
    H{ } assoc-clone-like ;

M: hashtable assoc-like
    drop dup hashtable? [ >hashtable ] unless ;

: ?set-at ( value key assoc/f -- assoc )
    [ [ set-at ] keep ] [ associate ] if* ;

INSTANCE: hashtable assoc

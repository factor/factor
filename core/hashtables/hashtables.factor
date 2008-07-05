! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel kernel.private slots.private math
assocs math.private sequences sequences.private vectors grouping ;
IN: hashtables

TUPLE: hashtable
{ count array-capacity }
{ deleted array-capacity }
{ array array } ;

<PRIVATE

: wrap ( i array -- n )
    array-capacity 1 fixnum-fast fixnum-bitand ; inline

: hash@ ( key array -- i )
    >r hashcode >fixnum dup fixnum+fast r> wrap ; inline

: probe ( array i -- array i )
    2 fixnum+fast over wrap ; inline

: (key@) ( key keys i -- array n ? )
    3dup swap array-nth
    dup ((empty)) eq?
    [ 3drop nip f f ] [
        = [ rot drop t ] [ probe (key@) ] if
    ] if ; inline

: key@ ( key hash -- array n ? )
    array>> 2dup hash@ (key@) ; inline

: <hash-array> ( n -- array )
    1+ next-power-of-2 4 * ((empty)) <array> ; inline

: init-hash ( hash -- )
    0 >>count 0 >>deleted drop ; inline

: reset-hash ( n hash -- )
    swap <hash-array> >>array init-hash ;

: (new-key@) ( key keys i -- keys n empty? )
    3dup swap array-nth dup ((empty)) eq? [
        2drop rot drop t
    ] [
        = [
            rot drop f
        ] [
            probe (new-key@)
        ] if
    ] if ; inline

: new-key@ ( key hash -- array n empty? )
    array>> 2dup hash@ (new-key@) ; inline

: set-nth-pair ( value key seq n -- )
    2 fixnum+fast [ set-slot ] 2keep
    1 fixnum+fast set-slot ; inline

: hash-count+ ( hash -- )
    [ 1+ ] change-count drop ; inline

: hash-deleted+ ( hash -- )
    [ 1+ ] change-deleted drop ; inline

: (set-hash) ( value key hash -- new? )
    2dup new-key@
    [ rot hash-count+ set-nth-pair t ]
    [ rot drop set-nth-pair f ] if ; inline

: (rehash) ( hash alist -- )
    swap [ swapd (set-hash) drop ] curry assoc-each ;

: hash-large? ( hash -- ? )
    [ count>> 3 fixnum*fast  ]
    [ array>> array-capacity ] bi > ;

: hash-stale? ( hash -- ? )
    [ deleted>> 10 fixnum*fast ] [ count>> ] bi fixnum> ;

: grow-hash ( hash -- )
    [ dup >alist swap assoc-size 1+ ] keep
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
    hashtable new [ reset-hash ] keep ;

M: hashtable at* ( key hash -- value ? )
    key@ [ 3 fixnum+fast slot t ] [ 2drop f f ] if ;

M: hashtable clear-assoc ( hash -- )
    [ init-hash ] [ array>> [ drop ((empty)) ] change-each ] bi ;

M: hashtable delete-at ( key hash -- )
    tuck key@ [
        >r >r ((tombstone)) dup r> r> set-nth-pair
        hash-deleted+
    ] [
        3drop
    ] if ;

M: hashtable assoc-size ( hash -- n )
    [ count>> ] [ deleted>> ] bi - ;

: rehash ( hash -- )
    dup >alist >r
    dup clear-assoc
    r> (rehash) ;

M: hashtable set-at ( value key hash -- )
    dup >r (set-hash) [ r> ?grow-hash ] [ r> drop ] if ;

: associate ( value key -- hash )
    2 <hashtable> [ set-at ] keep ;

M: hashtable >alist
    array>> 2 <groups> [ first tombstone? not ] filter ;

M: hashtable clone
    (clone) [ clone ] change-array ;

M: hashtable equal?
    over hashtable? [
        2dup [ assoc-size ] bi@ number=
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

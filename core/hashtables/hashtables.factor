! Copyright (C) 2005, 2011 John Benediktsson, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel kernel.private math
math.private sequences sequences.private slots.private vectors ;
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

: probe ( array i probe# -- array i probe# )
    2 fixnum+fast [ fixnum+fast over wrap ] keep ; inline

: no-key ( key array -- array n ? ) nip f f ; inline

: (key@) ( key array i probe# -- array n ? )
    [ 3dup swap array-nth ] dip over +empty+ eq?
    [ 4drop no-key ] [
        [ = ] dip swap
        [ drop rot drop t ]
        [ probe (key@) ]
        if
    ] if ; inline recursive

: key@ ( key hash -- array n ? )
    array>> dup length>> 0 eq?
    [ no-key ] [ 2dup hash@ 0 (key@) ] if ; inline

: <hash-array> ( n -- array )
    3 * 1 + 2/ next-power-of-2 2 * +empty+ <array> ; inline

: init-hash ( hash -- )
    0 >>count 0 >>deleted drop ; inline

: reset-hash ( n hash -- )
    swap <hash-array> >>array init-hash ; inline

: hash-count+ ( hash -- )
    [ 1 fixnum+fast ] change-count drop ; inline

: hash-deleted+ ( hash -- )
    [ 1 fixnum+fast ] change-deleted drop ; inline

: hash-deleted- ( hash -- )
    [ 1 fixnum-fast ] change-deleted drop ; inline

! i = first-empty-or-found
! j = first-deleted
! empty? = if true, key was not found
!
! if empty? is f:
! - we want to store into i
!
! if empty? is t:
! - we want to store into j if j is not f
! - otherwise we want to store into i
! - ... and increment count

: (new-key@) ( key array i probe# j -- array i j empty? )
    [ 2dup swap array-nth ] 2dip pick tombstone?
    [
        rot +empty+ eq?
        [ nip [ drop ] 3dip t ]
        [ pick or [ probe ] dip (new-key@) ]
        if
    ] [
        [ pickd = ] 2dip rot
        [ nip [ drop ] 3dip f ]
        [ [ probe ] dip (new-key@) ]
        if
    ] if ; inline recursive

: new-key@ ( key hash -- array n )
    [ array>> 2dup hash@ 0 f (new-key@) ] keep swap
    [ over [ hash-deleted- ] [ hash-count+ ] if swap or ] [ 2drop ] if ; inline

: set-nth-pair ( value key array n -- )
    2 fixnum+fast [ set-slot ] 2keep
    1 fixnum+fast set-slot ; inline

: (set-at) ( value key hash -- )
    dupd new-key@ set-nth-pair ; inline

: (rehash) ( alist hash -- )
    [ swapd (set-at) ] curry assoc-each ; inline

: hash-large? ( hash -- ? )
    [ count>> 1 fixnum+fast 3 fixnum*fast ]
    [ array>> length>> ] bi fixnum>= ; inline

: each-pair ( ... array quot: ( ... key value -- ... ) -- ... )
    [
        [ length 2/ ] keep [
            [ 1 fixnum-shift-fast ] dip [ array-nth ] 2keep
            pick tombstone? [ 3drop ]
        ] curry
    ] dip [ [ 1 fixnum+fast ] dip array-nth ] prepose
    [ if ] curry compose each-integer ; inline

: grow-hash ( hash -- )
    { hashtable } declare [
        [ array>> ]
        [ assoc-size 1 + ]
        [ reset-hash ] tri
    ] keep [ swapd (set-at) ] curry each-pair ;

: ?grow-hash ( hash -- )
    dup hash-large? [ grow-hash ] [ drop ] if ; inline

PRIVATE>

: <hashtable> ( n -- hash )
    integer>fixnum-strict
    [ 0 0 ] dip <hash-array> hashtable boa ; inline

M: hashtable at*
    key@ [ 3 fixnum+fast slot t ] [ 2drop f f ] if ;

M: hashtable clear-assoc
    [ init-hash ] [ array>> [ drop +empty+ ] map! drop ] bi ;

M: hashtable delete-at
    [ nip ] [ key@ ] 2bi [
        [ +tombstone+ dup ] 2dip set-nth-pair
        hash-deleted+
    ] [
        3drop
    ] if ;

M: hashtable assoc-size
    [ count>> ] [ deleted>> ] bi - ; inline

: rehash ( hash -- )
    [ >alist ] [ clear-assoc ] [ (rehash) ] tri ;

M: hashtable set-at
    dup ?grow-hash (set-at) ;

: associate ( value key -- hash )
    [ 1 0 ] 2dip 1 <hash-array>
    [ 2dup hash@ set-nth-pair ] keep
    hashtable boa ; inline

<PRIVATE

: collect-pairs ( hash quot: ( key value -- elt ) -- seq )
    [ [ array>> 0 swap ] [ assoc-size f <array> ] bi ] dip swap [
        [ overd set-nth-unsafe 1 + ] curry compose each-pair
    ] keep nip ; inline

PRIVATE>

M: hashtable >alist [ 2array ] collect-pairs ;

M: hashtable keys [ drop ] collect-pairs ;

M: hashtable values [ nip ] collect-pairs ;

M: hashtable unzip
    [ assoc-size dup [ <vector> ] bi@ ] [ array>> ] bi
    [ [ suffix! ] bi-curry@ bi* ] each-pair [ { } like ] bi@ ;

M: hashtable clone
    (clone) [ clone ] change-array ; inline

M: hashtable equal?
    over hashtable? [ assoc= ] [ 2drop f ] if ;

M: hashtable hashcode*
    [
        dup assoc-size 1 eq?
        [ assoc-hashcode ] [ nip assoc-size ] if
    ] recursive-hashcode ;

! Default method
M: assoc new-assoc drop <hashtable> ; inline

M: f new-assoc drop <hashtable> ; inline

: >hashtable ( assoc -- hashtable )
    [ >alist ] [ assoc-size <hashtable> ] bi [ (rehash) ] keep ;

M: hashtable assoc-like
    drop dup hashtable? [ >hashtable ] unless ; inline

: ?set-at ( value key assoc/f -- assoc )
    [ [ set-at ] keep ] [ associate ] if* ;

! borrowed from boost::hash_combine, but the
! magic number is 2^29/phi instead of 2^32/phi
! due to max fixnum value on 32-bit machines
: hash-combine ( hash1 hash2 -- newhash )
    [ 0x13c6ef37 + ] dip [ 6 shift ] [ -2 shift ] bi + + ; inline

ERROR: malformed-hashtable-pair seq pair ;

: check-hashtable ( seq -- seq )
    dup [ dup length 2 = [ drop ] [ malformed-hashtable-pair ] if ] each ;

: parse-hashtable ( seq -- hashtable )
    check-hashtable H{ } assoc-clone-like ;

INSTANCE: hashtable assoc

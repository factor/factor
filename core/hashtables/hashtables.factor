! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private slots.private math assocs
math.private sequences sequences.private vectors
combinators ;
IN: hashtables

<PRIVATE

: wrap ( i array -- n )
    array-capacity 1 fixnum-fast fixnum-bitand ; inline

: hash@ ( key array -- i )
    >r hashcode >fixnum dup fixnum+fast r> wrap ; inline

: probe ( array i -- array i )
    2 fixnum+fast over wrap ; inline

: (key@) ( key keys i -- array n ? )
    #! cond form expanded by hand for better interpreter speed
    3dup swap array-nth dup ((tombstone)) eq? [
        2drop probe (key@)
    ] [
        dup ((empty)) eq? [
            3drop nip f f
        ] [
            = [ rot drop t ] [ probe (key@) ] if
        ] if
    ] if ; inline

: key@ ( key hash -- array n ? )
    hash-array 2dup hash@ (key@) ; inline

: <hash-array> ( n -- array )
    1+ next-power-of-2 4 * ((empty)) <array> ; inline

: init-hash ( hash -- )
    0 over set-hash-count 0 swap set-hash-deleted ;

: reset-hash ( n hash -- )
    swap <hash-array> over set-hash-array init-hash ;

: (new-key@) ( key keys i -- keys n empty? )
    #! cond form expanded by hand for better interpreter speed
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
    hash-array 2dup hash@ (new-key@) ; inline

: nth-pair ( n seq -- key value )
    swap 2 fixnum+fast 2dup slot -rot 1 fixnum+fast slot ;
    inline

: set-nth-pair ( value key seq n -- )
    2 fixnum+fast [ set-slot ] 2keep
    1 fixnum+fast set-slot ; inline

: hash-count+ ( hash -- )
    dup hash-count 1+ swap set-hash-count ; inline

: hash-deleted+ ( hash -- )
    dup hash-deleted 1+ swap set-hash-deleted ; inline

: (set-hash) ( value key hash -- new? )
    2dup new-key@
    [ rot hash-count+ set-nth-pair t ]
    [ rot drop set-nth-pair f ] if ; inline

: find-pair-next >r 2 fixnum+fast r> ; inline

: (find-pair) ( quot i array -- key value ? )
    2dup array-capacity eq? [
        3drop f f f
    ] [
        2dup array-nth tombstone? [
            find-pair-next (find-pair)
        ] [
            [ nth-pair rot call ] 3keep roll [
                nth-pair >r nip r> t
            ] [
                find-pair-next (find-pair)
            ] if
        ] if
    ] if ; inline

: find-pair ( array quot -- key value ? ) 0 rot (find-pair) ; inline

: (rehash) ( hash array -- )
    [ swap pick (set-hash) drop f ] find-pair 2drop 2drop ;

: hash-large? ( hash -- ? )
    dup hash-count 3 fixnum*fast
    swap hash-array array-capacity > ;

: hash-stale? ( hash -- ? )
    dup hash-deleted 10 fixnum*fast swap hash-count fixnum> ;

: grow-hash ( hash -- )
    [ dup hash-array swap assoc-size 1+ ] keep
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
    (hashtable) [ reset-hash ] keep ;

M: hashtable at* ( key hash -- value ? )
    key@ [ 3 fixnum+fast slot t ] [ 2drop f f ] if ;

M: hashtable clear-assoc ( hash -- )
    dup init-hash hash-array [ drop ((empty)) ] change-each ;

M: hashtable delete-at ( key hash -- )
    tuck key@ [
        >r >r ((tombstone)) dup r> r> set-nth-pair
        hash-deleted+
    ] [
        3drop
    ] if ;

M: hashtable assoc-size ( hash -- n )
    dup hash-count swap hash-deleted - ;

: rehash ( hash -- )
    dup hash-array
    dup length ((empty)) <array> pick set-hash-array
    0 pick set-hash-count
    0 pick set-hash-deleted
    (rehash) ;

M: hashtable set-at ( value key hash -- )
    dup >r (set-hash) [ r> ?grow-hash ] [ r> drop ] if ;

: associate ( value key -- hash )
    2 <hashtable> [ set-at ] keep ;

M: hashtable assoc-find ( hash quot -- key value ? )
    >r hash-array r> find-pair ;

M: hashtable clone
    (clone) dup hash-array clone over set-hash-array ;

M: hashtable equal?
    {
        { [ over hashtable? not ] [ 2drop f ] }
        { [ 2dup [ assoc-size ] 2apply number= not ] [ 2drop f ] }
        { [ t ] [ assoc= ] }
    } cond ;

M: hashtable hashcode*
    dup assoc-size 1 number=
    [ assoc-hashcode ] [ nip assoc-size ] if ;

! Default method
M: assoc new-assoc drop <hashtable> ;

M: f new-assoc drop <hashtable> ;

: >hashtable ( assoc -- hashtable )
    H{ } assoc-clone-like ;

M: hashtable assoc-like
    drop dup hashtable? [ >hashtable ] unless ;

: ?set-at ( value key assoc/f -- assoc )
    [ [ set-at ] keep ] [ associate ] if* ;

: (prune) ( hash vec elt -- )
    rot 2dup key?
    [ 3drop ] [ dupd dupd set-at swap push ] if ; inline

: prune ( seq -- newseq )
    dup length <hashtable> over length <vector>
    rot [ >r 2dup r> (prune) ] each nip ;

INSTANCE: hashtable assoc

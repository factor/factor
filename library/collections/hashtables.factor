! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: hashtables-internals
USING: arrays hashtables kernel kernel-internals math sequences
sequences-internals ;

TUPLE: tombstone ;

: ((empty)) T{ tombstone f } ; inline
: ((tombstone)) T{ tombstone t } ; inline

: hash@ ( key keys -- n ) >r hashcode r> length 2 /i rem 2 * ;

: probe ( heys i -- hash i ) 2 + over length mod ;

: (key@) ( key keys i -- n )
    3dup swap nth-unsafe {
        { [ dup ((tombstone)) eq? ] [ 2drop probe (key@) ] }
        { [ dup ((empty)) eq? ] [ 2drop 3drop -1 ] }
        { [ = ] [ 2nip ] }
        { [ t ] [ probe (key@) ] }
    } cond ;

: key@ ( key hash -- n ) hash-array 2dup hash@ (key@) ;

: if-key ( key hash true false -- | true: index key hash -- )
    >r >r [ key@ ] 2keep pick -1 > r> r> if ; inline

: <hash-array> ( n -- array ) 1+ 4 * ((empty)) <array> ;

: reset-hash ( n hash -- )
    swap <hash-array> over set-hash-array
    0 over set-hash-count 0 swap set-hash-deleted ;

: (new-key@) ( key keys i -- n )
    3dup swap nth-unsafe dup tombstone? [
        2drop 2nip
    ] [
        = [ 2nip ] [ probe (new-key@) ] if
    ] if ;

: new-key@ ( key hash -- n )
    hash-array 2dup hash@ (new-key@) ;

: nth-pair ( n seq -- key value )
    [ nth-unsafe ] 2keep >r 1+ r> nth-unsafe ;

: set-nth-pair ( value key n seq -- )
    [ set-nth-unsafe ] 2keep >r 1+ r> set-nth-unsafe ;

: hash-count+ dup hash-count 1+ swap set-hash-count ;

: hash-deleted+ dup hash-deleted 1+ swap set-hash-deleted ;

: hash-deleted- dup hash-deleted 1- swap set-hash-deleted ;

: change-size ( hash old -- )
    dup ((tombstone)) eq? [
        drop hash-deleted-
    ] [
        ((empty)) eq? [ hash-count+ ] [ drop ] if
    ] if ;

: (set-hash) ( value key hash -- )
    2dup new-key@ swap
    [ hash-array 2dup nth-unsafe ] keep
    ( value key n hash-array old hash )
    swap change-size set-nth-pair ;

: (each-pair) ( quot array i -- | quot: k v -- )
    over length over number= [
        3drop
    ] [
        [
            swap nth-pair over tombstone?
            [ 3drop ] [ rot call ] if
        ] 3keep 2 + (each-pair)
    ] if ; inline

: each-pair ( array quot -- | quot: k v -- )
    swap 0 (each-pair) ; inline

: (all-pairs?) ( quot array i -- ? | quot: k v -- ? )
    over length over number= [
        3drop t
    ] [
        3dup >r >r >r swap nth-pair over tombstone? [
            3drop r> r> r> 2 + (all-pairs?)
        ] [
            rot call
            [ r> r> r> 2 + (all-pairs?) ] [ r> r> r> 3drop f ] if
        ] if
    ] if ; inline

: all-pairs? ( array quot -- ? | quot: k v -- ? )
    swap 0 (all-pairs?) ; inline

: hash>seq ( i hash -- seq )
    hash-array dup length 2 /i
    [ 2 * pick + over nth-unsafe ] map
    [ tombstone? not ] subset 2nip ;

IN: hashtables

: <hashtable> ( capacity -- hashtable )
    (hashtable) [ reset-hash ] keep ;

: hash* ( key hash -- value ? )
    [
        nip >r 1+ r> hash-array nth-unsafe t
    ] [
        3drop f f
    ] if-key ;

: hash-member? ( key hash -- ? )
    [ 3drop t ] [ 3drop f ] if-key ;

: ?hash* ( key hash -- value/f ? )
    dup [ hash* ] [ 2drop f f ] if ;

: hash ( key hash -- value ) hash* drop ; inline

: ?hash ( key hash -- value )
    dup [ hash ] [ 2drop f ] if ;

: clear-hash ( hash -- )
    [ hash-array length ] keep reset-hash ;

: remove-hash ( key hash -- )
    [
        nip
        dup hash-deleted+
        hash-array >r >r ((tombstone)) dup r> r> set-nth-pair
    ] [
        3drop
    ] if-key ;

: hash-size ( hash -- n ) dup hash-count swap hash-deleted - ;

: hash-empty? ( hash -- ? ) hash-size zero? ;

: grow-hash ( hash -- )
    [ dup hash-array swap hash-size 1+ ] keep
    [ reset-hash ] keep swap [ swap pick (set-hash) ] each-pair
    drop ;

: ?grow-hash ( hash -- )
    dup hash-count 3 * over hash-array length >
    [ dup grow-hash ] when drop ;

: set-hash ( value key hash -- )
    [ (set-hash) ] keep ?grow-hash ;

: associate ( value key -- hashtable )
    2 <hashtable> [ set-hash ] keep ;

: hash-keys ( hash -- keys ) 0 swap hash>seq ;

: hash-values ( hash -- keys ) 1 swap hash>seq ;

: hash>alist ( hash -- assoc )
    dup hash-keys swap hash-values 2array flip ;

: alist>hash ( alist -- hash )
    [ length <hashtable> ] keep
    [ first2 swap pick (set-hash) ] each ;

: hash-each ( hash quot -- | quot: k v -- )
    >r hash-array r> each-pair ; inline

: hash-each-with ( obj hash quot -- | quot: obj k v -- )
    swap [ 2swap [ >r -rot r> call ] 2keep ] hash-each 2drop ;
    inline

: hash-all? ( hash quot -- | quot: k v -- ? )
    >r hash-array r> all-pairs? ; inline

: hash-all-with? ( obj hash quot -- | quot: obj k v -- ? )
    swap
    [ 2swap [ >r -rot r> call ] 2keep rot ] hash-all? 2nip ;
    inline

: subhash? ( h1 h2 -- ? )
    swap [
        >r swap hash* [ r> = ] [ r> 2drop f ] if
    ] hash-all-with? ; flushable

: hash-subset ( hash quot -- hash | quot: k v -- ? )
    over hash-size <hashtable> rot [
        2swap [
            >r pick pick >r >r call [
                r> r> swap r> set-hash
            ] [
                r> r> r> 3drop
            ] if
        ] 2keep
    ] hash-each nip ; inline

: hash-subset-with ( obj hash quot -- hash | quot: obj { k v } -- ?  )
    swap
    [ 2swap [ >r -rot r> call ] 2keep rot ] hash-subset 2nip ;
    inline

M: hashtable clone ( hash -- hash )
    (clone) dup hash-array clone over set-hash-array ;

: hashtable= ( hash hash -- ? )
    2dup subhash? >r swap subhash? r> and ;

M: hashtable = ( obj hash -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over hashtable? not ] [ 2drop f ] }
        { [ 2dup [ hash-size ] 2apply number= not ] [ 2drop f ] }
        { [ t ] [ hashtable= ] }
    } cond ;

: hashtable-hashcode ( n hashtable -- n )
    >r 1- r> 0 swap [
        >r >r
        over r> hashcode* bitxor
        over r> hashcode* -1 shift bitxor
    ] hash-each nip ;

M: hashtable hashcode* ( n hash -- n )
    dup hash-size 1 number=
    [ hashtable-hashcode ] [ nip hash-size ] if ;

M: hashtable hashcode ( hash -- n )
    2 swap hashcode* ;

: ?hash ( key hash/f -- value/f )
    dup [ hash ] [ 2drop f ] if ; flushable

: ?hash* ( key hash/f -- value/f )
    dup [ hash* ] [ 2drop f f ] if ; flushable

: ?set-hash ( value key hash/f -- hash )
    [ [ set-hash ] keep ] [ associate ] if ;

: hash-stack ( key seq -- value )
    [ dupd hash-member? ] find-last nip ?hash ; flushable

: hash-intersect ( hash1 hash2 -- hash1/\hash2 )
    [ drop swap hash ] hash-subset-with ;

: hash-diff ( hash1 hash2 -- hash2-hash1 )
    [ drop swap hash not ] hash-subset-with ;

: hash-update ( hash1 hash2 -- )
    [ swap rot set-hash ] hash-each-with ;

: hash-concat ( seq -- hash )
    H{ } clone swap [ dupd hash-update ] each ;

: hash-union ( hash1 hash2 -- hash1\/hash2 )
    >r clone dup r> hash-update ;

: remove-all ( hash seq -- seq )
    [ swap hash-member? not ] subset-with ; flushable

: cache ( key hash quot -- value | quot: key -- value )
    pick pick hash [
        >r 3drop r>
    ] [
        pick rot >r >r call dup r> r> set-hash
    ] if* ; inline

: map>hash ( seq quot -- hash | quot: key -- key value )
    over length <hashtable> rot
    [ -rot [ >r call swap r> set-hash ] 2keep ] each nip ;
    inline

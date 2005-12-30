IN: hashtables-internals
USING: arrays hashtables kernel math sequences
sequences-internals ;

TUPLE: tombstone ;
: ((empty)) T{ tombstone f } ; inline
: ((tombstone)) T{ tombstone t } ; inline

: hash@ >r hashcode r> length 2 /i rem 2 * ;
: probe 2 + over length mod ;
: (key@)
    3dup swap nth-unsafe {
        { [ dup ((tombstone)) eq? ] [ 2drop probe (key@) ] }
        { [ dup ((empty)) eq? ] [ 2drop 3drop -1 ] }
        { [ = ] [ 2nip ] }
        { [ t ] [ probe (key@) ] }
    } cond ;
: key@ underlying 2dup hash@ (key@) ;
: if-key >r >r [ key@ ] 2keep pick -1 > r> r> if ; inline
: (new-key@)
    3dup swap nth-unsafe dup tombstone? [
        2drop 2nip
    ] [
        = [ 2nip ] [ probe (new-key@) ] if
    ] if ;
: new-key@ underlying 2dup hash@ (new-key@) ;

: <hash-array> 1+ 4 * ((empty)) <array> ;
: nth-pair [ nth-unsafe ] 2keep >r 1+ r> nth-unsafe ;
: set-nth-pair [ set-nth-unsafe ] 2keep >r 1+ r> set-nth-unsafe ;
: (each-pair)
    over length over number= [
        3drop
    ] [
        [
            swap nth-pair over tombstone?
            [ 3drop ] [ rot call ] if
        ] 3keep 2 + (each-pair)
    ] if ; inline
: each-pair swap 0 (each-pair) ; inline
: (all-pairs?)
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
: all-pairs? swap 0 (all-pairs?) ; inline

: reset-hash
    swap <hash-array> over set-underlying
    0 over set-hash-count 0 swap set-hash-deleted ;
: hash-count+ dup hash-count 1+ swap set-hash-count ;
: hash-deleted+ dup hash-deleted 1+ swap set-hash-deleted ;
: hash-deleted- dup hash-deleted 1- swap set-hash-deleted ;
: change-size
    dup ((tombstone)) eq? [
        drop hash-deleted-
    ] [
        ((empty)) eq? [ hash-count+ ] [ drop ] if
    ] if ;
: (set-hash)
    2dup new-key@ swap [ underlying 2dup nth-unsafe ] keep
    ( value key n underlying old hash )
    swap change-size set-nth-pair ;
: grow-hash
    [ dup underlying swap hash-size 1+ ] keep
    [ reset-hash ] keep swap [ swap pick (set-hash) ] each-pair
    drop ;
: ?grow-hash
    dup hash-count 3 * over underlying length >
    [ dup grow-hash ] when drop ;

: hash>seq
    underlying dup length 2 /i
    [ 2 * pick + over nth-unsafe ] map
    [ tombstone? not ] subset 2nip ;

IN: hashtables

: <hashtable> (hashtable) [ reset-hash ] keep ;
: associate 2 <hashtable> [ set-hash ] keep ;
: clear-hash [ underlying length ] keep reset-hash ;
: hash-size dup hash-count swap hash-deleted - ;
: hash-empty? hash-size 0 = ;

: hash*
    [ nip >r 1+ r> underlying nth-unsafe t ]
    [ 3drop f f ]
    if-key ;
: hash-member? [ 3drop t ] [ 3drop f ] if-key ;
: ?hash* dup [ hash* ] [ 2drop f f ] if ;
: hash hash* drop ; inline
: ?hash dup [ hash ] [ 2drop f ] if ;

: remove-hash
    [
        nip
        dup hash-deleted+
        underlying >r >r ((tombstone)) dup r> r> set-nth-pair
    ] [
        3drop
    ] if-key ;
: set-hash [ (set-hash) ] keep ?grow-hash ;

: hash-keys 0 swap hash>seq ; : hash-values 1 swap hash>seq ;
: hash>alist dup hash-keys swap hash-values 2array flip ;

: alist>hash
    [ length <hashtable> ] keep
    [ first2 swap pick (set-hash) ] each ;

: hash-each >r underlying r> each-pair ; inline
: hash-each-with
    swap [ 2swap [ >r -rot r> call ] 2keep ] hash-each 2drop ;
    inline
: hash-all? >r underlying r> all-pairs? ; inline
: hash-all-with?
    swap
    [ 2swap [ >r -rot r> call ] 2keep rot ] hash-all? 2nip ;
    inline
: hash-subset
    over hash-size <hashtable> rot [
        2swap [
            >r pick pick >r >r call [
                r> r> swap r> set-hash
            ] [
                r> r> r> 3drop
            ] if
        ] 2keep
    ] hash-each nip ; inline
: hash-subset-with
    swap
    [ 2swap [ >r -rot r> call ] 2keep rot ] hash-subset 2nip ;
    inline

M: hashtable clone clone-growable ;

: subhash? ( h1 h2 -- ? )
    #! Test if h2 contains all the key/value pairs of h1.
    swap [
        >r swap hash* [ r> = ] [ r> 2drop f ] if
    ] hash-all-with? ; flushable

M: hashtable = ( obj hash -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over hashtable? not ] [ 2drop f ] }
        { [ 2dup [ hash-size ] 2apply number= not ] [ 2drop f ] }
        { [ t ] [ 2dup subhash? >r swap subhash? r> and ] }
    } cond ;

: ?hash ( key hash/f -- value/f )
    dup [ hash ] [ 2drop f ] if ; flushable

: ?hash* ( key hash/f -- value/f )
    dup [ hash* ] [ 2drop f f ] if ; flushable

: ?set-hash ( value key hash/f -- hash )
    [ 2 <hashtable> ] unless* [ set-hash ] keep ;

: hash-stack ( key seq -- value )
    #! Searches for a key in a sequence of hashtables,
    #! where the most recently pushed hashtable is searched
    #! first.
    [ dupd hash-member? ] find-last nip ?hash ; flushable

: hash-intersect ( hash1 hash2 -- hash1/\hash2 )
    #! Remove all keys from hash2 not in hash1.
    [ drop swap hash ] hash-subset-with ;

: hash-diff ( hash1 hash2 -- hash2-hash1 )
    #! Remove all keys from hash2 in hash1.
    [ drop swap hash not ] hash-subset-with ;

: hash-update ( hash1 hash2 -- )
    #! Add all key/value pairs from hash2 to hash1.
    [ swap rot set-hash ] hash-each-with ;

: hash-concat ( seq -- hash )
    #! Combine a sequence of hashtables into one hashtable.
    H{ } clone swap [ dupd hash-update ] each ;

: hash-union ( hash1 hash2 -- hash1\/hash2 )
    #! Make a new hashtable with all key/value pairs from
    #! hash1 and hash2. Values in hash2 take precedence.
    >r clone dup r> hash-update ;

: remove-all ( hash seq -- seq )
    #! Remove all elements from the sequence that are keys
    #! in the hashtable.
    [ swap hash-member? not ] subset-with ; flushable

: cache ( key hash quot -- value | quot: key -- value )
    pick pick hash [
        >r 3drop r>
    ] [
        pick rot >r >r call dup r> r> set-hash
    ] if* ; inline

: map>hash ( seq quot -- hash | quot: key -- value )
    #! Construct a hashtable with keys from the sequence, and
    #! values obtained by applying the quotation to each key.
    swap [ length <hashtable> ] keep
    [ -rot [ >r over >r call r> r> set-hash ] 2keep ] each nip ;
    inline

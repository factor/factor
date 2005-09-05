! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: hashtables
USING: generic kernel lists math sequences vectors
kernel-internals ;

! A hashtable is implemented as an array of buckets. The
! array index is determined using a hash function, and the
! buckets are associative lists which are searched
! linearly.

! The unsafe words go in kernel internals. Everything else, even
! if it is somewhat 'implementation detail', is in the
! public 'hashtables' vocabulary.

: bucket-count ( hash -- n ) hash-array array-capacity ;

IN: kernel-internals

: hash-bucket ( n hash -- alist )
    >r >fixnum r> hash-array array-nth ;

: set-hash-bucket ( obj n hash -- )
    >r >fixnum r> hash-array set-array-nth ;

: change-bucket ( n hash quot -- )
    -rot hash-array
    [ array-nth swap call ] 2keep
    set-array-nth ; inline

: each-bucket ( hash quot -- | quot: n hash -- )
    over bucket-count [ [ -rot call ] 3keep ] repeat 2drop ;
    inline

: hash-size+ ( hash -- ) dup hash-size 1 + swap set-hash-size ;
: hash-size- ( hash -- ) dup hash-size 1 - swap set-hash-size ;

: grow-hash ( hash -- )
    #! A good way to earn a living.
    dup hash-size 2 * <array> swap set-hash-array ;

: (set-bucket-count) ( n hash -- )
    >r <array> r> set-hash-array ;
    
IN: hashtables

: (hashcode) ( key table -- index )
    #! Compute the index of the bucket for a key.
    >r hashcode r> bucket-count rem ; inline

: hash* ( key table -- [[ key value ]] )
    #! Look up a value in the hashtable.
    2dup (hashcode) swap hash-bucket assoc* ; flushable

: hash ( key table -- value ) hash* cdr ; flushable

: set-hash* ( key hash quot -- )
    #! Apply the quotation to yield a new association list.
    #! If the association list already contains the key,
    #! decrement the hash size, since it will get removed.
    -rot 2dup (hashcode) over [
        ( quot key hash assoc -- )
        swapd 2dup
        assoc* [ rot hash-size- ] [ rot drop ] ifte
        rot call
    ] change-bucket ; inline

: grow-hash? ( hash -- ? )
    dup bucket-count 3 * 2 /i swap hash-size < ;

: hash>alist ( hash -- alist )
    #! Push a list of key/value pairs in a hashtable.
    [ ] swap [ hash-bucket [ swons ] each ] each-bucket ;
    flushable

: (set-hash) ( value key hash -- )
    dup hash-size+ [ set-assoc ] set-hash* ;

: set-bucket-count ( new hash -- )
    dup hash>alist >r [ (set-bucket-count) ] keep r>
    0 pick set-hash-size
    [ unswons rot (set-hash) ] each-with ;

: grow-hash ( hash -- )
    #! Increase the hashtable size if its too small.
    dup grow-hash? [
        dup hash-size 2 * swap set-bucket-count
    ] [
        drop
    ] ifte ;

: set-hash ( value key table -- )
    #! Store the value in the hashtable. Either replaces an
    #! existing value in the appropriate bucket, or adds a new
    #! key/value pair.
    dup grow-hash (set-hash) ;

: remove-hash ( key table -- )
    #! Remove a value from a hashtable.
    [ remove-assoc ] set-hash* ;

: hash-clear ( hash -- )
    0 over set-hash-size [ f -rot set-hash-bucket ] each-bucket ;

: buckets>vector ( hash -- vector )
    hash-array >vector ;

: alist>hash ( alist -- hash )
    dup length 1 max <hashtable> swap
    [ unswons pick set-hash ] each ; foldable

: hash-keys ( hash -- list )
    hash>alist [ car ] map ; flushable

: hash-values ( hash -- alist )
    hash>alist [ cdr ] map ; flushable

: hash-each ( hash quot -- | quot: [[ k v ]] -- )
    swap hash-array [ swap each ] each-with ; inline

: hash-each-with ( obj hash quot -- | quot: obj [[ k v ]] -- )
    swap [ with ] hash-each 2drop ; inline

: hash-all? ( hash quot -- | quot: [[ k v ]] -- ? )
    swap hash-array [ swap all? ] all-with? ; inline

: hash-all-with? ( obj hash quot -- ? | quot: [[ k v ]] -- ? )
    swap [ with rot ] hash-all? 2nip ; inline

: hash-contained? ( h1 h2 -- ? )
    #! Test if h2 contains all the key/value pairs of h1.
    swap [
        uncons >r swap hash* dup [
            cdr r> =
        ] [
            r> 2drop f
        ] ifte
    ] hash-all-with? ; flushable

: hash-subset ( hash quot -- hash | quot: [[ k v ]] -- ? )
    >r hash>alist r> subset alist>hash ; inline

M: hashtable clone ( hash -- hash )
    dup bucket-count <hashtable>
    over hash-size over set-hash-size
    [ hash-array swap hash-array copy-array ] keep ;

M: hashtable = ( obj hash -- ? )
    2dup eq? [
        2drop t
    ] [
        over hashtable? [
            2dup hash-contained? >r swap hash-contained? r> and
        ] [
            2drop f
        ] ifte
    ] ifte ;

M: hashtable hashcode ( hash -- n )
    dup bucket-count 0 number= [
        drop 0
    ] [
        0 swap hash-bucket hashcode
    ] ifte ;

: cache ( key hash quot -- value | quot: key -- value )
    pick pick hash [
        >r 3drop r>
    ] [
        pick rot >r >r call dup r> r> set-hash
    ] ifte* ; inline

: map>hash ( seq quot -- hash | quot: elt -- value )
    over >r map r> dup length <hashtable> -rot
    [ pick set-hash ] 2each ; inline

: ?hash ( key hash/f -- value/f )
    dup [ hash ] [ 2drop f ] ifte ; flushable

: ?set-hash ( value key hash/f -- hash )
    [ 1 <hashtable> ] unless* [ set-hash ] keep ;

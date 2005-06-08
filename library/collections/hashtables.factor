! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals

DEFER: hash-array
DEFER: set-hash-array
DEFER: set-hash-size

IN: hashtables
USING: generic kernel lists math sequences vectors ;

! We put hash-size in the hashtables vocabulary, and
! the other words in kernel-internals.
DEFER: hashtable?
BUILTIN: hashtable 10 hashtable?
    [ 1 "hash-size" set-hash-size ]
    [ 2 hash-array set-hash-array ] ;

! A hashtable is implemented as an array of buckets. The
! array index is determined using a hash function, and the
! buckets are associative lists which are searched
! linearly.

! The unsafe words go in kernel internals. Everything else, even
! if it is somewhat 'implementation detail', is in the
! public 'hashtables' vocabulary.

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

: bucket-count ( hash -- n ) hash-array length ;

: (hashcode) ( key table -- index )
    #! Compute the index of the bucket for a key.
    >r hashcode r> bucket-count rem ; inline

: hash* ( key table -- [[ key value ]] )
    #! Look up a value in the hashtable.
    2dup (hashcode) swap hash-bucket assoc* ;

: hash ( key table -- value ) hash* cdr ;

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
    #! Remove all entries from a hashtable.
    0 over set-hash-size [ f -rot set-hash-bucket ] each-bucket ;

: buckets>list ( hash -- list )
    #! Push a list of key/value pairs in a hashtable.
    hash-array >list ;

: alist>hash ( alist -- hash )
    dup length 1 max <hashtable> swap
    [ unswons pick set-hash ] each ;

: hash-keys ( hash -- list )
    #! Push a list of keys in a hashtable.
    hash>alist [ car ] map ;

: hash-values ( hash -- alist )
    #! Push a list of values in a hashtable.
    hash>alist [ cdr ] map ;

: hash-each ( hash code -- )
    #! Apply the code to each key/value pair of the hashtable.
    >r hash>alist r> each ; inline

: hash-subset ( hash quot -- hash | quot: [[ k v ]] -- ? )
    >r hash>alist r> subset alist>hash ;

M: hashtable clone ( hash -- hash )
    dup bucket-count <hashtable>
    over hash-size over set-hash-size
    [ hash-array swap hash-array copy-array ] keep ;

M: hashtable = ( obj hash -- ? )
    2dup eq? [
        2drop t
    ] [
        over hashtable? [
            swap hash>alist swap hash>alist 2dup
            contained? >r swap contained? r> and
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

! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.tuple.private kernel math
parser sequences sequences.private vectors words ;
IN: memory.pools

TUPLE: pool
    prototype
    { objects vector } ;

: <pool> ( size class -- pool )
    [ nip new ]
    [ '[ _ new ] V{ } replicate-as ] 2bi
    pool boa ;

: pool-size ( pool -- size )
    objects>> length ;

<PRIVATE

:: copy-tuple ( from to -- to )
    from tuple-size :> size
    size [| n | n from array-nth n to set-array-nth ] each-integer
    to ; inline

: (pool-new) ( pool -- object )
    objects>> [ f ] [ pop ] if-empty ;

: (pool-init) ( pool object -- object )
    [ prototype>> ] dip copy-tuple ; inline

PRIVATE>

: pool-new ( pool -- object )
    dup (pool-new) [ (pool-init) ] [ drop f ] if* ; inline

: pool-free ( object pool -- )
    objects>> push ;

: class-pool ( class -- pool )
    "pool" word-prop ;

: set-class-pool ( class pool -- )
    "pool" set-word-prop ;

: new-from-pool ( class -- object )
    class-pool pool-new ;

: free-to-pool ( object -- )
    dup class-of class-pool pool-free ;

SYNTAX: POOL:
    scan-word scan-word '[ _ swap <pool> ] [ swap set-class-pool ] bi ;

! (c)2009 Joe Groff bsd license
USING: accessors arrays bit-arrays classes
classes.tuple.private fry kernel locals parser
sequences sequences.private vectors words ;
IN: memory.pools

TUPLE: pool
    prototype
    { objects vector } ;

: <pool> ( size class -- pool )
    [ nip new ]
    [ [ iota ] dip '[ _ new ] V{ } replicate-as ] 2bi
    pool boa ;

: pool-size ( pool -- size )
    objects>> length ;

<PRIVATE

:: copy-tuple ( from to -- to )
    from tuple-size :> size
    size [| n | n from array-nth n to set-array-nth ] each
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
    dup class class-pool pool-free ;

SYNTAX: POOL:
    scan-word scan-word '[ _ swap <pool> ] [ swap set-class-pool ] bi ;


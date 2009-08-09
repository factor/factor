! (c)2009 Joe Groff bsd license
USING: accessors arrays bit-arrays classes
classes.tuple.private fry kernel locals parser
sequences sequences.private words ;
IN: pools

TUPLE: pool
    prototype
    { objects array }
    { free bit-array } ;

: <pool> ( size class -- pool )
    [ nip new ]
    [ [ iota ] dip '[ _ new ] replicate ]
    [ drop <bit-array> ] 2tri
    pool boa ;

: pool-size ( pool -- size )
    objects>> length ;

: pool-free-size ( pool -- free-size )
    free>> [ f = ] filter length ;

<PRIVATE

:: copy-tuple ( from to -- to )
    from tuple-size :> size
    size [| n | n from array-nth n to set-array-nth ] each
    to ; inline

: (pool-new) ( pool -- object )
    [ free>> [ f = ] find drop ] [
        over [
            [ objects>> nth ] [ [ t ] 2dip free>> set-nth ] 2bi
        ] [ drop ] if
    ] bi ;

: (pool-init) ( pool object -- object )
    [ prototype>> ] dip copy-tuple ; inline

PRIVATE>

: pool-new ( pool -- object )
    dup (pool-new) [ (pool-init) ] [ drop f ] if* ; inline

: pool-free ( object pool -- )
    [ objects>> [ eq? ] with find drop ]
    [ [ f ] 2dip free>> set-nth ] bi ;

: pool-empty ( pool -- )
    free>> [ length iota ] keep [ [ f ] 2dip set-nth ] curry each ;

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

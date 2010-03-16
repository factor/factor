! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces make math sequences sets
assocs fry compiler.cfg compiler.cfg.instructions ;
FROM: namespaces => set ;
IN: compiler.cfg.rpo

SYMBOL: visited

: post-order-traversal ( bb -- )
    dup visited get key? [ drop ] [
        dup visited get conjoin
        [
            successors>> <reversed>
            [ post-order-traversal ] each
        ] [ , ] bi
    ] if ;

: number-blocks ( blocks -- )
    dup length iota <reversed>
    [ >>number drop ] 2each ;

: post-order ( cfg -- blocks )
    dup post-order>> [ ] [
        [
            H{ } clone visited set
            dup entry>> post-order-traversal
        ] { } make dup number-blocks
        >>post-order post-order>>
    ] ?if ;

: reverse-post-order ( cfg -- blocks )
    post-order <reversed> ; inline

: each-basic-block ( cfg quot -- )
    [ reverse-post-order ] dip each ; inline

: optimize-basic-block ( bb quot -- )
    [ drop basic-block set ]
    [ change-instructions drop ] 2bi ; inline

: local-optimization ( ... cfg quot: ( ... insns -- ... insns' ) -- ... cfg' )
    dupd '[ _ optimize-basic-block ] each-basic-block ; inline

: needs-post-order ( cfg -- cfg' )
    dup post-order drop ;

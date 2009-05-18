! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces make math sequences sets
assocs fry compiler.cfg compiler.cfg.instructions ;
IN: compiler.cfg.rpo

SYMBOL: visited

: post-order-traversal ( bb -- )
    dup id>> visited get key? [ drop ] [
        dup id>> visited get conjoin
        [
            successors>> <reversed>
            [ post-order-traversal ] each
        ] [ , ] bi
    ] if ;

: post-order ( bb -- blocks )
    [ post-order-traversal ] { } make ;

: number-blocks ( blocks -- )
    [ >>number drop ] each-index ;

: reverse-post-order ( bb -- blocks )
    H{ } clone visited [
        post-order <reversed> dup number-blocks
    ] with-variable ; inline

: each-basic-block ( cfg quot -- )
    [ entry>> reverse-post-order ] dip each ; inline

: change-basic-blocks ( cfg quot -- cfg' )
    [ '[ _ change-instructions drop ] each-basic-block ]
    [ drop ]
    2bi ; inline

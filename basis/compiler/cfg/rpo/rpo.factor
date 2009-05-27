! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces make math sequences sets
assocs fry compiler.cfg compiler.cfg.instructions
compiler.cfg.liveness ;
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

: post-order ( cfg -- blocks )
    [ entry>> post-order-traversal ] { } make ;

: number-blocks ( blocks -- )
    [ >>number drop ] each-index ;

: reverse-post-order ( cfg -- blocks )
    H{ } clone visited [
        post-order <reversed> dup number-blocks
    ] with-variable ; inline

: each-basic-block ( cfg quot -- )
    [ reverse-post-order ] dip each ; inline

: optimize-basic-block ( bb init-quot insn-quot -- )
    [ '[ live-in keys _ each ] ] [ '[ _ change-instructions drop ] ] bi* bi ; inline

: local-optimization ( rpo init-quot: ( live-in -- ) insn-quot: ( insns -- insns' ) -- )
    '[ _ _ optimize-basic-block ] each ;
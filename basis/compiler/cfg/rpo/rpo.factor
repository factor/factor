! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg kernel make namespaces sequences
sets ;
IN: compiler.cfg.rpo

: post-order-traversal ( visited bb -- visited )
    dup pick ?adjoin [
        [
            successors>> <reversed>
            [ post-order-traversal ] each
        ] [ , ] bi
    ] [ drop ] if ; inline recursive

: number-blocks ( blocks -- )
    dup length <iota> <reversed>
    [ >>number drop ] 2each ;

: post-order ( cfg -- blocks )
    [ post-order>> ] [
        [
            HS{ } clone over entry>>
            post-order-traversal drop
        ] { } make dup number-blocks
        >>post-order post-order>>
    ] ?unless ;

: reverse-post-order ( cfg -- blocks )
    post-order <reversed> ; inline

: each-basic-block ( cfg quot -- )
    [ reverse-post-order ] dip each ; inline

: optimize-basic-block ( bb quot -- )
    over kill-block?>> [ 2drop ] [
        over basic-block namespaces:set
        change-instructions drop
    ] if ; inline

: simple-optimization ( ... cfg quot: ( ... insns -- ... insns' ) -- ... )
    '[ _ optimize-basic-block ] each-basic-block ; inline

: analyze-basic-block ( bb quot -- )
    over kill-block?>> [ 2drop ] [
        [ dup basic-block namespaces:set instructions>> ] dip call
    ] if ; inline

: simple-analysis ( ... cfg quot: ( ... insns -- ... ) -- ... )
    '[ _ analyze-basic-block ] each-basic-block ; inline

: needs-post-order ( cfg -- )
    post-order drop ;

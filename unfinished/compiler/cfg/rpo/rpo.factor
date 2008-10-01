! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces make math sequences
compiler.cfg.instructions ;
IN: compiler.cfg.rpo

: post-order-traversal ( basic-block -- )
    dup visited>> [ drop ] [
        t >>visited
        [ successors>> [ post-order-traversal ] each ] [ , ] bi
    ] if ;

: post-order ( procedure -- blocks )
    [ post-order-traversal ] { } make ;

: number-blocks ( blocks -- )
    [ >>number drop ] each-index ;

: reverse-post-order ( procedure -- blocks )
    post-order <reversed> dup number-blocks ; inline

! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel accessors sequences sequences.deep
compiler.tree ;
IN: compiler.tree.combinators

: each-node ( nodes quot -- )
    dup dup '[
        , [
            dup #branch? [
                children>> [ , each-node ] each
            ] [
                dup #recursive? [
                    child>> , each-node
                ] [ drop ] if
            ] if
        ] bi
    ] each ; inline

: map-nodes ( nodes quot: ( node -- node' ) -- nodes )
    dup dup '[
        @
        dup #branch? [
            [ [ , map-nodes ] map ] change-children
        ] [
            dup #recursive? [
                [ , map-nodes ] change-child
            ] when
        ] if
    ] map flatten ; inline recursive

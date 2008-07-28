! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel accessors sequences compiler.tree ;
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

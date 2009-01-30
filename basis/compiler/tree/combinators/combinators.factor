! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs fry kernel accessors sequences compiler.utilities
arrays stack-checker.inlining namespaces compiler.tree
math.order ;
IN: compiler.tree.combinators

: each-node ( nodes quot: ( node -- ) -- )
    dup dup '[
        _ [
            dup #branch? [
                children>> [ _ each-node ] each
            ] [
                dup #recursive? [
                    child>> _ each-node
                ] [ drop ] if
            ] if
        ] bi
    ] each ; inline recursive

: map-nodes ( nodes quot: ( node -- node' ) -- nodes )
    dup dup '[
        @
        dup #branch? [
            [ [ _ map-nodes ] map ] change-children
        ] [
            dup #recursive? [
                [ _ map-nodes ] change-child
            ] when
        ] if
    ] map-flat ; inline recursive

: contains-node? ( nodes quot: ( node -- ? ) -- ? )
    dup dup '[
        _ keep swap [ drop t ] [
            dup #branch? [
                children>> [ _ contains-node? ] any?
            ] [
                dup #recursive? [
                    child>> _ contains-node?
                ] [ drop f ] if
            ] if
        ] if
    ] any? ; inline recursive

: select-children ( seq flags -- seq' )
    [ [ drop f ] unless ] 2map ;

: sift-children ( seq flags -- seq' )
    zip [ nip ] assoc-filter keys ;

: until-fixed-point ( #recursive quot: ( node -- ) -- )
    over label>> t >>fixed-point drop
    [ with-scope ] 2keep
    over label>> fixed-point>> [ 2drop ] [ until-fixed-point ] if ;
    inline recursive

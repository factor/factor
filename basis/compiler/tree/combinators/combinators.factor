! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators combinators.short-circuit fry kernel
locals accessors sequences compiler.utilities arrays
stack-checker.inlining namespaces compiler.tree math.order ;
IN: compiler.tree.combinators

:: each-node ( ... nodes quot: ( ... node -- ... ) -- ... )
    nodes [
        quot
        [
            {
                { [ dup #branch? ] [ children>> [ quot each-node ] each ] }
                { [ dup #recursive? ] [ child>> quot each-node ] }
                { [ dup #alien-callback? ] [ child>> quot each-node ] }
                [ drop ]
            } cond
        ] bi
    ] each ; inline recursive

:: map-nodes ( ... nodes quot: ( ... node -- ... node' ) -- ... nodes )
    nodes [
        quot call
        {
            { [ dup #branch? ] [ [ [ quot map-nodes ] map ] change-children ] }
            { [ dup #recursive? ] [ [ quot map-nodes ] change-child ] }
            { [ dup #alien-callback? ] [ [ quot map-nodes ] change-child ] }
            [ ]
        } cond
    ] map-flat ; inline recursive

:: contains-node? ( ... nodes quot: ( ... node -- ... ? ) -- ... ? )
    nodes [
        {
            quot
            [
                {
                    { [ dup #branch? ] [ children>> [ quot contains-node? ] any? ] }
                    { [ dup #recursive? ] [ child>> quot contains-node? ] }
                    { [ dup #alien-callback? ] [ child>> quot contains-node? ] }
                    [ drop f ]
                } cond
            ]
        } 1||
    ] any? ; inline recursive

: select-children ( seq flags -- seq' )
    [ [ drop f ] unless ] 2map ;

: sift-children ( seq flags -- seq' )
    zip [ nip ] assoc-filter keys ;

: until-fixed-point ( ... #recursive quot: ( ... node -- ... ) -- ... )
    over label>> t >>fixed-point drop
    [ with-scope ] 2keep
    over label>> fixed-point>> [ 2drop ] [ until-fixed-point ] if ;
    inline recursive

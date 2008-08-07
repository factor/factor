! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors arrays fry math.intervals
combinators namespaces
stack-checker.inlining
compiler.tree
compiler.tree.copy-equiv
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.branches
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.recursive

: check-fixed-point ( node infos1 infos2 -- )
    [ value-info<= ] 2all?
    [ drop ] [ label>> f >>fixed-point drop ] if ;

: recursive-stacks ( #enter-recursive -- stacks initial )
    [ label>> calls>> [ node-input-infos ] map flip ]
    [ in-d>> [ value-info ] map ] bi ;

: generalize-counter-interval ( interval initial-interval -- interval' )
    {
        { [ 2dup interval-subset? ] [ empty-interval ] }
        { [ over empty-interval eq? ] [ empty-interval ] }
        { [ 2dup interval>= t eq? ] [ 1./0. [a,a] ] }
        { [ 2dup interval<= t eq? ] [ -1./0. [a,a] ] }
        [ [-inf,inf] ]
    } cond interval-union nip ;

: generalize-counter ( info' initial -- info )
    2dup [ class>> null-class? ] either? [ drop ] [
        [ drop clone ] [ [ interval>> ] bi@ ] 2bi
        generalize-counter-interval >>interval
    ] if ;

: unify-recursive-stacks ( stacks initial -- infos )
    over empty? [ nip ] [
        [
            [ sift value-infos-union ] dip
            [ generalize-counter ] keep
            value-info-union
        ] 2map
    ] if ;

: propagate-recursive-phi ( #enter-recursive -- )
    [ ] [ recursive-stacks unify-recursive-stacks ] [ ] tri
    [ node-output-infos check-fixed-point ]
    [ out-d>> set-value-infos drop ]
    3bi ;

M: #recursive propagate-around ( #recursive -- )
    { 0 } clone [ USE: math
        dup first 10 = [ "OOPS" throw ] [ dup first 1+ swap set-first ] if
        constraints [ clone ] change

        child>>
        [ first compute-copy-equiv ]
        [ first propagate-recursive-phi ]
        [ (propagate) ]
        tri
    ] curry until-fixed-point ;

: generalize-return-interval ( info -- info' )
    dup [ literal?>> ] [ class>> null-class? ] bi or
    [ clone [-inf,inf] >>interval ] unless ;

: generalize-return ( infos -- infos' )
    [ generalize-return-interval ] map ;

: return-infos ( node -- infos )
    label>> return>> node-input-infos generalize-return ;

M: #call-recursive propagate-before ( #call-label -- )
    [ ] [ return-infos ] [ node-output-infos ] tri
    [ check-fixed-point ] [ drop swap out-d>> set-value-infos ] 3bi ;

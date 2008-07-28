! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors arrays fry math.intervals
combinators
stack-checker.inlining
compiler.tree
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.branches
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.recursive

: check-fixed-point ( node infos1 infos2 -- node )
    sequence= [ dup label>> f >>fixed-point drop ] unless ; inline

: recursive-stacks ( #enter-recursive -- stacks initial )
    [ label>> calls>> [ node-input-infos ] map flip ]
    [ in-d>> [ value-info ] map ] bi ;

: generalize-counter-interval ( interval initial-interval -- interval' )
    {
        { [ 2dup = ] [ empty-interval ] }
        { [ over empty-interval eq? ] [ empty-interval ] }
        { [ 2dup interval>= t eq? ] [ 1./0. [a,a] ] }
        { [ 2dup interval<= t eq? ] [ -1./0. [a,a] ] }
        [ [-inf,inf] ]
    } cond nip interval-union ;

: generalize-counter ( info' initial -- info )
    [ drop clone ] [ [ interval>> ] bi@ ] 2bi
    generalize-counter-interval >>interval ;

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
    [ node-output-infos check-fixed-point drop ] 2keep
    out-d>> set-value-infos ;

USING: namespaces math ;
SYMBOL: iter-counter
0 iter-counter set-global
M: #recursive propagate-around ( #recursive -- )
    iter-counter inc
    iter-counter get 10 > [ "Oops" throw ] when
    dup label>> t >>fixed-point drop [
        [
            child>>
            [ first propagate-recursive-phi ]
            [ (propagate) ]
            bi
        ] save-constraints
    ] [ dup label>> fixed-point>> [ drop ] [ propagate-around ] if ] bi ;

: generalize-return-interval ( info -- info' )
    dup literal?>> [
        clone [-inf,inf] >>interval
    ] unless ;

: generalize-return ( infos -- infos' )
    [ generalize-return-interval ] map ;

M: #call-recursive propagate-before ( #call-label -- )
    dup [ node-output-infos ] [ label>> return>> node-input-infos ] bi
    [ check-fixed-point ] keep
    generalize-return swap out-d>> set-value-infos ;

M: #return-recursive propagate-before ( #return-recursive -- )
    dup [ node-input-infos ] [ in-d>> [ value-info ] map ] bi
    check-fixed-point drop ;

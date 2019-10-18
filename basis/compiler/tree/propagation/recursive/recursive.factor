! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes.algebra sequences accessors arrays fry
math math.intervals layouts combinators namespaces locals
stack-checker.inlining
compiler.tree
compiler.tree.combinators
compiler.tree.propagation.copy
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.branches
compiler.tree.propagation.constraints ;
FROM: sequences.private => array-capacity ;
IN: compiler.tree.propagation.recursive

: check-fixed-point ( node infos1 infos2 -- )
    [ value-info<= ] 2all?
    [ drop ] [ label>> f >>fixed-point drop ] if ;

: latest-input-infos ( node -- infos )
    in-d>> [ value-info ] map ;

: recursive-stacks ( #enter-recursive -- stacks initial )
    [ label>> calls>> [ node>> node-input-infos ] map flip ]
    [ latest-input-infos ] bi ;

: counter-class ( interval class -- class' )
    dup fixnum class<= [
        swap array-capacity-interval interval-subset?
        [ drop array-capacity ] when
    ] [ nip ] if ;

:: generalize-counter-interval ( interval initial-interval class -- interval' )
    interval class counter-class :> class
    {
        { [ interval initial-interval interval-subset? ] [ initial-interval ] }
        { [ interval empty-interval eq? ] [ initial-interval ] }
        {
            [ interval initial-interval interval>= t eq? ]
            [ class max-value [a,a] initial-interval interval-union ]
        }
        {
            [ interval initial-interval interval<= t eq? ]
            [ class min-value [a,a] initial-interval interval-union ]
        }
        [ class class-interval ]
    } cond ;

: generalize-counter ( info' initial -- info )
    2dup [ not ] either? [ drop ] [
        2dup [ class>> null-class? ] either? [ drop ] [
            [ clone ] dip
            [ [ drop ] [ [ [ interval>> ] bi@ ] [ drop class>> ] 2bi generalize-counter-interval ] 2bi >>interval ]
            [ [ drop ] [ [ slots>> ] bi@ [ generalize-counter ] 2map ] 2bi >>slots ]
            bi
        ] if
    ] if ;

: unify-recursive-stacks ( stacks initial -- infos )
    over empty? [ nip ] [
        [
            [ value-infos-union ] dip
            [ generalize-counter ] keep
            value-info-union
        ] 2map
    ] if ;

: propagate-recursive-phi ( #enter-recursive -- )
    [ recursive-stacks unify-recursive-stacks ] keep
    out-d>> set-value-infos ;

M: #recursive propagate-around ( #recursive -- )
    constraints [ H{ } clone suffix ] change
    [
        loop-nesting inc

        constraints [ but-last H{ } clone suffix ] change

        child>>
        [ first compute-copy-equiv ]
        [ first propagate-recursive-phi ]
        [ (propagate) ]
        tri

        loop-nesting dec
    ] until-fixed-point ;

: recursive-phi-infos ( node -- infos )
    label>> enter-recursive>> node-output-infos ;

: generalize-return-interval ( info -- info' )
    dup [ literal?>> ] [ class>> null-class? ] bi or
    [ clone dup class>> class-interval >>interval ] unless ;

: generalize-return ( infos -- infos' )
    [ generalize-return-interval ] map ;

: return-infos ( node -- infos )
    label>> return>> node-input-infos generalize-return ;

: save-return-infos ( node infos -- )
    swap out-d>> set-value-infos ;

: unless-loop ( node quot -- )
    [ dup label>> loop?>> [ drop ] ] dip if ; inline

M: #call-recursive propagate-before ( #call-recursive -- )
    [
        [ ] [ latest-input-infos ] [ recursive-phi-infos ] tri
        check-fixed-point
    ]
    [
        [
            [ ] [ return-infos ] [ node-output-infos ] tri
            [ check-fixed-point ] [ drop save-return-infos ] 3bi
        ] unless-loop
    ] bi ;

M: #call-recursive annotate-node
    dup [ in-d>> ] [ out-d>> ] bi append (annotate-node) ;

M: #enter-recursive annotate-node
    dup out-d>> (annotate-node) ;

M: #return-recursive propagate-before ( #return-recursive -- )
    [
        [ ] [ latest-input-infos ] [ node-input-infos ] tri
        check-fixed-point
    ] unless-loop ;

M: #return-recursive annotate-node
    dup in-d>> (annotate-node) ;

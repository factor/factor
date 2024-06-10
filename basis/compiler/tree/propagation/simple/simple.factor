! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs classes classes.algebra
classes.algebra.private classes.maybe classes.tuple.private
combinators combinators.short-circuit compiler.tree
compiler.tree.propagation.constraints compiler.tree.propagation.info
compiler.tree.propagation.inlining compiler.tree.propagation.nodes
compiler.tree.propagation.slots continuations fry kernel make
sequences sets stack-checker.dependencies words ;
IN: compiler.tree.propagation.simple

M: #introduce propagate-before
    out-d>> [ object-info swap set-value-info ] each ;

M: #push propagate-before
    [ literal>> <literal-info> ] [ out-d>> first ] bi
    set-value-info ;

M: #declare propagate-before
    ! We need to force the caller word to recompile when the
    ! classes mentioned in the declaration are redefined, since
    ! now we're making assumptions about their definitions.
    declaration>> [
        [ add-depends-on-class ]
        [ <class-info> swap refine-value-info ]
        bi
    ] assoc-each ;

: predicate-constraints ( value class boolean-value -- constraint )
    [ [ is-instance-of ] dip t--> ]
    [ [ class-not is-instance-of ] dip f--> ]
    3bi 2array ;

: custom-constraints ( #call quot -- )
    [ [ in-d>> ] [ out-d>> ] bi append ] dip
    with-datastack first assume ;

: compute-constraints ( #call word -- )
    dup "constraints" word-prop [ nip custom-constraints ] [
        dup predicate? [
            [ [ in-d>> first ] [ out-d>> first ] bi ]
            [ "predicating" word-prop ] bi*
            swap predicate-constraints assume
        ] [ 2drop ] if
    ] if* ;

ERROR: invalid-outputs #call infos ;

: check-outputs ( #call infos -- infos )
    over out-d>> over 2length =
    [ nip ] [ invalid-outputs ] if ;

: call-outputs-quot ( #call word -- infos )
    dupd
    [ in-d>> [ value-info ] map ]
    [ "outputs" word-prop ] bi*
    with-datastack check-outputs ;

: literal-inputs? ( #call -- ? )
    in-d>> [ value-info literal?>> ] all? ;

: input-classes-match? ( #call word -- ? )
    [ in-d>> ] [ "input-classes" word-prop ] bi*
    [ [ value-info literal>> ] dip instance? ] 2all? ;

: foldable-call? ( #call word -- ? )
    {
        [ nip foldable? ]
        [ drop literal-inputs? ]
        [ input-classes-match? ]
    } 2&& ;

: (fold-call) ( #call word -- info )
    [ [ out-d>> ] [ in-d>> [ value-info literal>> ] map ] bi ] [ '[ _ execute ] ] bi*
    '[ _ _ with-datastack [ <literal-info> ] map nip ]
    [ drop length [ object-info ] replicate ]
    recover ;

: fold-call ( #call word -- )
    [ (fold-call) ] [ drop out-d>> ] 2bi set-value-infos ;

: predicate-output-infos/literal ( info class -- info )
    [ literal>> ] dip
    '[ _ _ instance? <literal-info> ]
    [ drop object-info ]
    recover ;

: predicate-output-infos/class ( info class -- info )
    [ class>> ] dip evaluate-class-predicate
    dup +incomparable+ eq? [ drop object-info ] [ <literal-info> ] if ;

: predicate-output-infos ( info class -- info )
    over literal?>>
    [ predicate-output-infos/literal ]
    [ predicate-output-infos/class ]
    if ;

: propagate-predicate ( #call word -- infos )
    [ in-d>> first value-info ]
    [ "predicating" word-prop ] bi*
    [ nip +conditional+ depends-on ]
    [ predicate-output-infos 1array ] 2bi ;

: default-output-value-infos ( #call word -- infos )
    "default-output-classes" word-prop or?
    [ class-infos ] [ out-d>> length object-info <repetition> ] if ;

: output-value-infos ( #call word -- infos )
    {
        { [ dup \ <tuple-boa> eq? ] [ drop propagate-<tuple-boa> ] }
        { [ dup sequence-constructor? ] [ propagate-sequence-constructor ] }
        { [ dup predicate? ] [ propagate-predicate ] }
        { [ dup "outputs" word-prop ] [ call-outputs-quot ] }
        [ default-output-value-infos ]
    } cond ;

M: #call propagate-before
    dup word>> {
        { [ 2dup foldable-call? ] [ fold-call ] }
        { [ 2dup do-inlining ] [
            [ output-value-infos ] [ drop out-d>> ] 2bi refine-value-infos
        ] }
        [
            [ [ output-value-infos ] [ drop out-d>> ] 2bi set-value-infos ]
            [ compute-constraints ]
            2bi
        ]
    } cond ;

M: #call annotate-node
    dup [ in-d>> ] [ out-d>> ] bi append (annotate-node) ;

: propagate-input-infos ( node infos/f -- )
    swap in-d>> refine-value-infos ;

M: #call propagate-after
    dup word>> word>input-infos propagate-input-infos ;

: propagate-alien-invoke ( node -- )
    [ out-d>> ] [ params>> return>> ] bi
    [ drop ] [ c-type-class <class-info> swap first set-value-info ] if-void ;

M: #alien-node propagate-before propagate-alien-invoke ;

M: #alien-callback propagate-around child>> (propagate) ;

M: #return annotate-node dup in-d>> (annotate-node) ;

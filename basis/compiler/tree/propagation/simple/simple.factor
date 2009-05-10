! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors kernel sequences sequences.private assocs words
namespaces classes.algebra combinators classes classes.tuple
classes.tuple.private continuations arrays alien.c-types
math math.private slots generic definitions
stack-checker.state
compiler.tree
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.slots
compiler.tree.propagation.inlining
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.simple

! Propagation for straight-line code.

M: #introduce propagate-before
    out-d>> [ object-info swap set-value-info ] each ;

M: #push propagate-before
    [ literal>> <literal-info> ] [ out-d>> first ] bi
    set-value-info ;

: refine-value-infos ( classes values -- )
    [ refine-value-info ] 2each ;

: class-infos ( classes -- infos )
    [ <class-info> ] map ;

: set-value-infos ( infos values -- )
    [ set-value-info ] 2each ;

M: #declare propagate-before
    #! We need to force the caller word to recompile when the
    #! classes mentioned in the declaration are redefined, since
    #! now we're making assumptions but their definitions.
    declaration>> [
        [ inlined-dependency depends-on ]
        [ <class-info> swap refine-value-info ]
        bi
    ] assoc-each ;

: predicate-constraints ( value class boolean-value -- constraint )
    [ [ is-instance-of ] dip t--> ]
    [ [ class-not is-instance-of ] dip f--> ]
    3bi /\ ;

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

: call-outputs-quot ( #call word -- infos )
    [ in-d>> [ value-info ] map ] [ "outputs" word-prop ] bi*
    with-datastack ;

: foldable-call? ( #call word -- ? )
    "foldable" word-prop
    [ in-d>> [ value-info literal?>> ] all? ] [ drop f ] if ;

: (fold-call) ( #call word -- info )
    [ [ out-d>> ] [ in-d>> [ value-info literal>> ] map ] bi ] [ '[ _ execute ] ] bi*
    '[ _ _ with-datastack [ <literal-info> ] map nip ]
    [ drop [ object-info ] replicate ]
    recover ;

: fold-call ( #call word -- )
    [ (fold-call) ] [ drop out-d>> ] 2bi set-value-infos ;

: predicate-output-infos/literal ( info class -- info )
    [ literal>> ] dip
    '[ _ _ instance? <literal-info> ]
    [ drop object-info ]
    recover ;

: predicate-output-infos/class ( info class -- info )
    [ class>> ] dip {
        { [ 2dup class<= ] [ t <literal-info> ] }
        { [ 2dup classes-intersect? not ] [ f <literal-info> ] }
        [ object-info ]
    } cond 2nip ;

: predicate-output-infos ( info class -- info )
    over literal?>>
    [ predicate-output-infos/literal ]
    [ predicate-output-infos/class ]
    if ;

: propagate-predicate ( #call word -- infos )
    #! We need to force the caller word to recompile when the class
    #! is redefined, since now we're making assumptions but the
    #! class definition itself.
    [ in-d>> first value-info ]
    [ "predicating" word-prop dup inlined-dependency depends-on ] bi*
    predicate-output-infos 1array ;

: default-output-value-infos ( #call word -- infos )
    "default-output-classes" word-prop
    [ class-infos ] [ out-d>> length object-info <repetition> ] ?if ;

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
        { [ 2dup do-inlining ] [ 2drop ] }
        [
            [ [ output-value-infos ] [ drop out-d>> ] 2bi set-value-infos ]
            [ compute-constraints ]
            2bi
        ]
    } cond ;

M: #call annotate-node
    dup [ in-d>> ] [ out-d>> ] bi append (annotate-node) ;

: propagate-input-classes ( node input-classes -- )
    class-infos swap in-d>> refine-value-infos ;

M: #call propagate-after
    dup word>> "input-classes" word-prop dup
    [ propagate-input-classes ] [ 2drop ] if ;

: propagate-alien-invoke ( node -- )
    [ out-d>> ] [ params>> return>> ] bi
    [ drop ] [ c-type-class <class-info> swap first set-value-info ] if-void ;

M: #alien-invoke propagate-before propagate-alien-invoke ;

M: #alien-indirect propagate-before propagate-alien-invoke ;

M: #return annotate-node dup in-d>> (annotate-node) ;

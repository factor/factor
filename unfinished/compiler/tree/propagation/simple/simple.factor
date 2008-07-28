! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors kernel sequences sequences.private assocs
words namespaces classes.algebra combinators classes
classes.tuple classes.tuple.private continuations arrays
byte-arrays strings math math.private slots
compiler.tree
compiler.tree.def-use
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.slots
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.simple

M: #introduce propagate-before
    value>> object <class-info> swap set-value-info ;

M: #push propagate-before
    [ literal>> value>> <literal-info> ] [ out-d>> first ] bi
    set-value-info ;

: refine-value-infos ( classes values -- )
    [ refine-value-info ] 2each ;

: class-infos ( classes -- infos )
    [ <class-info> ] map ;

: set-value-infos ( infos values -- )
    [ set-value-info ] 2each ;

M: #declare propagate-before
    declaration>> [ <class-info> swap refine-value-info ] assoc-each ;

: predicate-constraints ( value class boolean-value -- constraint )
    [ [ is-instance-of ] dip t--> ]
    [ [ class-not is-instance-of ] dip f--> ]
    3bi /\ ;

: custom-constraints ( #call quot -- )
    [ [ in-d>> ] [ out-d>> ] bi append ] dip
    with-datastack first assume ;

: compute-constraints ( #call -- )
    dup word>> +constraints+ word-prop [ custom-constraints ] [
        dup word>> predicate? [
            [ in-d>> first ]
            [ word>> "predicating" word-prop ]
            [ out-d>> first ]
            tri predicate-constraints assume
        ] [ drop ] if
    ] if* ;

: call-outputs-quot ( node -- infos )
    [ in-d>> [ value-info ] map ]
    [ word>> +outputs+ word-prop ]
    bi with-datastack ;

: foldable-word? ( #call -- ? )
    dup word>> "foldable" word-prop [
        drop t
    ] [
        dup word>> \ <tuple-boa> eq? [
            in-d>> peek value-info literal>> immutable-tuple-class?
        ] [
            drop f
        ] if
    ] if ;

: foldable-call? ( #call -- ? )
    dup word>> "foldable" word-prop [
        in-d>> [ value-info literal?>> ] all?
    ] [
        drop f
    ] if ;

: fold-call ( #call -- infos )
    [ in-d>> [ value-info literal>> ] map ]
    [ word>> [ execute ] curry ]
    bi with-datastack
    [ <literal-info> ] map ;

: default-output-value-infos ( node -- infos )
    dup word>> "default-output-classes" word-prop [
        class-infos
    ] [
        out-d>> length object <class-info> <repetition>
    ] ?if ;

: output-value-infos ( node -- infos )
    {
        { [ dup foldable-call? ] [ fold-call ] }
        { [ dup tuple-constructor? ] [ propagate-tuple-constructor ] }
        { [ dup word>> reader? ] [ reader-word-outputs ] }
        { [ dup sequence-constructor? ] [ propagate-sequence-constructor ] }
        { [ dup length-accessor? ] [ propagate-length ] }
        { [ dup word>> +outputs+ word-prop ] [ call-outputs-quot ] }
        [ default-output-value-infos ]
    } cond ;

M: #call propagate-before
    [ [ output-value-infos ] [ out-d>> ] bi set-value-infos ]
    [ compute-constraints ]
    bi ;

M: node propagate-before drop ;

: propagate-input-classes ( node -- )
    [ word>> "input-classes" word-prop class-infos ] [ in-d>> ] bi
    refine-value-infos ;

M: #call propagate-after
    {
        { [ dup reader? ] [ reader-word-inputs ] }
        { [ dup word>> "input-classes" word-prop ] [ propagate-input-classes ] }
        [ drop ]
    } cond ;

M: node propagate-after drop ;

: annotate-node ( node -- )
    dup
    [ node-defs-values ] [ node-uses-values ] bi append
    [ dup value-info ] H{ } map>assoc
    >>info drop ;

M: node propagate-around
    [ propagate-before ] [ annotate-node ] [ propagate-after ] tri ;

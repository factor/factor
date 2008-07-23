! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors kernel sequences assocs words namespaces
classes.algebra combinators classes continuations
compiler.tree
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.simple

M: #introduce propagate-before
    object <class-info> swap values>> [ set-value-info ] with each ;

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
    [ [ in-d>> ] [ out-d>> ] bi are-copies-of ]
    [
        [ declaration>> class-infos ] [ out-d>> ] bi
        refine-value-infos
    ] bi ;

M: #shuffle propagate-before
    [ out-d>> dup ] [ mapping>> ] bi
    '[ , at ] map swap are-copies-of ;

M: #>r propagate-before
    [ in-d>> ] [ out-r>> ] bi are-copies-of ;

M: #r> propagate-before
    [ in-r>> ] [ out-d>> ] bi are-copies-of ;

M: #copy propagate-before
    [ in-d>> ] [ out-d>> ] bi are-copies-of ;

: predicate-constraints ( value class boolean-value -- constraint )
    [ [ <class-constraint> ] dip if-true ]
    [ [ class-not <class-constraint> ] dip if-false ]
    3bi <conjunction> ;

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

: default-output-value-infos ( node -- infos )
    dup word>> "default-output-classes" word-prop [
        class-infos
    ] [
        out-d>> length object <class-info> <repetition>
    ] ?if ;

: call-outputs-quot ( node quot -- infos )
    [ in-d>> [ value-info ] map ] dip with-datastack ;

: output-value-infos ( node -- infos )
    dup word>> +outputs+ word-prop
    [ call-outputs-quot ] [ default-output-value-infos ] if* ;

M: #call propagate-before
    [ [ output-value-infos ] [ out-d>> ] bi set-value-infos ]
    [ compute-constraints ]
    bi ;

M: node propagate-before drop ;

M: #call propagate-after
    dup word>> "input-classes" word-prop dup [
        class-infos swap in-d>> refine-value-infos
    ] [
        2drop
    ] if ;

M: node propagate-after drop ;

: annotate-node ( node -- )
    dup node-values [ dup value-info ] H{ } map>assoc >>info drop ;

M: node propagate-around
    [ propagate-before ] [ annotate-node ] [ propagate-after ] tri ;

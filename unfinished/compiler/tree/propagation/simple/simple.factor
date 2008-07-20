! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors kernel sequences assocs words namespaces
combinators classes.algebra compiler.tree
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.simple

GENERIC: propagate-before ( node -- )

M: #introduce propagate-before
    values>> [ object swap set-value-class ] each ;

M: #push propagate-before
    [ literal>> ] [ out-d>> first ] bi set-value-literal ;

M: #declare propagate-before
    [ [ in-d>> ] [ out-d>> ] bi are-copies-of ]
    [ [ declaration>> ] [ out-d>> ] bi [ intersect-value-class ] 2each ]
    bi ;

M: #shuffle propagate-before
    [ out-r>> dup ] [ mapping>> ] bi '[ , at ] map are-copies-of ;

M: #>r propagate-before
    [ in-d>> ] [ out-r>> ] bi are-copies-of ;

M: #r> propagate-before
    [ in-r>> ] [ out-d>> ] bi are-copies-of ;

M: #copy propagate-before
    [ in-d>> ] [ out-d>> ] bi are-copies-of ;

: intersect-classes ( classes values -- )
    [ intersect-value-class ] 2each ;

: intersect-intervals ( intervals values -- )
    [ intersect-value-interval ] 2each ;

: predicate-constraints ( class #call -- )
    [
        ! If word outputs true, input is an instance of class
        [
            0 `input class,
            \ f class-not 0 `output class,
        ] set-constraints
    ] [
        ! If word outputs false, input is not an instance of class
        [
            class-not 0 `input class,
            \ f 0 `output class,
        ] set-constraints
    ] 2bi ;

: compute-constraints ( #call -- )
    dup word>> "constraints" word-prop [
        call
    ] [
        dup word>> "predicating" word-prop dup
        [ swap predicate-constraints ] [ 2drop ] if
    ] if* ;

: compute-output-classes ( node word -- classes intervals )
    dup word>> "output-classes" word-prop
    dup [ call ] [ 2drop f f ] if ;

: output-classes ( node -- classes intervals )
    dup compute-output-classes [
        [ ] [ word>> "default-output-classes" word-prop ] ?if
    ] dip ;

: intersect-values ( classes intervals values -- )
    tuck [ intersect-classes ] [ intersect-intervals ] 2bi* ;

M: #call propagate-before
    [ compute-constraints ]
    [ [ output-classes ] [ out-d>> ] bi intersect-values ] bi ;

M: node propagate-before drop ;

GENERIC: propagate-after ( node -- )

: input-classes ( #call -- classes )
    word>> "input-classes" word-prop ;

M: #call propagate-after
    [ input-classes ] [ in-d>> ] bi intersect-classes ;

M: node propagate-after drop ;

GENERIC: propagate-around ( node -- )

: valid-keys ( seq assoc -- newassoc )
    '[ dup resolve-copy , at ] H{ } map>assoc
    [ nip ] assoc-filter
    f assoc-like ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values {
        [ value-intervals get valid-keys >>intervals ]
        [ value-classes   get valid-keys >>classes   ]
        [ value-literals  get valid-keys >>literals  ]
        [ 2drop ]
    } cleave ;

M: object propagate-around
    {
        [ propagate-before ]
        [ annotate-node ]
        [ propagate-after ]
    } cleave ;

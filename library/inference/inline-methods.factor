! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables kernel lists sequences vectors words ;

! Method inlining optimization

: min-class? ( class seq -- ? )
    #! Is this class the smallest class in the sequence?
    2dup member? [
        [ dupd class-and ] map
        [ null = not ] subset
        [ class< ] all-with?
    ] [
        2drop f
    ] ifte ;

GENERIC: dispatching-values ( node word -- seq )

M: object dispatching-values 2drop { } ;

M: simple-generic dispatching-values drop node-in-d peek 1vector ;

M: 2generic dispatching-values drop node-in-d 2 swap tail* ;

: safe-node-classes ( node seq -- seq )
    >r node-classes r> [
        dup value-safe? [
            swap ?hash [ object ] unless*
        ] [
            2drop object
        ] ifte
    ] map-with ;

: dispatching-classes ( node -- seq )
    dup dup node-param dispatching-values safe-node-classes ;

: inline-method? ( #call -- ? )
    dup dispatching-classes dup empty? [
        2drop f
    ] [
        dup [ = ] every? [
            first swap node-param order min-class?
        ] [
            2drop f
        ] ifte
    ] ifte ;

: subst-node
    [ last-node set-node-successor ] keep ;

: inline-method ( node -- node )
    dup dispatching-classes first
    over node-param "methods" word-prop hash
    over node-in-d dataflow-with
    subst-node ;

: related? ( actual testing -- ? )
    #! If actual is a subset of testing or if the two classes
    #! are disjoint, return t.
    2dup class< >r class-and null = r> or ;

: optimize-predicate? ( #call -- ? )
    dup node-param "predicating" word-prop dup [
        >r dup node-in-d safe-node-classes first r> related?
    ] [
        2drop f
    ] ifte ;

: subst-literal ( successor literal -- #push )
    #! Make #push -> #return -> successor
    literalize dataflow [ last-node set-node-successor ] keep ;

: inline-literal ( node literal -- node )
    over drop-inputs
    [ >r subst-literal r> set-node-successor ] keep ;

: optimize-predicate ( #call -- node )
    dup node-param "predicating" word-prop
    over dup node-in-d safe-node-classes first class<
    inline-literal ;

M: #call optimize-node* ( node -- node/t )
    dup node-param [
        dup inline-method? [
            inline-method
        ] [
            dup optimize-predicate? [
                optimize-predicate
            ] [
                dup optimize-not? [
                    node-successor dup flip-branches
                ] [
                    drop t
                ] ifte
            ] ifte
        ] ifte
    ] [
        node-successor
    ] ifte ;

: post-inline ( #return #call -- node )
    [ >r node-in-d r> node-out-d ] keep
    node-successor [ subst-values ] keep ;

M: #return optimize-node* ( node -- node/t )
    #! A #return followed by another node is a result of
    #! method inlining. Do a value substitution and drop both
    #! nodes.
    dup node-successor dup [ post-inline ] [ 2drop t ] ifte ;

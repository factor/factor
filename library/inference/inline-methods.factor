! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel lists math
namespaces sequences words ;

! Method inlining optimization

GENERIC: dispatching-values ( node word -- seq )

M: object dispatching-values 2drop { } ;

M: simple-generic dispatching-values drop node-in-d peek 1array ;

M: 2generic dispatching-values drop node-in-d 2 swap tail* ;

: node-classes* ( node seq -- seq )
    >r node-classes r>
    [ swap ?hash [ object ] unless* ] map-with ;

: dispatching-classes ( node -- seq )
    dup node-in-d empty? [
        drop { }
    ] [
        dup dup node-param dispatching-values node-classes*
    ] if ;

: already-inlined? ( node -- ? )
    #! Was this node inlined from definition of 'word'?
    dup node-param swap node-history memq? ;

: inlining-class ( #call -- class )
    #! If the generic dispatch can be eliminated, return the
    #! class of the method that will always be invoked here.
    dup already-inlined? [
        drop f
    ] [
        dup dispatching-classes dup empty? [
            2drop f
        ] [
            dup all-eq? [
                first swap node-param order min-class
            ] [
                2drop f
            ] if
        ] if
    ] if ;

: will-inline ( node -- quot )
    dup inlining-class swap node-param "methods" word-prop hash ;

: method-dataflow ( node -- dataflow )
    dup will-inline swap node-in-d dataflow-with
    dup solve-recursion ;

: inline-method ( node -- node )
    #! We set the #call node's param to f so that it gets killed
    #! later.
    dup method-dataflow
    [ >r node-param r> remember-node ] 2keep
    [ subst-node ] keep ;

: related? ( actual testing -- ? )
    #! If actual is a subset of testing or if the two classes
    #! are disjoint, return t.
    2dup class< >r classes-intersect? not r> or ;

: optimize-predicate? ( #call -- ? )
    dup node-param "predicating" word-prop dup [
        >r dup node-in-d node-classes* first r> related?
    ] [
        2drop f
    ] if ;

: optimize-predicate ( #call -- node )
    dup node-param "predicating" word-prop >r
    dup dup node-in-d node-classes* first r> class<
    1array inline-literals ;

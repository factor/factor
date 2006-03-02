! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel lists math
namespaces sequences words ;

! Method inlining optimization

GENERIC: dispatching-values ( node word -- seq )

M: object dispatching-values 2drop { } ;

M: standard-generic dispatching-values
    "combination" word-prop first swap
    node-in-d reverse-slice nth 1array ;

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
    dup will-inline swap node-in-d dataflow-with ;

: post-inline ( #return/#values #call/#merge -- )
    dup [
        [
            >r node-in-d r> node-out-d
            2array unify-lengths first2
        ] keep node-successor subst-values
    ] [
        2drop
    ] if ;

: subst-node ( old new -- )
    #! The last node of 'new' becomes 'old', then values are
    #! substituted. A subsequent optimizer phase kills the
    #! last node of 'new' and the first node of 'old'.
    last-node 2dup swap post-inline set-node-successor ;

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

: inline-literals ( node literals -- node )
    #! Make #push -> #return -> successor
    over drop-inputs [
        >r >list [ literalize ] map dataflow [ subst-node ] keep
        r> set-node-successor
    ] keep ;

: optimize-predicate ( #call -- node )
    dup node-param "predicating" word-prop >r
    dup dup node-in-d node-classes* first r> class<
    1array inline-literals ;

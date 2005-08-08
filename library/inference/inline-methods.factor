! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: namespaces generic hashtables kernel lists sequences
vectors words ;

! Method inlining optimization

: min-class ( class seq -- class/f )
    #! Is this class the smallest class in the sequence?
    [ dupd class-and null = not ] subset [ class< not ] sort
    tuck [ class< ] all-with? [ first ] [ drop f ] ifte ;

GENERIC: dispatching-values ( node word -- seq )

M: object dispatching-values 2drop { } ;

M: simple-generic dispatching-values drop node-in-d peek 1vector ;

M: 2generic dispatching-values drop node-in-d 2 swap tail* ;

: node-classes* ( node seq -- seq )
    >r node-classes r>
    [ swap ?hash [ object ] unless* ] map-with ;

: dispatching-classes ( node -- seq )
    dup dup node-param dispatching-values node-classes* ;

: inlining-class ( #call -- class )
    #! If the generic dispatch can be eliminated, return the
    #! class of the method that will always be invoked here.
    dup node-param recursive-state get member? [
        drop f
    ] [
        dup dispatching-classes dup empty? [
            2drop f
        ] [
            dup [ = ] every? [
                first swap node-param order min-class
            ] [
                2drop f
            ] ifte
        ] ifte
    ] ifte ;

: unlink-last ( node -- butlast last )
    dup penultimate-node
    dup node-successor
    f rot set-node-successor ;

: subst-node ( label old new -- new )
    #! #simple-label<label> ---> new-last ---> old
    #!     |---> new-butlast
    dup node-successor [
        unlink-last rot over set-node-successor
        >r >r #simple-label r> 1vector over set-node-children
        r> over set-node-successor
    ] [
        [ set-node-successor drop ] keep
    ] ifte ;

: inline-method ( node -- node )
    dup inlining-class
    over node-param "methods" word-prop hash
    over node-in-d dataflow-with dup solve-recursion
    >r [ node-param ] keep r> subst-node ;

: related? ( actual testing -- ? )
    #! If actual is a subset of testing or if the two classes
    #! are disjoint, return t.
    2dup class< >r class-and null = r> or ;

: optimize-predicate? ( #call -- ? )
    dup node-param "predicating" word-prop dup [
        >r dup node-in-d node-classes* first r> related?
    ] [
        2drop f
    ] ifte ;

: optimize-predicate ( #call -- node )
    dup node-param "predicating" word-prop >r
    dup dup node-in-d node-classes* first r> class<
    unit inline-literals ;

M: #return optimize-node* ( node -- node/t )
    #! A #return followed by another node is a result of
    #! method inlining. Do a value substitution and drop both
    #! nodes.
    dup node-successor dup [ post-inline ] [ 2drop t ] ifte ;

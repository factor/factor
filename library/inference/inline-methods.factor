! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables kernel sequences words ;

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

: node-dispatching-class ( node -- class )
    dup node-in-d peek dup value-safe? [
        swap node-classes ?hash
    ] [
        2drop object
    ] ifte ;

: inline-method? ( #call -- ? )
    dup node-param "picker" word-prop [ dup ] = [
        dup node-dispatching-class dup [
            swap node-param order min-class?
        ] [
            2drop f
        ] ifte
    ] [
        drop f
    ] ifte ;

: subst-node ( old new -- )
    last-node set-node-successor ;

: inline-method ( node -- node )
    dup node-dispatching-class
    over node-param "methods" word-prop hash
    over node-in-d dataflow-with
    [ subst-node ] keep ;

M: #call optimize-node* ( node -- node/t )
    dup node-param [
        dup inline-method? [
            inline-method
        ] [
            dup optimize-not? [
                node-successor dup flip-branches
            ] [
                drop t
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

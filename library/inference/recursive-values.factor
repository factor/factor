! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: optimizer
USING: inference kernel namespaces prettyprint sequences vectors ;

GENERIC: collect-recursion* ( label node -- )

M: node collect-recursion* ( label node -- ) 2drop ;

M: #call-label collect-recursion* ( label node -- )
    tuck node-param = [ node-in-d , ] [ drop ] if ;

: collect-recursion ( #label -- seq )
    #! Collect the input stacks of all #call-label nodes that
    #! call given label.
    dup node-param swap
    [ [ collect-recursion* ] each-node-with ] @{ }@ make ;

GENERIC: solve-recursion*

M: node solve-recursion* ( node -- ) drop ;

: purge-invariants ( stacks -- seq )
    #! Output a sequence of values which are not present in the
    #! same position in each sequence of the stacks sequence.
    flip [ all-eq? not ] subset concat ;

: join-values ( calls entry -- new old live )
    add unify-lengths
    [ flip [ unify-values ] map ] keep
    [ peek ] keep
    purge-invariants ;

: entry-values ( node -- new old live )
    dup collect-recursion swap node-child node-in-d join-values ;

M: #label solve-recursion* ( node -- )
    #! #entry node-out-d is abused; its not a stack slice, but
    #! a set of values.
    [ entry-values ] keep node-child
    [ set-node-out-d ] keep
    node-successor subst-values ;

: solve-recursion ( node -- )
    #! Figure out which values survive inner recursions in
    #! #labels, and those that don't should be fudged.
    [ solve-recursion* ] each-node ;

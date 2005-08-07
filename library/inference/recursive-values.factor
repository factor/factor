! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: kernel namespaces prettyprint sequences vectors ;

GENERIC: collect-recursion* ( label node -- )

M: node collect-recursion* ( label node -- ) 2drop ;

M: #call-label collect-recursion* ( label node -- )
    tuck node-param = [ node-in-d , ] [ drop ] ifte ;

: collect-recursion ( label node -- seq )
    #! Collect the input stacks of all #call-label nodes that
    #! call given label.
    [ [ collect-recursion* ] each-node-with ] make-vector ;

GENERIC: solve-recursion*

M: node solve-recursion* ( node -- ) drop ;

M: #label solve-recursion* ( node -- )
    dup node-param over collect-recursion >r
    node-children first dup node-in-d r> swap add
    unify-stacks swap [ node-in-d unify-length ] keep
    subst-values ;

: solve-recursion ( node -- )
    #! Figure out which values survive inner recursions in
    #! #labels, and those that don't should be fudged.
    [ solve-recursion* ] each-node ;

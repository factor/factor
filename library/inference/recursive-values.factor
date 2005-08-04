! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: kernel namespaces prettyprint sequences vectors ;

! Technical detail: need to figure out which values survive
! inner recursions in #labels.

GENERIC: collect-recursion* ( label node -- )

M: node collect-recursion* ( label node -- ) 2drop ;

M: #call-label collect-recursion* ( label node -- )
    tuck node-param = [ node-in-d , ] [ drop ] ifte ;

: collect-recursion ( label node -- seq )
    #! Collect the input stacks of all #call-label nodes that
    #! call given label.
    [ [ collect-recursion* ] each-node-with ] make-vector ;

: first-child ( child node -- )
    [ node-children first over set-node-successor 1vector ] keep
    set-node-children ;

M: #label optimize-node* ( node -- node/t )
    dup dup node-param over collect-recursion >r
    node-children first node-in-d r> swap add
    unify-stacks #split swap first-child t ;

M: #split optimize-node* ( node -- node/t )
    node-successor ;

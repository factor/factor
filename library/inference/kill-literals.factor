! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel math
namespaces sequences ;

: node-union ( node quot -- hash | quot: node -- )
    [
        swap [ swap call [ dup set ] each ] each-node-with
    ] make-hash ; inline

GENERIC: literals* ( node -- seq )

: literals ( node -- hash )
    [ literals* ] node-union ;

GENERIC: live-values* ( node -- seq )

: live-values ( node -- hash )
    #! All values that are returned or passed to calls.
    [ live-values* ] node-union ;

GENERIC: returns* ( node -- )

: returns ( node -- seq )
    #! Trace all control flow paths, build a hash of
    #! final #return nodes.
    [ returns* ] @{ }@ make ;

M: f returns* drop ;

: kill-set ( node -- hash )
    #! Push a list of literals that may be killed in the IR.
    dup live-values swap literals hash-diff ;

: remove-values ( values node -- )
    2dup [ node-in-d remove-all ] keep set-node-in-d
    2dup [ node-out-d remove-all ] keep set-node-out-d
    2dup [ node-in-r remove-all ] keep set-node-in-r
    [ node-out-r remove-all ] keep set-node-out-r ;

: kill-node ( values node -- )
    over hash-size 0 >
    [ [ remove-values ] each-node-with ] [ 2drop ] if ;

! Generic nodes
M: node literals* ( node -- ) drop @{ }@ ;

M: node live-values* ( node -- ) node-values ;

M: node returns* ( node -- seq ) node-successor returns* ;

! #shuffle
M: #shuffle literals* ( node -- seq )
    dup node-out-d swap node-out-r
    [ [ literal? ] subset ] 2apply append ;

! #return
M: #return returns* , ;

M: #return live-values* ( node -- seq )
    #! Values returned by local labels can be killed.
    dup node-param [ drop @{ }@ ] [ delegate live-values* ] if ;

! nodes that don't use their input values directly
UNION: #killable #shuffle #call-label #merge #values ;

M: #killable live-values* ( node -- seq ) drop @{ }@ ;

! #entry
M: #entry live-values* ( node -- seq )
    #! The live values are those which appear in the in-d but
    #! not in the out-d. These are literals which are replaced
    #! by computed values in the solve-recursion step.
    node-out-d ;

! branching
UNION: #branch #if #dispatch ;

M: #branch returns* ( node -- ) node-children [ returns* ] each ;

M: #branch live-values* ( node -- )
    #! This assumes that the last element of each branch is a
    #! #return node.
    dup delegate live-values* >r returns [ node-in-d ] map
    unify-lengths purge-invariants r> append ;

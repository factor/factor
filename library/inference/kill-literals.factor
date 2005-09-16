! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel
namespaces sequences ;

: node-union ( node quot -- hash | quot: node -- seq )
    #! Build a hash with equal keys/values, effectively taking
    #! the set union over all return values of the quotation.
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

GENERIC: returns*

: returns ( node -- hash )
    #! Trace all control flow paths, build a hash of
    #! final #return nodes.
    [ returns* ] node-union ;

: kill-set ( node -- seq )
    #! Push a list of literals that may be killed in the IR.
    dup live-values swap literals hash-diff hash-keys ;

: remove-values ( values node -- )
    2dup [ node-in-d remove-all ] keep set-node-in-d
    2dup [ node-out-d remove-all ] keep set-node-out-d
    2dup [ node-in-r remove-all ] keep set-node-in-r
    [ node-out-r remove-all ] keep set-node-out-r ;

: kill-node ( literals node -- )
    [ remove-values ] each-node-with ;

! Generic nodes
M: node literals* ( node -- seq ) drop @{ }@ ;

M: node live-values* ( node -- seq ) node-values ;

M: node returns* ( node -- seq ) drop @{ }@ ;

! #shuffle
M: #shuffle literals* ( node -- seq )
    node-out-d [ literal? ] subset ;

! #return
M: #return returns* 1array ;

M: #return live-values* ( node -- seq )
    #! Values returned by local labels can be killed.
    dup node-param [ drop @{ }@ ] [ delegate live-values* ] ifte ;

! nodes that don't use their input values directly
UNION: #killable #shuffle #call-label #merge #entry #values ;

M: #killable live-values* ( node -- seq ) drop @{ }@ ;

! branching
UNION: #branch #ifte #dispatch ;

M: #branch live-values* ( node -- seq )
    #! This assumes that the last element of each branch is a
    #! #return node.
    returns hash-keys [ node-in-d ] map unify-lengths flip
    [ [ eq? ] monotonic? not ] subset concat ;

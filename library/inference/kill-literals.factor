! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: optimizer
USING: arrays generic hashtables inference kernel math
namespaces sequences words ;

: node-union ( node quot -- hash | quot: node -- )
    [
        swap [ swap call [ dup set ] each ] each-node-with
    ] make-hash ; inline

GENERIC: literals* ( node -- seq )

: literals ( node -- hash )
    [ literals* ] node-union ;

! GENERIC: flushable-values* ( node -- seq )
! 
! : flushable-values ( node -- hash )
!     [ flushable-values* ] node-union ;

GENERIC: live-values* ( node -- seq )

: live-values ( node -- hash )
    #! All values that are returned or passed to calls.
    [ live-values* ] node-union ;

: kill-node* ( values node -- )
    2dup [ node-in-d remove-all ] keep set-node-in-d
    2dup [ node-out-d remove-all ] keep set-node-out-d
    2dup [ node-in-r remove-all ] keep set-node-in-r
    [ node-out-r remove-all ] keep set-node-out-r ;

: kill-node ( values node -- )
    over hash-empty?
    [ 2drop ] [ [ kill-node* ] each-node-with ] if ;

: kill-unused-literals ( node -- )
    \ live-values get over literals hash-diff swap kill-node ;

: kill-values ( node -- )
    dup live-values over literals hash-diff swap kill-node ;

! Generic nodes
M: node literals* ( node -- ) drop { } ;

! M: node flushable-values* ( node -- ) drop { } ;

M: node live-values* ( node -- ) node-values ;

! #shuffle
M: #shuffle literals* ( node -- seq )
    dup node-out-d swap node-out-r
    [ [ value? ] subset ] 2apply append ;

! #call
! M: #call flushable-values* ( node -- )
!     dup node-param "flushable" word-prop
!     [ node-out-d ] [ drop { } ] if ;

! #return
M: #return live-values* ( node -- seq )
    #! Values returned by local labels can be killed.
    dup node-param [ drop { } ] [ delegate live-values* ] if ;

! nodes that don't use their input values directly
UNION: #killable #shuffle #call-label #merge #values #entry ;

M: #killable live-values* ( node -- seq ) drop { } ;

: purge-invariants ( stacks -- seq )
    #! Output a sequence of values which are not present in the
    #! same position in each sequence of the stacks sequence.
    unify-lengths flip [ all-eq? not ] subset concat ;

! #label
M: #label live-values* ( node -- seq )
    dup node-child node-in-d over node-in-d 2array
    swap collect-recursion append purge-invariants ;

! branching
UNION: #branch #if #dispatch ;

M: #branch live-values* ( node -- )
    #! This assumes that the last element of each branch is a
    #! #return node.
    dup delegate live-values* >r
    node-children [ last-node node-in-d ] map purge-invariants
    r> append ;

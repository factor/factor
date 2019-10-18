! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: generic kernel math inference namespaces words sequences
;

: intrinsics ( #call -- quot )
    node-param "intrinsics" word-prop ;

: if-intrinsics ( #call -- quot )
    node-param "if-intrinsics" word-prop ;

: no-stack-frame -1 ;

DEFER: #terminal?

PREDICATE: #merge #terminal-merge node-successor #terminal? ;

PREDICATE: #values #terminal-values node-successor #terminal? ;

PREDICATE: #call #terminal-call
    dup node-successor #if?
    over node-successor node-successor #terminal? and
    swap if-intrinsics and ;

UNION: #terminal
    POSTPONE: f #return #terminal-values #terminal-merge ;

: tail-call? ( -- ? )
    node-stack get [
        dup #terminal-call? swap node-successor #terminal? or
    ] all? ;

: tail-stack-frame-size tail-call? no-stack-frame 0 ? ;

GENERIC: stack-frame-size* ( node -- n )

M: object stack-frame-size* drop no-stack-frame ;

: (stack-frame-size) ( n -- n node )
    node@ stack-frame-size* max iterate-next ;

: stack-frame-size ( node -- n )
    [
        no-stack-frame swap
        [ (stack-frame-size) ] iterate-nodes
    ] with-node-iterator ;

: if-stack-frame ( quot -- )
    \ stack-frame-size get no-stack-frame = swap unless ; inline

M: #if stack-frame-size*
    drop
    no-stack-frame [ (stack-frame-size) ] iterate-children ;

M: #label stack-frame-size*
    drop tail-stack-frame-size ;

M: #dispatch stack-frame-size*
    drop tail-stack-frame-size ;

: do-if-intrinsic? ( #call -- ? )
    dup if-intrinsics swap node-successor #if? and ;

M: #call stack-frame-size*
    {
        { [ dup do-if-intrinsic? ] [ drop no-stack-frame ] }
        { [ dup intrinsics ] [ drop no-stack-frame ] }
        { [ t ] [ drop tail-stack-frame-size ] }
    } cond ;

M: #call-label stack-frame-size* drop tail-stack-frame-size ;

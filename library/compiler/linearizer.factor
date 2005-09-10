! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: compiler-backend errors generic lists inference kernel
math namespaces prettyprint sequences
strings words ;

SYMBOL: simple-labels

GENERIC: linearize* ( node -- )

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, and flattens conditionals into
    #! jumps and labels.
    [
        { } clone simple-labels set
        %prologue ,
        linearize*
    ] { } make ;

: linearize-next node-successor linearize* ;

M: f linearize* ( f -- ) drop ;

M: node linearize* ( node -- ) linearize-next ;

: simple-label? ( #label -- ? )
    #! A simple label only contains tail calls to itself.
    dup node-param swap node-child [
        dup #call-label? [
            [ node-param = not ] keep node-successor #return? or
        ] [
            2drop t
        ] ifte
    ] all-nodes-with? ;

: simple-label ( #label -- )
    dup node-param %label , node-child linearize* ;

M: #label linearize* ( node -- )
    dup simple-label? [
        dup node-param simple-labels get push
        dup simple-label
    ] [
        dup <label> [ %return-to , simple-label ] keep %label ,
    ] ifte linearize-next ;

: tail-call? ( node -- ? )
    #! A #call to some other label or word, followed by a
    #! #return from a simple label is not allowed to be
    #! tail-call-optimized; indeed, that #return will not be
    #! generated at all.
    dup node-successor dup #return? [
        swap node-param swap node-param
        dup simple-labels get memq? not >r eq? r> or
    ] [
        2drop f
    ] ifte ;

: ?tail-call ( node caller jumper -- next )
    >r >r dup tail-call? [
        node-param r> drop r> execute ,
    ] [
        dup node-param r> execute , r> drop linearize-next
    ] ifte ; inline

: intrinsic ( #call -- quot ) node-param "intrinsic" word-prop ;

: ifte-intrinsic ( #call -- quot )
    dup node-successor #ifte?
    [ node-param "ifte-intrinsic" word-prop ] [ drop f ] ifte ;

: linearize-ifte ( node label -- )
    #! Assume the quotation emits a VOP that jumps to the label
    #! if some condition holds; we linearize the false branch,
    #! then the label, then the true branch.
    >r node-children first2 linearize* r> %label , linearize* ;

M: #call linearize* ( node -- )
    dup ifte-intrinsic [
        >r <label> 2dup r> call
        >r node-successor r> linearize-ifte
    ] [
        dup intrinsic [
            dupd call linearize-next
        ] [
            \ %call \ %jump ?tail-call
        ] ifte*
    ] ifte* ;

M: #call-label linearize* ( node -- )
    \ %call-label \ %jump-label ?tail-call ;

M: #ifte linearize* ( node -- )
    <label> dup in-1  -1 %inc-d , 0 %jump-t , linearize-ifte ;

: dispatch-head ( vtable -- label/code )
    #! Output the jump table insn and return a list of
    #! label/branch pairs.
    in-1
    -1 %inc-d ,
    0 %untag-fixnum ,
    0 %dispatch ,
    [ <label> dup %target-label ,  cons ] map
    %end-dispatch , ;

: dispatch-body ( label/param -- )
    [ uncons %label , linearize* ] each ;

M: #dispatch linearize* ( vtable -- )
    #! The parameter is a list of nodes, each one is a branch to
    #! take in case the top of stack has that type.
    node-children dispatch-head dispatch-body ;

M: #return linearize* ( node -- )
    #! Simple label returns do not count, since simple labels do
    #! not push a stack frame on the C stack.
    node-param simple-labels get memq? [ %return , ] unless ;

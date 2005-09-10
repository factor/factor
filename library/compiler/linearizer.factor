! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: compiler-backend errors generic lists inference kernel
math namespaces prettyprint sequences
strings words ;

GENERIC: linearize* ( node -- )

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, and flattens conditionals into
    #! jumps and labels.
    [
        %prologue ,
        linearize*
    ] { } make ;

: linearize-next node-successor linearize* ;

M: f linearize* ( f -- ) drop ;

M: node linearize* ( node -- ) linearize-next ;

M: #label linearize* ( node -- )
    <label> [
        %return-to ,
        dup node-param %label ,
        dup node-child linearize*
    ] keep %label ,
    linearize-next ;

: ?tail-call ( node caller jumper -- next )
    >r >r dup node-successor #return? [
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
    drop %return , ;

! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: arrays compiler-backend errors generic inference kernel
lists math namespaces prettyprint sequences strings words ;

: in-1 0 0 %peek-d , ;
: in-2 0 1 %peek-d ,  1 0 %peek-d , ;
: in-3 0 2 %peek-d ,  1 1 %peek-d ,  2 0 %peek-d , ;
: out-1 T{ vreg f 0 } 0 %replace-d , ;

GENERIC: linearize* ( node -- )

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, and flattens conditionals into
    #! jumps and labels.
    [ %prologue , linearize* ] { } make ;

: linearize-next node-successor linearize* ;

M: f linearize* ( f -- ) drop ;

M: node linearize* ( node -- ) linearize-next ;

M: #label linearize* ( node -- )
    #! We remap the IR node's label to a new label object here,
    #! to avoid problems with two IR #label nodes having the
    #! same label in different lexical scopes.
    <label> [
        %return-to ,
        <label> dup pick node-param set %label ,
        dup node-child linearize*
    ] keep %label ,
    linearize-next ;

: ?tail-call ( node label caller jumper -- next )
    >r >r over node-successor #return? [
        r> drop r> execute , drop
    ] [
        r> execute , r> drop linearize-next
    ] if ; inline

: intrinsic ( #call -- quot ) node-param "intrinsic" word-prop ;

: if-intrinsic ( #call -- quot )
    dup node-successor #if?
    [ node-param "if-intrinsic" word-prop ] [ drop f ] if ;

: linearize-if ( node label -- )
    #! Assume the quotation emits a VOP that jumps to the label
    #! if some condition holds; we linearize the false branch,
    #! then the label, then the true branch.
    >r node-children first2 linearize* r> %label , linearize* ;

M: #call linearize* ( node -- )
    dup if-intrinsic [
        >r <label> 2dup r> call
        >r node-successor r> linearize-if
    ] [
        dup intrinsic [
            dupd call linearize-next
        ] [
            dup node-param \ %call \ %jump ?tail-call
        ] if*
    ] if* ;

M: #call-label linearize* ( node -- )
    dup node-param get \ %call-label \ %jump-label ?tail-call ;

M: #if linearize* ( node -- )
    <label> dup in-1  -1 %inc-d , 0 %jump-t , linearize-if ;

: dispatch-head ( vtable -- label/code )
    #! Output the jump table insn and return a list of
    #! label/branch pairs.
    in-1
    -1 %inc-d ,
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
    drop %return , ;

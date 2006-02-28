! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: arrays compiler-backend errors generic hashtables
inference kernel math namespaces prettyprint sequences
strings words ;

: in-1 0 0 %peek-d , ;
: in-2 0 1 %peek-d ,  1 0 %peek-d , ;
: in-3 0 2 %peek-d ,  1 1 %peek-d ,  2 0 %peek-d , ;
: out-1 T{ vreg f 0 } 0 %replace-d , ;

! A map from words to linear IR.
SYMBOL: linearized

! Renamed labels. To avoid problems with labels with the same
! name in different scopes.
SYMBOL: renamed-labels

: rename-label ( label -- label )
    <label> dup rot renamed-labels get set-hash ;

: renamed-label ( label -- label )
    renamed-labels get hash ;

GENERIC: linearize* ( node -- )

: make-linear ( word quot -- )
    swap >r [ %prologue , call ] { } make r>
    linearized get set-hash ; inline

: linearize-1 ( word dataflow -- )
    swap [ linearize* ] make-linear ;

: init-linearizer ( -- )
    H{ } clone linearized set
    H{ } clone renamed-labels set ;

: linearize ( word dataflow -- linearized )
    #! Outputs a hashtable mapping from labels to their
    #! respective linear IR.
    init-linearizer linearize-1 linearized get ;

: linearize-next node-successor linearize* ;

M: f linearize* ( f -- ) drop ;

M: node linearize* ( node -- ) linearize-next ;

: linearize-call ( node label -- )
    over node-successor #return?
    [ %jump , drop ] [ %call , linearize-next ] if ;

: linearize-call-label ( node -- )
    dup node-param rename-label linearize-call ;

M: #label linearize* ( node -- )
    #! We remap the IR node's label to a new label object here,
    #! to avoid problems with two IR #label nodes having the
    #! same label in different lexical scopes.
    dup linearize-call-label dup node-param renamed-label
    swap node-child linearize-1 ;

: intrinsic ( #call -- quot ) node-param "intrinsic" word-prop ;

: if-intrinsic ( #call -- quot )
    dup node-successor #if?
    [ node-param "if-intrinsic" word-prop ] [ drop f ] if ;

: linearize-if ( node label -- )
    <label> dup >r >r >r dup node-children first2 linearize*
    r> r> %jump-label , %label , linearize* r> %label ,
    linearize-next ;

M: #call linearize* ( node -- )
    dup if-intrinsic [
        >r <label> 2dup r> call
        >r node-successor r> linearize-if
    ] [
        dup intrinsic [
            dupd call linearize-next
        ] [
            dup node-param linearize-call
        ] if*
    ] if* ;

M: #call-label linearize* ( node -- )
    dup node-param renamed-label linearize-call ;

M: #if linearize* ( node -- )
    in-1 -1 %inc-d , <label> dup 0 %jump-t , linearize-if ;

: dispatch-head ( vtable -- label/code )
    #! Output the jump table insn and return a list of
    #! label/branch pairs.
    in-1
    -1 %inc-d ,
    0 %dispatch ,
    [ <label> dup %target-label ,  2array ] map ;

: dispatch-body ( label/param -- )
    <label> swap [
        first2 %label , linearize* dup %jump-label ,
    ] each %label , ;

M: #dispatch linearize* ( vtable -- )
    #! The parameter is a list of nodes, each one is a branch to
    #! take in case the top of stack has that type.
    dup node-children dispatch-head dispatch-body
    linearize-next ;

M: #return linearize* ( node -- )
    drop %return , ;

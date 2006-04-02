! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays compiler-backend generic hashtables inference
kernel math namespaces sequences words ;
IN: compiler-frontend

! On PowerPC and AMD64, we use a stack discipline whereby
! stack frames are used to hold parameters. We need to compute
! the stack frame size to compile the prologue on entry to a
! word.
GENERIC: stack-reserve*

M: object stack-reserve* drop 0 ;

: stack-reserve ( node -- )
    0 swap [ stack-reserve* max ] each-node ;

DEFER: #terminal?

PREDICATE: #merge #terminal-merge node-successor #terminal? ;

UNION: #terminal POSTPONE: f #return #values #terminal-merge ;

: tail-call? ( -- ? )
    node-stack get [ node-successor ] map [ #terminal? ] all? ;

GENERIC: linearize* ( node -- next )

: linearize-child ( node -- )
    [ node@ linearize* ] iterate-nodes ;

! A map from words to linear IR.
SYMBOL: linearized

! Renamed labels. To avoid problems with labels with the same
! name in different scopes.
SYMBOL: renamed-labels

: make-linear ( word quot -- )
    [
        swap >r { } make r> linearized get set-hash
    ] with-node-iterator ; inline

: linearize-1 ( word node -- )
    swap [
        dup stack-reserve %prologue , linearize-child
    ] make-linear ;

: init-linearizer ( -- )
    H{ } clone linearized set
    H{ } clone renamed-labels set ;

: linearize ( word dataflow -- linearized )
    #! Outputs a hashtable mapping from labels to their
    #! respective linear IR.
    init-linearizer linearize-1 linearized get ;

M: node linearize* ( node -- next ) drop iterate-next ;

: linearize-call ( label -- next )
    tail-call? [
        %jump , f
    ] [
        %call , iterate-next
    ] if ;

: rename-label ( label -- label )
    <label> dup rot renamed-labels get set-hash ;

: renamed-label ( label -- label )
    renamed-labels get hash ;

: linearize-call-label ( label -- next )
    rename-label linearize-call ;

M: #label linearize* ( node -- next )
    #! We remap the IR node's label to a new label object here,
    #! to avoid problems with two IR #label nodes having the
    #! same label in different lexical scopes.
    dup node-param dup linearize-call-label >r
    renamed-label swap node-child linearize-1
    r> ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: load-literal ( obj vreg -- )
    over immediate? [ %immediate ] [ %indirect ] if , ;

GENERIC: load-value ( vreg loc value -- operand )

M: object load-value ( vreg loc value -- operand )
    drop dupd %peek , ;

M: value load-value ( vreg loc value -- operand )
    nip value-literal swap [ [ load-literal ] keep ] when* ;

: (template-inputs) ( seq template -- inputs )
    dup length reverse-slice [ <ds-loc> ] map rot 3array flip
    [ first3 load-value ] map ;

: template-inputs ( node template -- )
    flip first2 >r [ dup [ <vreg> ] when ] map
    >r node-in-d r> (template-inputs)
    r> [ set ] 2each ;

: stacks<>vregs ( values quot quot -- )
    >r >r dup reverse-slice swap length r> map r> 2each ; inline

: template-outputs ( template -- )
    [ get ] map [ <ds-loc> ] [ %replace , ] stacks<>vregs ;

: with-template ( node in out quot -- )
    [
        >r
        pick pick template-inputs
        dup rot [ length ] 2apply - %inc-d ,
        swap node set
        r> swap slip template-outputs
    ] with-scope ; inline

: intrinsic ( #call -- quot ) node-param "intrinsic" word-prop ;

: if-intrinsic ( #call -- quot )
    dup node-successor #if?
    [ node-param "if-intrinsic" word-prop ] [ drop f ] if ;

: linearize-if ( node label -- next )
    <label> dup >r >r >r node-children first2 linearize-child
    r> r> %jump-label , %label , linearize-child r> %label ,
    iterate-next ;

M: #call linearize* ( node -- next )
    dup if-intrinsic [
        >r <label> 2dup r> call
        >r node-successor r> linearize-if node-successor
    ] [
        dup intrinsic
        [ call iterate-next ] [ node-param linearize-call ] if*
    ] if* ;

M: #call-label linearize* ( node -- next )
    node-param renamed-label linearize-call ;

: ?static-branch ( node -- n )
    node-in-d first dup value?
    [ value-literal 0 1 ? ] [ drop f ] if ;

M: #if linearize* ( node -- next )
    dup ?static-branch [
        -1 %inc-d ,
        swap node-children nth linearize-child iterate-next
    ] [
        dup { { 0 "flag" } } { } [
            <label> dup "flag" get %jump-t ,
        ] with-template linearize-if
    ] if* ;

: dispatch-head ( node -- label/node )
    #! Output the jump table insn and return a list of
    #! label/branch pairs.
    dup { { 0 "n" } } { } [ "n" get %dispatch , ] with-template
    node-children [ <label> dup %target-label ,  2array ] map ;

: dispatch-body ( label/node -- )
    <label> swap [
        first2 %label , linearize-child dup %jump-label ,
    ] each %label , ;

M: #dispatch linearize* ( node -- next )
    #! The parameter is a list of nodes, each one is a branch to
    #! take in case the top of stack has that type.
    dispatch-head dispatch-body iterate-next ;

M: #return linearize* drop %return , f ;

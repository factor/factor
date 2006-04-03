! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic hashtables inference
kernel math namespaces sequences words ;

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
        0 { d-height r-height } [ set ] each-with
        swap >r { } make r> linearized get set-hash
    ] with-node-iterator ; inline

: linearize-1 ( word node -- )
    swap [
        dup stack-reserve %prologue ,
        linearize-child
        end-basic-block
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
    tail-call? [ %jump , f ] [ %call , iterate-next ] if ;

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
    renamed-label swap node-child linearize-1 r> ;

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

SYMBOL: live-d
SYMBOL: live-r

: value-dropped? ( value -- ? )
    dup value?
    over live-d get member? not
    rot live-r get member? not and
    or ;

: filter-dropped ( seq -- seq )
    [ dup value-dropped? [ drop f ] when ] map ;

: prepare-inputs ( values -- values templates )
    filter-dropped dup [ any-reg swap 2array ] map ;

: do-inputs ( node -- )
    dup node-in-d prepare-inputs rot node-in-r prepare-inputs
    template-inputs ;

: live-stores ( instack outstack -- stack )
    #! Avoid storing a value into its former position.
    dup length [ pick ?nth dupd eq? [ drop f ] when ] 2map nip ;

: shuffle-height ( node -- )
    [ dup node-out-d length swap node-in-d length - ] keep
    dup node-out-r length swap node-in-r length -
    adjust-stacks end-basic-block ;

M: #shuffle linearize* ( #shuffle -- )
    [
        0 vreg-allocator set
        dup node-in-d over node-out-d live-stores live-d set
        dup node-in-r over node-out-r live-stores live-r set
        dup do-inputs
        shuffle-height
        live-d get live-r get template-outputs
    ] with-scope iterate-next ;

: ?static-branch ( node -- n )
    node-in-d first dup value?
    [ value-literal 0 1 ? ] [ drop f ] if ;

M: #if linearize* ( node -- next )
    dup ?static-branch [
        -1 0 adjust-stacks end-basic-block
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

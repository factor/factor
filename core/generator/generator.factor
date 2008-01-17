! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes combinators cpu.architecture
effects generator.fixup generator.registers generic hashtables
inference inference.backend inference.dataflow io kernel
kernel.private layouts math namespaces optimizer prettyprint
quotations sequences system threads words vectors ;
IN: generator

SYMBOL: compile-queue
SYMBOL: compiled

: begin-compiling ( word -- )
    f swap compiled get set-at ;

: finish-compiling ( word literals relocation labels code -- )
    4array swap compiled get set-at ;

: queue-compile ( word -- )
    {
        { [ dup compiled get key? ] [ drop ] }
        { [ dup primitive? ] [ drop ] }
        { [ dup deferred? ] [ drop ] }
        { [ t ] [ dup compile-queue get set-at ] }
    } cond ;

: maybe-compile ( word -- )
    dup compiled? [ drop ] [ queue-compile ] if ;

SYMBOL: compiling-word

SYMBOL: compiling-label

! Label of current word, after prologue, makes recursion faster
SYMBOL: current-label-start

: compiled-stack-traces? ( -- ? ) 36 getenv ;

: init-generator ( -- )
    compiled-stack-traces?
    compiling-word get  f ?
    1vector literal-table set ;

: generate-1 ( word label node quot -- )
    pick begin-compiling [
        roll compiling-word set
        pick compiling-label set
        init-generator
        call
        literal-table get >array
    ] { } make fixup finish-compiling ;

GENERIC: generate-node ( node -- next )

: generate-nodes ( node -- )
    [ node@ generate-node ] iterate-nodes end-basic-block ;

: generate ( word label node -- )
    [
        init-templates
        %save-word-xt
        %prologue-later
        current-label-start define-label
        current-label-start resolve-label
        [ generate-nodes ] with-node-iterator
    ] generate-1 ;

: word-dataflow ( word -- effect dataflow )
    [
        dup "no-effect" word-prop [ no-effect ] when
        dup specialized-def over dup 2array 1array infer-quot
        finish-word
    ] with-infer ;

: intrinsics ( #call -- quot )
    node-param "intrinsics" word-prop ;

: if-intrinsics ( #call -- quot )
    node-param "if-intrinsics" word-prop ;

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

! node
M: node generate-node drop iterate-next ;

: %call ( word -- )
    dup primitive? [ %call-primitive ] [ %call-label ] if ;

: %jump ( word -- )
    {
        { [ dup compiling-label get eq? ] [
            drop current-label-start get %jump-label
        ] }
        { [ dup primitive? ] [
            %epilogue-later %jump-primitive
        ] }
        { [ t ] [
            %epilogue-later %jump-label
        ] }
    } cond ;

: generate-call ( label -- next )
    dup maybe-compile
    end-basic-block
    tail-call? [
        %jump f
    ] [
        0 frame-required
        %call
        iterate-next
    ] if ;

! #label
M: #label generate-node
    dup node-param generate-call >r
    dup #label-word over node-param rot node-child generate
    r> ;

! #if
: end-false-branch ( label -- )
    tail-call? [ %return drop ] [ %jump-label ] if ;

: generate-branch ( node -- )
    [ copy-templates generate-nodes ] with-scope ;

: generate-if ( node label -- next )
    <label> [
        >r >r node-children first2 generate-branch
        r> r> end-false-branch resolve-label
        generate-branch
        init-templates
    ] keep resolve-label iterate-next ;

M: #if generate-node
    [ <label> dup %jump-t ]
    H{ { +input+ { { f "flag" } } } }
    with-template
    generate-if ;

! #dispatch
: dispatch-branch ( node word -- label )
    gensym [
        rot [
            copy-templates
            %save-dispatch-xt
            %prologue-later
            [ generate-nodes ] with-node-iterator
        ] generate-1
    ] keep ;

: dispatch-branches ( node -- )
    node-children [
        compiling-word get dispatch-branch %dispatch-label
    ] each ;

M: #dispatch generate-node
    #! The order here is important, dispatch-branches must
    #! run after %dispatch, so that each branch gets the
    #! correct register state
    tail-call? [
        %jump-dispatch dispatch-branches
    ] [
        0 frame-required
        %call-dispatch >r dispatch-branches r> resolve-label
    ] if
    init-templates iterate-next ;

! #call
: define-intrinsics ( word intrinsics -- )
    "intrinsics" set-word-prop ;

: define-intrinsic ( word quot assoc -- )
    2array 1array define-intrinsics ;

: define-if>branch-intrinsics ( word intrinsics -- )
    "if-intrinsics" set-word-prop ;

: if>boolean-intrinsic ( quot -- )
    "true" define-label
    "end" define-label
    "true" get swap call
    f "if-scratch" get load-literal
    "end" get %jump-label
    "true" resolve-label
    t "if-scratch" get load-literal
    "end" resolve-label
    "if-scratch" get phantom-push ; inline

: define-if>boolean-intrinsics ( word intrinsics -- )
    [
        >r [ if>boolean-intrinsic ] curry r>
        { { f "if-scratch" } } +scratch+ associate union
    ] assoc-map "intrinsics" set-word-prop ;

: define-if-intrinsics ( word intrinsics -- )
    [ +input+ associate ] assoc-map
    2dup define-if>branch-intrinsics
    define-if>boolean-intrinsics ;

: define-if-intrinsic ( word quot inputs -- )
    2array 1array define-if-intrinsics ;

: do-if-intrinsic ( #call pair -- next )
    <label> [ swap do-template ] keep
    >r node-successor r> generate-if
    node-successor ;

: find-intrinsic ( #call -- pair/f )
    intrinsics find-template ;

: find-if-intrinsic ( #call -- pair/f )
    dup node-successor #if? [
        if-intrinsics find-template
    ] [
        drop f
    ] if ;

M: #call generate-node
    dup node-input-classes set-operand-classes
    dup find-if-intrinsic [
        do-if-intrinsic
    ] [
        dup find-intrinsic [
            do-template iterate-next
        ] [
            node-param generate-call
        ] ?if
    ] if* ;

! #call-label
M: #call-label generate-node node-param generate-call ;

! #push
M: #push generate-node
    node-out-d [ value-literal <constant> phantom-push ] each
    iterate-next ;

! #shuffle
M: #shuffle generate-node
    node-shuffle phantom-shuffle iterate-next ;

M: #>r generate-node
    node-in-d length
    phantom->r
    iterate-next ;

M: #r> generate-node
    node-out-d length
    phantom-r>
    iterate-next ;

! #return
M: #return generate-node drop end-basic-block %return f ;

! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes combinators cpu.architecture
effects generator.fixup generator.registers generic hashtables
inference inference.backend inference.dataflow io kernel
kernel.private layouts math namespaces optimizer
optimizer.specializers prettyprint quotations sequences system
threads words vectors ;
IN: generator

SYMBOL: compile-queue
SYMBOL: compiled

: queue-compile ( word -- )
    {
        { [ dup compiled get key? ] [ drop ] }
        { [ dup inlined-block? ] [ drop ] }
        { [ dup primitive? ] [ drop ] }
        [ dup compile-queue get set-at ]
    } cond ;

: maybe-compile ( word -- )
    dup compiled? [ drop ] [ queue-compile ] if ;

SYMBOL: compiling-word

SYMBOL: compiling-label

SYMBOL: compiling-loops

! Label of current word, after prologue, makes recursion faster
SYMBOL: current-label-start

: compiled-stack-traces? ( -- ? ) 36 getenv ;

: begin-compiling ( word label -- )
    H{ } clone compiling-loops set
    compiling-label set
    compiling-word set
    compiled-stack-traces?
    compiling-word get f ?
    1vector literal-table set
    f compiling-word get compiled get set-at ;

: finish-compiling ( literals relocation labels code -- )
    4array compiling-label get compiled get set-at ;

: with-generator ( node word label quot -- )
    [
        >r begin-compiling r>
        { } make fixup
        finish-compiling
    ] with-scope ; inline

GENERIC: generate-node ( node -- next )

: generate-nodes ( node -- )
    [ node@ generate-node ] iterate-nodes end-basic-block ;

: init-generate-nodes ( -- )
    init-templates
    %save-word-xt
    %prologue-later
    current-label-start define-label
    current-label-start resolve-label ;

: generate ( node word label -- )
    [
        init-generate-nodes
        [ generate-nodes ] with-node-iterator
    ] with-generator ;

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

! node
M: node generate-node drop iterate-next ;

: %jump ( word -- )
    dup compiling-label get eq?
    [ drop current-label-start get ] [ %epilogue-later ] if
    %jump-label ;

: generate-call ( label -- next )
    dup maybe-compile
    end-basic-block
    dup compiling-loops get at [
        %jump-label f
    ] [
        tail-call? [
            %jump f
        ] [
            0 frame-required
            %call
            iterate-next
        ] if
    ] ?if ;

! #label
M: #label generate-node
    dup node-param generate-call >r
    dup node-child over #label-word rot node-param generate
    r> ;

! #loop
: compiling-loop ( word -- )
    <label> dup resolve-label swap compiling-loops get set-at ;

M: #loop generate-node
    end-basic-block
    dup node-param compiling-loop
    node-child generate-nodes
    iterate-next ;

! #if
: end-false-branch ( label -- )
    tail-call? [ %return drop ] [ %jump-label ] if ;

: generate-branch ( node -- )
    [ copy-templates generate-nodes ] with-scope ;

: generate-if ( node label -- next )
    <label> [
        >r >r node-children first2 swap generate-branch
        r> r> end-false-branch resolve-label
        generate-branch
        init-templates
    ] keep resolve-label iterate-next ;

M: #if generate-node
    [ <label> dup %jump-f ]
    H{ { +input+ { { f "flag" } } } }
    with-template
    generate-if ;

! #dispatch
: dispatch-branch ( node word -- label )
    gensym [
        [
            copy-templates
            %save-dispatch-xt
            %prologue-later
            [ generate-nodes ] with-node-iterator
        ] with-generator
    ] keep ;

: dispatch-branches ( node -- )
    node-children [
        compiling-word get dispatch-branch
        %dispatch-label
    ] each ;

: generate-dispatch ( node -- )
    %dispatch dispatch-branches init-templates ;

M: #dispatch generate-node
    #! The order here is important, dispatch-branches must
    #! run after %dispatch, so that each branch gets the
    #! correct register state
    tail-call? [
        generate-dispatch iterate-next
    ] [
        compiling-word get gensym [
            [
                init-generate-nodes
                generate-dispatch
            ] with-generator
        ] keep generate-call
    ] if ;

! #call
: define-intrinsics ( word intrinsics -- )
    "intrinsics" set-word-prop ;

: define-intrinsic ( word quot assoc -- )
    2array 1array define-intrinsics ;

: define-if>branch-intrinsics ( word intrinsics -- )
    "if-intrinsics" set-word-prop ;

: if>boolean-intrinsic ( quot -- )
    "false" define-label
    "end" define-label
    "false" get swap call
    t "if-scratch" get load-literal
    "end" get %jump-label
    "false" resolve-label
    f "if-scratch" get load-literal
    "end" resolve-label
    "if-scratch" get phantom-push ; inline

: define-if>boolean-intrinsics ( word intrinsics -- )
    [
        >r [ if>boolean-intrinsic ] curry r>
        { { f "if-scratch" } } +scratch+ associate assoc-union
    ] assoc-map "intrinsics" set-word-prop ;

: define-if-intrinsics ( word intrinsics -- )
    [ +input+ associate ] assoc-map
    2dup define-if>branch-intrinsics
    define-if>boolean-intrinsics ;

: define-if-intrinsic ( word quot inputs -- )
    2array 1array define-if-intrinsics ;

: do-if-intrinsic ( pair -- next )
    <label> [
        swap do-template
        node> node-successor dup >node
    ] keep generate-if ;

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
    ] ?if ;

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
M: #return generate-node
    end-basic-block
    node-param compiling-loops get key?
    [ %return ] unless f ;

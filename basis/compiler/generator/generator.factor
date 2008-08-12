 ! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators
cpu.architecture effects generic hashtables io kernel
kernel.private layouts math namespaces prettyprint quotations
sequences system threads words vectors sets dequeues cursors
stack-checker.inlining
compiler.tree compiler.tree.builder compiler.tree.combinators
compiler.tree.propagation.info compiler.generator.fixup
compiler.generator.registers compiler.generator.iterator ;
IN: compiler.generator

SYMBOL: compile-queue
SYMBOL: compiled

: queue-compile ( word -- )
    {
        { [ dup "forgotten" word-prop ] [ ] }
        { [ dup compiled get key? ] [ ] }
        { [ dup inlined-block? ] [ ] }
        { [ dup primitive? ] [ ] }
        [ dup compile-queue get push-front ]
    } cond drop ;

: maybe-compile ( word -- )
    dup compiled>> [ drop ] [ queue-compile ] if ;

SYMBOL: compiling-word

SYMBOL: compiling-label

SYMBOL: compiling-loops

! Label of current word, after prologue, makes recursion faster
SYMBOL: current-label-start

: compiled-stack-traces? ( -- ? ) 59 getenv ;

: begin-compiling ( word label -- )
    H{ } clone compiling-loops set
    compiling-label set
    compiling-word set
    compiled-stack-traces?
    compiling-word get f ?
    1vector literal-table set
    f compiling-label get compiled get set-at ;

: save-machine-code ( literals relocation labels code -- )
    4array compiling-label get compiled get set-at ;

: with-generator ( node word label quot -- )
    [
        >r begin-compiling r>
        { } make fixup
        save-machine-code
    ] with-scope ; inline

GENERIC: generate-node ( node -- next )

: generate-nodes ( nodes -- )
    [ current-node generate-node ] iterate-nodes end-basic-block ;

: init-generate-nodes ( -- )
    init-templates
    %save-word-xt
    %prologue-later
    current-label-start define-label
    current-label-start resolve-label ;

: generate ( nodes word label -- )
    [
        init-generate-nodes
        [ generate-nodes ] with-node-iterator
    ] with-generator ;

: intrinsics ( #call -- quot )
    word>> "intrinsics" word-prop ;

: if-intrinsics ( #call -- quot )
    word>> "if-intrinsics" word-prop ;

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

! #recursive
: compile-recursive ( node -- )
    dup label>> id>> generate-call >r
    [ child>> ] [ label>> word>> ] [ label>> id>> ] tri generate
    r> ;

: compiling-loop ( word -- )
    <label> dup resolve-label swap compiling-loops get set-at ;

: compile-loop ( node -- )
    end-basic-block
    [ label>> id>> compiling-loop ] [ child>> generate-nodes ] bi
    iterate-next ;

M: #recursive generate-node
    dup label>> loop?>> [ compile-loop ] [ compile-recursive ] if ;

! #if
: end-false-branch ( label -- )
    tail-call? [ %return drop ] [ %jump-label ] if ;

: generate-branch ( nodes -- )
    [ copy-templates generate-nodes ] with-scope ;

: generate-if ( node label -- next )
    <label> [
        >r >r children>> first2 swap generate-branch
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
: dispatch-branch ( nodes word -- label )
    gensym [
        [
            copy-templates
            %save-dispatch-xt
            %prologue-later
            [ generate-nodes ] with-node-iterator
        ] with-generator
    ] keep ;

: dispatch-branches ( node -- )
    children>> [
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
        node> next dup >node
    ] keep generate-if ;

: find-intrinsic ( #call -- pair/f )
    intrinsics find-template ;

: find-if-intrinsic ( #call -- pair/f )
    node@ next #if? [
        if-intrinsics find-template
    ] [
        drop f
    ] if ;

M: #call generate-node
    dup node-input-infos [ class>> ] map set-operand-classes
    dup find-if-intrinsic [
        do-if-intrinsic
    ] [
        dup find-intrinsic [
            do-template iterate-next
        ] [
            word>> generate-call
        ] ?if
    ] ?if ;

! #call-recursive
M: #call-recursive generate-node label>> id>> generate-call ;

! #push
M: #push generate-node
    literal>> <constant> phantom-push iterate-next ;

! #shuffle
M: #shuffle generate-node
    shuffle-effect phantom-shuffle iterate-next ;

M: #>r generate-node
    in-d>> length
    phantom->r
    iterate-next ;

M: #r> generate-node
    out-d>> length
    phantom-r>
    iterate-next ;

! #return
M: #return generate-node
    drop end-basic-block %return f ;

M: #return-recursive generate-node
    end-basic-block
    label>> id>> compiling-loops get key?
    [ %return ] unless f ;

! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes combinators cpu.architecture
effects generator.fixup generator.registers generic hashtables
inference inference.backend inference.dataflow inference.stack
io kernel kernel.private layouts math namespaces optimizer
prettyprint quotations sequences system threads words ;
IN: generator

SYMBOL: compiled-xts

: save-xt ( word xt -- )
    swap dup unchanged-word compiled-xts get set-at ;

: compiling? ( word -- ? )
    {
        { [ dup compiled-xts get key? ] [ drop t ] }
        { [ dup word-changed? ] [ drop f ] }
        { [ t ] [ compiled? ] }
    } cond ;

SYMBOL: compiling-word

SYMBOL: compiling-label

! Label of current word, after prologue, makes recursion faster
SYMBOL: current-label-start

SYMBOL: compiled-stack-traces

t compiled-stack-traces set-global

: init-generator ( -- )
    V{ } clone literal-table set
    V{ } clone word-table set
    compiled-stack-traces get
    [ compiling-word get ] [ f ] if
    literal-table get push ;

: generate-1 ( word label node quot -- )
    pick f save-xt [
        roll compiling-word set
        pick compiling-label set
        init-generator
        %save-xt
        %prologue-later
        call
        literal-table get >array
        word-table get >array
    ] { } make fixup add-compiled-block save-xt ;

GENERIC: generate-node ( node -- next )

: generate-nodes ( node -- )
    [ node@ generate-node ] iterate-nodes end-basic-block ;

SYMBOL: profiler-prologues

: profiler-prologue ( -- )
    profiler-prologues get-global [
        compiling-word get %profiler-prologue
    ] when ;

: generate ( word label node -- )
    [
        init-templates
        profiler-prologue
        current-label-start define-label
        current-label-start resolve-label
        [ generate-nodes ] with-node-iterator
    ] generate-1 ;

: word-dataflow ( word -- dataflow )
    [
        dup "no-effect" word-prop [ no-effect ] when
        dup specialized-def over dup 2array 1array infer-quot
        finish-word
    ] with-infer nip ;

SYMBOL: compiler-hook

[ ] compiler-hook set-global

SYMBOL: compile-errors

SYMBOL: batch-mode

: compile-begins ( word -- )
    compiler-hook get call
    "quiet" get batch-mode get or [
        drop
    ] [
        "Compiling " write . flush
    ] if ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        dup compile-begins
        dup dup word-dataflow optimize generate
    ] [
        drop
    ] if ;

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
    dup (compile)
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
            [ generate-nodes ] with-node-iterator
        ] generate-1
    ] keep ;

: dispatch-branches ( node -- syms )
    node-children
    [ compiling-word get dispatch-branch ] map
    word-table get push-all ;

: %dispatch ( word-table# -- )
    tail-call? [
        %jump-dispatch
    ] [
        0 frame-required
        %call-dispatch
    ] if ;

M: #dispatch generate-node
    word-table get length %dispatch
    dispatch-branches init-templates iterate-next ;

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
        first2
        >r [ if>boolean-intrinsic ] curry r>
        { { f "if-scratch" } } +scratch+ associate union
        2array
    ] map "intrinsics" set-word-prop ;

: define-if-intrinsics ( word intrinsics -- )
    [ +input+ associate ] assoc-map
    2dup define-if>branch-intrinsics
    define-if>boolean-intrinsics ;

: define-if-intrinsic ( word quot inputs -- )
    2array 1array define-if-intrinsics ;

: do-intrinsic ( pair -- ) first2 with-template ;

: do-if-intrinsic ( #call pair -- next )
    <label> [ swap do-intrinsic ] keep
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
    dup find-if-intrinsic [
        do-if-intrinsic
    ] [
        dup find-intrinsic [
            do-intrinsic iterate-next
        ] [
            node-param generate-call
        ] ?if
    ] if* ;

! #call-label
M: #call-label generate-node node-param generate-call ;

! #push
UNION: immediate fixnum POSTPONE: f ;

M: #push generate-node
    node-out-d [ phantom-push ] each iterate-next ;

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

! These constants must match vm/memory.h
: card-bits 6 ;
: card-mark HEX: 40 HEX: 80 bitor ;

! These constants must match vm/layouts.h
: header-offset object tag-number neg ;
: float-offset 8 float tag-number - ;
: string-offset 3 cells object tag-number - ;
: profile-count-offset 7 cells object tag-number - ;
: byte-array-offset 2 cells object tag-number - ;
: alien-offset 3 cells object tag-number - ;
: tuple-class-offset 2 cells tuple tag-number - ;
: class-hash-offset cell object tag-number - ;

: operand-immediate? ( operand -- ? )
    operand-class immediate class< ;

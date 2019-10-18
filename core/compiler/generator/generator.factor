! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
DEFER: (compile)

IN: generator
USING: arrays errors generic assocs hashtables inference
kernel kernel-internals math namespaces sequences words
quotations compiler ;

SYMBOL: compiled-xts

: save-xt ( word xt -- )
    swap dup unchanged-word compiled-xts get set-at ;

: compiling? ( word -- ? )
    {
        { [ dup compiled-xts get key? ] [ drop t ] }
        { [ dup word-changed? ] [ drop f ] }
        { [ t ] [ compiled? ] }
    } cond ;

: with-compiler ( quot -- )
    [
        H{ } clone compiled-xts set
        call
        compiled-xts get >alist finalize-compile
    ] with-scope ;

! The word being compiled
SYMBOL: compiling

: init-generator ( word -- )
    #! The first entry in the literal table is the word itself,
    #! this is for compiled call traces
    V{ } clone literal-table set 
    V{ } clone word-table set
    dup compiling set literal-table get push ;

: generate-1 ( word label node quot -- )
    #! Generate the code, then dump three vectors to pass to
    #! add-compiled-block.
    pick f save-xt [
        roll init-generator
        %prologue-later
        call
        literal-table get
        word-table get
    ] V{ } make fixup code-format add-compiled-block save-xt ;

GENERIC: generate-node ( node -- next )

: generate-nodes ( node -- )
    [ node@ generate-node ] iterate-nodes end-basic-block ;

: generate ( word label node -- )
    [
        init-templates
        [ generate-nodes ] with-node-iterator
    ] generate-1 ;

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

! #label
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
    [ compiling get dispatch-branch ] map
    word-table get push-all ;

: %dispatch ( word-table# -- )
    tail-call? [
        %jump-dispatch
    ] [
        0 frame-required
        %call-dispatch
    ] if ;

M: #dispatch generate-node
    #! The parameter is a list of nodes, each one is a branch to
    #! take in case the top of stack has that type.
    word-table get length %dispatch
    dispatch-branches init-templates iterate-next ;

! #call
: define-intrinsics ( word intrinsics -- )
    #! intrinsics is a sequence of { hash quot }
    "intrinsics" set-word-prop ;

: define-intrinsic ( word quot hash -- )
    2array 1array define-intrinsics ;

: define-if>branch-intrinsics ( word intrinsics -- )
    #! intrinsics is a sequence of { hash quot }
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
    "if-scratch" get phantom-d get phantom-push ; inline

: define-if>boolean-intrinsics ( word intrinsics -- )
    #! intrinsics is a sequence of { hash quot }
    [
        first2
        >r [ if>boolean-intrinsic ] curry r>
        { { f "if-scratch" } } +scratch+ associate union
        2array
    ] map "intrinsics" set-word-prop ;

: define-if-intrinsics ( word intrinsics -- )
    #! intrinsics is a sequence of { quot inputs }
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
    node-out-d phantom-d get phantom-append iterate-next ;

! #shuffle
: phantom-shuffle-input ( n phantom -- seq )
    2dup length <= [
        cut-phantom
    ] [
        [ phantom-locs ] keep [ length head-slice* ] keep
        [ append ] keep delete-all
    ] if ;

: adjust-shuffle ( shuffle -- )
    effect-in length neg phantom-d get adjust-phantom ;

: phantom-shuffle ( shuffle -- )
    [
        effect-in length phantom-d get phantom-shuffle-input
    ] keep
    [ shuffle* ] keep adjust-shuffle
    phantom-d get phantom-append ;

M: #shuffle generate-node
    node-shuffle phantom-shuffle iterate-next ;

: generate->r/r>
    { } guess-vregs ensure-vregs
    1 over phantom-shuffle-input
    -1 rot adjust-phantom
    swap phantom-append ;

M: #>r generate-node
    node-in-d empty? [
        phantom-r get phantom-d get { { f } } { }
        generate->r/r>
    ] unless
    iterate-next ;

M: #r> generate-node
    node-out-d empty? [
        phantom-d get phantom-r get { } { { f } }
        generate->r/r>
    ] unless
    iterate-next ;

! #return
M: #return generate-node drop end-basic-block %return f ;

! These constants must match vm/memory.h
: card-bits 7 ;
: card-mark HEX: 80 ;

! These constants must match vm/layouts.h
: float-offset 8 float tag-number - ;
: string-offset 3 cells object tag-number - ;

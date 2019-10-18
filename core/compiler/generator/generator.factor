! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: arrays errors generic hashtables inference
kernel kernel-internals math namespaces sequences words ;

! The word being compiled
SYMBOL: compiling

: generate-code ( node quot -- )
    over stack-frame-size \ stack-frame-size set
    %prologue call ; inline

: init-generator ( word -- )
    #! The first entry in the literal table is the word itself,
    #! this is for compiled call traces
    dup compiling set
    V{ } clone relocation-table set
    V{ } clone literal-table set
    V{ } clone label-table set 
    V{ } clone word-table set
    literal-table get push ;

: generate-1 ( word label node quot -- )
    #! Generate the code, then dump three vectors to pass to
    #! add-compiled-block.
    pick f save-xt [
        roll init-generator
        generate-code
        generate-labels
        relocation-table get
        literal-table get
        word-table get
    ] V{ } make code-format add-compiled-block save-xt ;

GENERIC: generate-node ( node -- next )

: generate-nodes ( node -- )
    [ node@ generate-node ] iterate-nodes end-basic-block ;

: generate ( word label node -- )
    [
        init-templates
        [ generate-nodes ] with-node-iterator
    ] generate-1 ;

! node
M: node generate-node drop iterate-next ;

! #label
: generate-call ( label -- next )
    end-basic-block
    tail-call? [ %jump f ] [ %call iterate-next ] if ;

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
    word-table get nappend ;

: %dispatch ( word-table# -- )
    tail-call? [ %jump-dispatch ] [ %call-dispatch ] if ;

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
    "if-scratch" get phantom-d get phantom-push
    compute-free-vregs ; inline

: define-if>boolean-intrinsics ( word intrinsics -- )
    #! intrinsics is a sequence of { hash quot }
    [
        first2
        >r [ if>boolean-intrinsic ] curry r>
        { { f "if-scratch" } } +scratch+ associate hash-union
        2array
    ] map "intrinsics" set-word-prop ;

: define-if-intrinsics ( word intrinsics -- )
    #! intrinsics is a sequence of { quot inputs }
    [ first2 +input+ associate 2array ] map
    2dup define-if>branch-intrinsics
    define-if>boolean-intrinsics ;

: define-if-intrinsic ( word quot inputs -- )
    2array 1array define-if-intrinsics ;

: do-if-intrinsic ( #call -- next )
    dup node-successor
    <label> [ rot if-intrinsics apply-template ] keep
    generate-if node-successor ;

: do-intrinsic ( #call -- ) intrinsics apply-template ;

M: #call generate-node
    {
        { [ dup do-if-intrinsic? ] [ do-if-intrinsic ] }
        { [ dup intrinsics ] [ do-intrinsic iterate-next ] }
        { [ t ] [ node-param generate-call ] }
    } cond ;

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
    dup effect-in 0 additional-vregs 0 ensure-vregs
    [
        effect-in length phantom-d get phantom-shuffle-input
    ] keep
    [ shuffle* ] keep adjust-shuffle
    phantom-d get phantom-append ;

M: #shuffle generate-node
    node-shuffle phantom-shuffle iterate-next ;

M: #>r generate-node
    node-in-d empty? [
        1 0 additional-vregs 0 ensure-vregs
        1 phantom-d get phantom-shuffle-input
        -1 phantom-d get adjust-phantom
        phantom-r get phantom-append
    ] unless
    iterate-next ;

M: #r> generate-node
    node-out-d empty? [
        0 1 additional-vregs 0 ensure-vregs
        1 phantom-r get phantom-shuffle-input
        -1 phantom-r get adjust-phantom
        phantom-d get phantom-append
    ] unless
    iterate-next ;

! #return
M: #return generate-node drop end-basic-block %return f ;

! These constants must match vm/memory.h
: card-bits 7 ;
: card-mark HEX: 80 ;

! These constants must match vm/layouts.h
: float-offset 8 float-tag - ;
: string-offset 3 cells object-tag - ;

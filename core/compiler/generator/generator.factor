! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays assembler errors generic hashtables inference
kernel kernel-internals math namespaces sequences words ;

GENERIC: stack-reserve* ( node -- n )

M: object stack-reserve* drop 0 ;

: stack-reserve ( node -- n )
    0 swap [ stack-reserve* max ] each-node ;

: intrinsic ( #call -- quot )
    node-param "intrinsic" word-prop ;

: if-intrinsic ( #call -- quot )
    node-param "if-intrinsic" word-prop ;

DEFER: #terminal?

PREDICATE: #merge #terminal-merge node-successor #terminal? ;

PREDICATE: #values #terminal-values node-successor #terminal? ;

PREDICATE: #call #terminal-call
    dup node-successor #if?
    over node-successor node-successor #terminal? and
    swap if-intrinsic and ;

UNION: #terminal
    POSTPONE: f #return #terminal-values #terminal-merge ;

: tail-call? ( -- ? )
    node-stack get [
        dup #terminal-call? swap node-successor #terminal? or
    ] all? ;

: generate-code ( node quot -- )
    over stack-reserve %prologue call ; inline

: init-generator ( word -- )
    #! The first entry in the literal table is the word itself,
    #! this is for compiled call traces
    V{ } clone relocation-table set
    V{ } clone literal-table set
    V{ } clone label-table set 
    V{ } clone word-table set
    literal-table get push ;

: generate-1 ( word node quot -- )
    #! Generate the code, then dump three vectors to pass to
    #! add-compiled-block.
    pick f save-xt [
        pick init-generator
        init-templates
        generate-code
        generate-labels
        relocation-table get
        literal-table get
        word-table get
    ] V{ } make code-format add-compiled-block save-xt ;

GENERIC: generate-node ( node -- next )

: generate-nodes ( node -- )
    [ node@ generate-node ] iterate-nodes end-basic-block ;

: generate-branch ( node -- )
    [ generate-nodes ] keep-templates ;

: generate ( word node -- )
    [ [ generate-nodes ] with-node-iterator ] generate-1 ;

! node
M: node generate-node drop iterate-next ;

! #label
: generate-call ( label -- next )
    end-basic-block
    tail-call? [ %jump f ] [ %call iterate-next ] if ;

M: #label generate-node
    dup node-param dup generate-call >r
    swap node-child generate r> ;

! #if
: end-false-branch ( label -- )
    tail-call? [ %return drop ] [ %jump-label ] if ;

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

! #call
: [with-template] ( quot template -- quot )
    \ with-template 3array >quotation ;

: define-intrinsic ( word quot template -- )
    [with-template] "intrinsic" set-word-prop ;

: define-if>branch-intrinsic ( word quot inputs -- )
    +input+ associate
    [with-template] "if-intrinsic" set-word-prop ;

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

: define-if>boolean-intrinsic ( word quot inputs -- )
    +input+ associate
    { { f "if-scratch" } } +scratch+ associate
    hash-union
    >r [ if>boolean-intrinsic ] curry r>
    [with-template] "intrinsic" set-word-prop ;

: define-if-intrinsic ( word quot inputs -- )
    3dup define-if>branch-intrinsic define-if>boolean-intrinsic ;

: do-if-intrinsic ( node -- next )
    dup node-successor dup #if? [
        <label> [ rot if-intrinsic call ] keep
        generate-if node-successor
    ] [
        drop intrinsic call iterate-next
    ] if ;

M: #call generate-node
    {
        { [ dup if-intrinsic ] [ do-if-intrinsic ] }
        { [ dup intrinsic ] [ intrinsic call iterate-next ] }
        { [ t ] [ node-param generate-call ] }
    } cond ;

! #call-label
M: #call-label generate-node
    node-param generate-call ;

! #dispatch
: dispatch-head ( node -- label/node )
    #! Return a list of label/branch pairs.
    node-children [ <label> dup %target 2array ] map ;

: dispatch-body ( label/node -- )
    <label> swap [
        first2 resolve-label generate-branch
        dup %jump-label
    ] each resolve-label init-templates ;

M: #dispatch generate-node
    #! The parameter is a list of nodes, each one is a branch to
    #! take in case the top of stack has that type.
    %dispatch dispatch-head dispatch-body iterate-next ;

! #push
UNION: immediate fixnum POSTPONE: f ;

: generate-push ( node -- )
    >#push<
    dup length ?fp-scratch + 0 ensure-vregs
    [ f spec>vreg [ load-literal ] keep ] map
    phantom-d get phantom-append ;

M: #push generate-node
    generate-push iterate-next ;

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
    drop
    1 0 additional-vregs 0 ensure-vregs
    1 phantom-d get phantom-shuffle-input
    -1 phantom-d get adjust-phantom
    phantom-r get phantom-append
    iterate-next ;

M: #r> generate-node
    drop
    0 1 additional-vregs 0 ensure-vregs
    1 phantom-r get phantom-shuffle-input
    -1 phantom-r get adjust-phantom
    phantom-d get phantom-append
    iterate-next ;

! #return
M: #return generate-node drop end-basic-block %return f ;

! These constants must match vm/memory.h
: card-bits 7 ;
: card-mark HEX: 80 ;

! These constants must match vm/layouts.h
: float-offset 8 float-tag - ;
: string-offset 3 cells object-tag - ;

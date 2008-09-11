 ! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators hashtables kernel
math fry namespaces make sequences words stack-checker.inlining
compiler.tree
compiler.tree.builder
compiler.tree.combinators
compiler.tree.propagation.info
compiler.cfg
compiler.cfg.stacks
compiler.cfg.templates
compiler.cfg.iterator
compiler.alien
compiler.instructions
compiler.registers ;
IN: compiler.cfg.builder

! Convert tree SSA IR to CFG (not quite SSA yet) IR.

: set-basic-block ( basic-block -- )
    [ basic-block set ] [ instructions>> building set ] bi ;

: begin-basic-block ( -- )
    <basic-block> basic-block get [
        dupd successors>> push
    ] when*
    set-basic-block ;

: end-basic-block ( -- )
    building off
    basic-block off ;

: stop-iterating ( -- next ) end-basic-block f ;

USE: qualified
FROM: compiler.generator.registers => +input+   ;
FROM: compiler.generator.registers => +output+  ;
FROM: compiler.generator.registers => +scratch+ ;
FROM: compiler.generator.registers => +clobber+ ;

SYMBOL: procedures

SYMBOL: current-word

SYMBOL: current-label

SYMBOL: loops

! Basic block after prologue, makes recursion faster
SYMBOL: current-label-start

: add-procedure ( -- )
    basic-block get current-word get current-label get
    <cfg> procedures get push ;

: begin-procedure ( word label -- )
    end-basic-block
    begin-basic-block
    H{ } clone loops set
    current-label set
    current-word set
    add-procedure ;

: with-cfg-builder ( nodes word label quot -- )
    '[ begin-procedure @ ] with-scope ; inline

GENERIC: emit-node ( node -- next )

: check-basic-block ( node -- node' )
    basic-block get [ drop f ] unless ; inline

: emit-nodes ( nodes -- )
    [ current-node emit-node check-basic-block ] iterate-nodes
    finalize-phantoms ;

: remember-loop ( label -- )
    basic-block get swap loops get set-at ;

: begin-word ( -- )
    #! We store the basic block after the prologue as a loop
    #! labelled by the current word, so that self-recursive
    #! calls can skip an epilogue/prologue.
    init-phantoms
    %prologue
    %branch
    begin-basic-block
    current-label get remember-loop ;

: (build-cfg) ( nodes word label -- )
    [
        begin-word
        [ emit-nodes ] with-node-iterator
    ] with-cfg-builder ;

: build-cfg ( nodes word label -- procedures )
    V{ } clone [
        procedures [
            (build-cfg)
        ] with-variable
    ] keep ;

: if-intrinsics ( #call -- quot )
    word>> "if-intrinsics" word-prop ;

: local-recursive-call ( basic-block -- next )
    %branch
    basic-block get successors>> push
    stop-iterating ;

: emit-call ( word -- next )
    finalize-phantoms
    {
        { [ tail-call? not ] [ 0 %frame-required %call iterate-next ] }
        { [ dup loops get key? ] [ loops get at local-recursive-call ] }
        [ %epilogue %jump stop-iterating ]
    } cond ;

! #recursive
: compile-recursive ( node -- next )
    [ label>> id>> emit-call ]
    [ [ child>> ] [ label>> word>> ] [ label>> id>> ] tri (build-cfg) ] bi ;

: compile-loop ( node -- next )
    finalize-phantoms
    begin-basic-block
    [ label>> id>> remember-loop ] [ child>> emit-nodes ] bi
    iterate-next ;

M: #recursive emit-node
    dup label>> loop?>> [ compile-loop ] [ compile-recursive ] if ;

! #if
: emit-branch ( nodes -- final-bb )
    [
        begin-basic-block copy-phantoms
        emit-nodes
        basic-block get dup [ %branch ] when
    ] with-scope ;

: emit-if ( node -- next )
    children>> [ emit-branch ] map
    end-basic-block
    begin-basic-block
    basic-block get '[ [ _ swap successors>> push ] when* ] each
    init-phantoms
    iterate-next ;

M: #if emit-node
    { { f "flag" } } lazy-load first %branch-t
    emit-if ;

! #dispatch
: dispatch-branch ( nodes word -- label )
    gensym [
        [
            copy-phantoms
            %prologue
            [ emit-nodes ] with-node-iterator
            %epilogue
            %return
        ] with-cfg-builder
    ] keep ;

: dispatch-branches ( node -- )
    children>> [
        current-word get dispatch-branch
        %dispatch-label
    ] each ;

: emit-dispatch ( node -- )
    %dispatch dispatch-branches init-phantoms ;

M: #dispatch emit-node
    #! The order here is important, dispatch-branches must
    #! run after %dispatch, so that each branch gets the
    #! correct register state
    tail-call? [
        emit-dispatch iterate-next
    ] [
        current-word get gensym [
            [
                begin-word
                emit-dispatch
            ] with-cfg-builder
        ] keep emit-call
    ] if ;

! #call
: define-intrinsics ( word intrinsics -- )
    "intrinsics" set-word-prop ;

: define-intrinsic ( word quot assoc -- )
    2array 1array define-intrinsics ;

: define-if-intrinsics ( word intrinsics -- )
    [ +input+ associate ] assoc-map
    "if-intrinsics" set-word-prop ;

: define-if-intrinsic ( word quot inputs -- )
    2array 1array define-if-intrinsics ;

: find-intrinsic ( #call -- pair/f )
    word>> "intrinsics" word-prop find-template ;

: find-boolean-intrinsic ( #call -- pair/f )
    word>> "if-intrinsics" word-prop find-template ;

: find-if-intrinsic ( #call -- pair/f )
    node@ {
        { [ dup length 2 < ] [ 2drop f ] }
        { [ dup second #if? ] [ drop find-boolean-intrinsic ] }
        [ 2drop f ]
    } cond ;

: do-if-intrinsic ( pair -- next )
    [ %if-intrinsic ] apply-template skip-next emit-if ;

: do-boolean-intrinsic ( pair -- next )
    [
        f alloc-vreg [ %boolean-intrinsic ] keep phantom-push
    ] apply-template iterate-next ;

: do-intrinsic ( pair -- next )
    [ %intrinsic ] apply-template iterate-next ;

: setup-operand-classes ( #call -- )
    node-input-infos [ class>> ] map set-operand-classes ;

M: #call emit-node
    dup setup-operand-classes
    dup find-if-intrinsic [ do-if-intrinsic ] [
        dup find-boolean-intrinsic [ do-boolean-intrinsic ] [
            dup find-intrinsic [ do-intrinsic ] [
                word>> emit-call
            ] ?if
        ] ?if
    ] ?if ;

! #call-recursive
M: #call-recursive emit-node label>> id>> emit-call ;

! #push
M: #push emit-node
    literal>> <constant> phantom-push iterate-next ;

! #shuffle
M: #shuffle emit-node
    shuffle-effect phantom-shuffle iterate-next ;

M: #>r emit-node
    [ in-d>> length ] [ out-r>> empty? ] bi
    [ phantom-drop ] [ phantom->r ] if
    iterate-next ;

M: #r> emit-node
    [ in-r>> length ] [ out-d>> empty? ] bi
    [ phantom-rdrop ] [ phantom-r> ] if
    iterate-next ;

! #return
M: #return emit-node
    drop finalize-phantoms %epilogue %return f ;

M: #return-recursive emit-node
    finalize-phantoms
    label>> id>> loops get key?
    [ %epilogue %return ] unless f ;

! #terminate
M: #terminate emit-node drop stop-iterating ;

! FFI
M: #alien-invoke emit-node
    params>>
    [ alien-invoke-frame %frame-required ]
    [ %alien-invoke iterate-next ]
    bi ;

M: #alien-indirect emit-node
    params>>
    [ alien-invoke-frame %frame-required ]
    [ %alien-indirect iterate-next ]
    bi ;

M: #alien-callback emit-node
    params>> dup xt>> dup
    [ init-phantoms %alien-callback ] with-cfg-builder
    iterate-next ;

! No-op nodes
M: #introduce emit-node drop iterate-next ;

M: #copy emit-node drop iterate-next ;

M: #enter-recursive emit-node drop iterate-next ;

M: #phi emit-node drop iterate-next ;

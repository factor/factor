 ! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators hashtables kernel
math fry namespaces make sequences words byte-arrays
layouts alien.c-types alien.structs
stack-checker.inlining cpu.architecture
compiler.tree
compiler.tree.builder
compiler.tree.combinators
compiler.tree.propagation.info
compiler.cfg
compiler.cfg.iterator
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.builder.hats
compiler.cfg.builder.calls
compiler.cfg.builder.stacks
compiler.alien ;
IN: compiler.cfg.builder

! Convert tree SSA IR to CFG SSA IR.

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

SYMBOL: procedures
SYMBOL: current-word
SYMBOL: current-label
SYMBOL: loops
SYMBOL: first-basic-block

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

: begin-word ( -- )
    #! We store the basic block after the prologue as a loop
    #! labelled by the current word, so that self-recursive
    #! calls can skip an epilogue/prologue.
    init-phantoms
    ##prologue
    ##branch
    begin-basic-block
    basic-block get first-basic-block set ;

: (build-cfg) ( nodes word label -- )
    [
        begin-word
        V{ } clone node-stack set
        emit-nodes
    ] with-cfg-builder ;

: build-cfg ( nodes word -- procedures )
    V{ } clone [
        procedures [
            dup (build-cfg)
        ] with-variable
    ] keep ;

: local-recursive-call ( basic-block -- next )
    ##branch
    basic-block get successors>> push
    stop-iterating ;

: emit-call ( word -- next )
    finalize-phantoms
    {
        { [ dup loops get key? ] [ loops get at local-recursive-call ] }
        { [ tail-call? not ] [ ##simple-stack-frame ##call iterate-next ] }
        { [ dup current-label get eq? ] [ drop first-basic-block get local-recursive-call ] }
        [ ##epilogue ##jump stop-iterating ]
    } cond ;

! #recursive
: compile-recursive ( node -- next )
    [ label>> id>> emit-call ]
    [ [ child>> ] [ label>> word>> ] [ label>> id>> ] tri (build-cfg) ] bi ;

: remember-loop ( label -- )
    basic-block get swap loops get set-at ;

: compile-loop ( node -- next )
    finalize-phantoms
    begin-basic-block
    [ label>> id>> remember-loop ] [ child>> emit-nodes ] bi
    iterate-next ;

M: #recursive emit-node
    dup label>> loop?>> [ compile-loop ] [ compile-recursive ] if ;

! #if
: emit-branch ( obj -- final-bb )
    [
        begin-basic-block copy-phantoms
        emit-nodes
        basic-block get dup [ ##branch ] when
    ] with-scope ;

: emit-if ( node -- )
    children>>  [ emit-branch ] map
    end-basic-block
    begin-basic-block
    basic-block get '[ [ _ swap successors>> push ] when* ] each
    init-phantoms ;

: ##branch-t ( vreg -- )
    \ f tag-number cc/= ##compare-imm-branch ;

M: #if emit-node
    phantom-pop ##branch-t emit-if iterate-next ;

! #dispatch
: dispatch-branch ( nodes word -- label )
    gensym [
        [
            V{ } clone node-stack set
            init-phantoms
            ##prologue
            emit-nodes
            basic-block get [
                ##epilogue
                ##return
                end-basic-block
            ] when
        ] with-cfg-builder
    ] keep ;

: dispatch-branches ( node -- )
    children>> [
        current-word get dispatch-branch
        ##dispatch-label
    ] each ;

: emit-dispatch ( node -- )
    phantom-pop int-regs next-vreg
    [ finalize-phantoms ##epilogue ] 2dip
    [ ^^offset>slot ] dip
    ##dispatch
    dispatch-branches init-phantoms ;

: <dispatch-block> ( -- word )
    gensym dup t "inlined-block" set-word-prop ;

M: #dispatch emit-node
    tail-call? [
        emit-dispatch stop-iterating
    ] [
        current-word get <dispatch-block> [
            [
                begin-word
                emit-dispatch
            ] with-cfg-builder
        ] keep emit-call
    ] if ;

! #call
M: #call emit-node
    dup word>> dup "intrinsic" word-prop
    [ emit-intrinsic iterate-next ] [ nip emit-call ] if ;

! #call-recursive
M: #call-recursive emit-node label>> id>> emit-call ;

! #push
M: #push emit-node
    literal>> ^^load-literal phantom-push iterate-next ;

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
    drop finalize-phantoms ##epilogue ##return stop-iterating ;

M: #return-recursive emit-node
    finalize-phantoms
    label>> id>> loops get key?
    [ iterate-next ] [ ##epilogue ##return stop-iterating ] if ;

! #terminate
M: #terminate emit-node
    drop finalize-phantoms stop-iterating ;

! FFI
: return-size ( ctype -- n )
    #! Amount of space we reserve for a return value.
    {
        { [ dup c-struct? not ] [ drop 0 ] }
        { [ dup large-struct? not ] [ drop 2 cells ] }
        [ heap-size ]
    } cond ;

: <alien-stack-frame> ( params -- stack-frame )
    stack-frame new
        swap
        [ return>> return-size >>return ]
        [ alien-parameters parameter-sizes drop >>params ] bi ;

: alien-stack-frame ( params -- )
    <alien-stack-frame> ##stack-frame ;

: emit-alien-node ( node quot -- next )
    finalize-phantoms
    [ params>> ] dip [ drop alien-stack-frame ] [ call ] 2bi
    iterate-next ; inline

M: #alien-invoke emit-node
    [ ##alien-invoke ] emit-alien-node ;

M: #alien-indirect emit-node
    [ ##alien-indirect ] emit-alien-node ;

M: #alien-callback emit-node
    dup params>> xt>> dup
    [
        init-phantoms
        ##prologue
        dup [ ##alien-callback ] emit-alien-node drop
        ##epilogue
        params>> ##callback-return
    ] with-cfg-builder
    iterate-next ;

! No-op nodes
M: #introduce emit-node drop iterate-next ;

M: #copy emit-node drop iterate-next ;

M: #enter-recursive emit-node drop iterate-next ;

M: #phi emit-node drop iterate-next ;

 ! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators hashtables kernel
math fry namespaces make sequences words byte-arrays
locals layouts alien.c-types alien.structs
stack-checker.inlining
cpu.architecture
compiler.intrinsics
compiler.tree
compiler.tree.builder
compiler.tree.combinators
compiler.tree.propagation.info
compiler.cfg
compiler.cfg.stacks
compiler.cfg.templates
compiler.cfg.iterator
compiler.cfg.instructions
compiler.cfg.registers
compiler.alien ;
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
    ##prologue
    ##branch
    begin-basic-block
    current-label get remember-loop ;

: (build-cfg) ( nodes word label -- )
    [
        begin-word
        [ emit-nodes ] with-node-iterator
    ] with-cfg-builder ;

: build-cfg ( nodes word -- procedures )
    V{ } clone [
        procedures [
            dup (build-cfg)
        ] with-variable
    ] keep ;

SYMBOL: +intrinsics+
SYMBOL: +if-intrinsics+

: if-intrinsics ( #call -- quot )
    word>> +if-intrinsics+ word-prop ;

: local-recursive-call ( basic-block -- next )
    ##branch
    basic-block get successors>> push
    stop-iterating ;

: emit-call ( word -- next )
    finalize-phantoms
    {
        { [ tail-call? not ] [ ##simple-stack-frame ##call iterate-next ] }
        { [ dup loops get key? ] [ loops get at local-recursive-call ] }
        [ ##epilogue ##jump stop-iterating ]
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
: emit-branch ( obj quot -- final-bb )
    '[
        begin-basic-block copy-phantoms
        @
        basic-block get dup [ ##branch ] when
    ] with-scope ;

: emit-branches ( seq quot -- )
    '[ _ emit-branch ] map
    end-basic-block
    begin-basic-block
    basic-block get '[ [ _ swap successors>> push ] when* ] each
    init-phantoms ;

: emit-if ( node -- next )
    children>> [ emit-nodes ] emit-branches ;

M: #if emit-node
    phantom-pop ##branch-t emit-if iterate-next ;

! #dispatch
: dispatch-branch ( nodes word -- label )
    #! The order here is important, dispatch-branches must
    #! run after ##dispatch, so that each branch gets the
    #! correct register state
    gensym [
        [
            init-phantoms
            ##prologue
            [ emit-nodes ] with-node-iterator
        ] with-cfg-builder
    ] keep ;

: dispatch-branches ( node -- )
    children>> [
        current-word get dispatch-branch
        ##dispatch-label
    ] each ;

: emit-dispatch ( node -- )
    phantom-pop int-regs next-vreg
    [ finalize-phantoms ##epilogue ] 2dip ##dispatch
    dispatch-branches init-phantoms ;

M: #dispatch emit-node
    tail-call? [
        emit-dispatch stop-iterating
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
    +intrinsics+ set-word-prop ;

: define-intrinsic ( word quot assoc -- )
    2array 1array define-intrinsics ;

: define-if-intrinsics ( word intrinsics -- )
    [ template new swap >>input ] assoc-map
    +if-intrinsics+ set-word-prop ;

: define-if-intrinsic ( word quot inputs -- )
    2array 1array define-if-intrinsics ;

: find-intrinsic ( #call -- pair/f )
    word>> +intrinsics+ word-prop find-template ;

: find-boolean-intrinsic ( #call -- pair/f )
    word>> +if-intrinsics+ word-prop find-template ;

: find-if-intrinsic ( #call -- pair/f )
    node@ {
        { [ dup length 2 < ] [ 2drop f ] }
        { [ dup second #if? ] [ drop find-boolean-intrinsic ] }
        [ 2drop f ]
    } cond ;

: do-if-intrinsic ( pair -- next )
    [ ##if-intrinsic ] apply-template skip-next emit-if
    iterate-next ;

: do-boolean-intrinsic ( pair -- next )
    [ ##if-intrinsic ] apply-template
    { t f } [
        <constant> phantom-push finalize-phantoms
    ] emit-branches
    iterate-next ;

: do-intrinsic ( pair -- next )
    [ ##intrinsic ] apply-template iterate-next ;

: setup-value-classes ( #call -- )
    node-input-infos [ class>> ] map set-value-classes ;

{
    (tuple) (array) (byte-array)
    (complex) (ratio) (wrapper)
    (write-barrier)
} [ t "intrinsic" set-word-prop ] each

: allot-size ( -- n )
    1 phantom-datastack get phantom-input first value>> ;

:: emit-allot ( size type tag -- )
    int-regs next-vreg
    dup fresh-object
    dup size type tag int-regs next-vreg ##allot
    type tagged boa phantom-push ;

: emit-write-barrier ( -- )
    phantom-pop dup >vreg fresh-object? [ drop ] [
        int-regs next-vreg ##write-barrier
    ] if ;

: emit-intrinsic ( word -- next )
    {
        { \ (tuple) [ allot-size 2 + cells tuple tuple emit-allot ] }
        { \ (array) [ allot-size 2 + cells array object emit-allot ] }
        { \ (byte-array) [ allot-size 2 cells + byte-array object emit-allot ] }
        { \ (complex) [ 3 cells complex complex emit-allot ] }
        { \ (ratio) [ 3 cells ratio ratio emit-allot ] }
        { \ (wrapper) [ 2 cells wrapper object emit-allot ] }
        { \ (write-barrier) [ emit-write-barrier ] }
    } case
    iterate-next ;

M: #call emit-node
    dup setup-value-classes
    dup find-if-intrinsic [ do-if-intrinsic ] [
        dup find-boolean-intrinsic [ do-boolean-intrinsic ] [
            dup find-intrinsic [ do-intrinsic ] [
                word>> dup "intrinsic" word-prop
                [ emit-intrinsic ] [ emit-call ] if
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
    drop finalize-phantoms ##epilogue ##return stop-iterating ;

M: #return-recursive emit-node
    finalize-phantoms
    label>> id>> loops get key?
    [ ##epilogue ##return ] unless stop-iterating ;

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
        [ alien-parameters parameter-sizes drop >>params ] bi
        dup [ params>> ] [ return>> ] bi + >>size ;

: alien-stack-frame ( node -- )
    params>> <alien-stack-frame> ##stack-frame ;

: emit-alien-node ( node quot -- next )
    [ drop alien-stack-frame ]
    [ [ params>> ] dip call ] 2bi
    iterate-next ; inline

M: #alien-invoke emit-node
    [ ##alien-invoke ] emit-alien-node ;

M: #alien-indirect emit-node
    [ ##alien-indirect ] emit-alien-node ;

M: #alien-callback emit-node
    params>> dup xt>> dup
    [
        init-phantoms
        [ ##alien-callback ] emit-alien-node drop
    ] with-cfg-builder
    iterate-next ;

! No-op nodes
M: #introduce emit-node drop iterate-next ;

M: #copy emit-node drop iterate-next ;

M: #enter-recursive emit-node drop iterate-next ;

M: #phi emit-node drop iterate-next ;

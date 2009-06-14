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
compiler.cfg.hats
compiler.cfg.stacks
compiler.cfg.iterator
compiler.cfg.utilities
compiler.cfg.registers
compiler.cfg.intrinsics
compiler.cfg.stack-frame
compiler.cfg.instructions
compiler.alien ;
IN: compiler.cfg.builder

! Convert tree SSA IR to CFG SSA IR.

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
    [ current-node emit-node check-basic-block ] iterate-nodes ;

: begin-word ( -- )
    #! We store the basic block after the prologue as a loop
    #! labeled by the current word, so that self-recursive
    #! calls can skip an epilogue/prologue.
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

: emit-call ( word height -- next )
    {
        { [ over loops get key? ] [ drop loops get at local-recursive-call ] }
        { [ terminate-call? ] [ ##call stop-iterating ] }
        { [ tail-call? not ] [ ##call ##branch begin-basic-block iterate-next ] }
        { [ dup current-label get eq? ] [ 2drop first-basic-block get local-recursive-call ] }
        [ drop ##epilogue ##jump stop-iterating ]
    } cond ;

! #recursive
: recursive-height ( #recursive -- n )
    [ label>> return>> in-d>> length ] [ in-d>> length ] bi - ;

: emit-recursive ( #recursive -- next )
    [ [ label>> id>> ] [ recursive-height ] bi emit-call ]
    [ [ child>> ] [ label>> word>> ] [ label>> id>> ] tri (build-cfg) ] bi ;

: remember-loop ( label -- )
    basic-block get swap loops get set-at ;

: emit-loop ( node -- next )
    ##loop-entry
    ##branch
    begin-basic-block
    [ label>> id>> remember-loop ] [ child>> emit-nodes ] bi
    iterate-next ;

M: #recursive emit-node
    dup label>> loop?>> [ emit-loop ] [ emit-recursive ] if ;

! #if
: emit-branch ( obj -- final-bb )
    [
        begin-basic-block
        emit-nodes
        basic-block get dup [ ##branch ] when
    ] with-scope ;

: emit-if ( node -- )
    children>>  [ emit-branch ] map
    end-basic-block
    begin-basic-block
    basic-block get '[ [ _ swap successors>> push ] when* ] each ;

: ##branch-t ( vreg -- )
    \ f tag-number cc/= ##compare-imm-branch ;

: trivial-branch? ( nodes -- value ? )
    dup length 1 = [
        first dup #push? [ literal>> t ] [ drop f f ] if
    ] [ drop f f ] if ;

: trivial-if? ( #if -- ? )
    children>> first2
    [ trivial-branch? [ t eq? ] when ]
    [ trivial-branch? [ f eq? ] when ] bi*
    and ;

: emit-trivial-if ( -- )
    ds-pop \ f tag-number cc/= ^^compare-imm ds-push ;

: trivial-not-if? ( #if -- ? )
    children>> first2
    [ trivial-branch? [ f eq? ] when ]
    [ trivial-branch? [ t eq? ] when ] bi*
    and ;

: emit-trivial-not-if ( -- )
    ds-pop \ f tag-number cc= ^^compare-imm ds-push ;

M: #if emit-node
    {
        { [ dup trivial-if? ] [ drop emit-trivial-if ] }
        { [ dup trivial-not-if? ] [ drop emit-trivial-not-if ] }
        [ ds-pop ##branch-t emit-if ]
    } cond iterate-next ;

! #dispatch
M: #dispatch emit-node
    ds-pop ^^offset>slot i ##dispatch emit-if iterate-next ;

! #call
M: #call emit-node
    dup word>> dup "intrinsic" word-prop
    [ emit-intrinsic ] [ swap call-height emit-call ] if ;

! #call-recursive
M: #call-recursive emit-node [ label>> id>> ] [ call-height ] bi emit-call ;

! #push
M: #push emit-node
    literal>> ^^load-literal ds-push iterate-next ;

! #shuffle
M: #shuffle emit-node
    dup
    H{ } clone
    [ [ in-d>> [ length ds-load ] keep ] dip '[ _ set-at ] 2each ]
    [ [ in-r>> [ length rs-load ] keep ] dip '[ _ set-at ] 2each ]
    [ nip ] 2tri
    [ [ [ out-d>> ] [ mapping>> ] bi ] dip '[ _ at _ at ] map ds-store ]
    [ [ [ out-r>> ] [ mapping>> ] bi ] dip '[ _ at _ at ] map rs-store ] 2bi
    iterate-next ;

! #return
M: #return emit-node
    drop ##epilogue ##return stop-iterating ;

M: #return-recursive emit-node
    label>> id>> loops get key?
    [ iterate-next ] [ ##epilogue ##return stop-iterating ] if ;

! #terminate
M: #terminate emit-node drop stop-iterating ;

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
    [ params>> ] dip [ drop alien-stack-frame ] [ call ] 2bi
    ##branch begin-basic-block iterate-next ; inline

M: #alien-invoke emit-node
    [ ##alien-invoke ] emit-alien-node ;

M: #alien-indirect emit-node
    [ ##alien-indirect ] emit-alien-node ;

M: #alien-callback emit-node
    dup params>> xt>> dup
    [
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

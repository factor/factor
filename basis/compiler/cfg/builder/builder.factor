! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.builder.blocks compiler.cfg.comparisons
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.stacks.local compiler.cfg.utilities compiler.tree
cpu.architecture kernel make math namespaces sequences words ;
IN: compiler.cfg.builder

SLOT: id
SLOT: return
SYMBOL: procedures
SYMBOL: loops

: begin-cfg ( word label -- cfg )
    H{ } clone loops set
    <basic-block> dup set-basic-block <cfg> dup cfg set ;

: with-cfg-builder ( nodes word label quot: ( ..a block -- ..b ) -- )
    '[
        begin-stack-analysis
        begin-cfg
        [ procedures get push ]
        [ entry>> @ ]
        [ end-stack-analysis ] tri
    ] with-scope ; inline

: with-dummy-cfg-builder ( node quot -- )
    [
        [ V{ } clone procedures ] 2dip
        '[ _ t t [ drop _ call( node -- ) ] with-cfg-builder ] with-variable
    ] { } make drop ;

GENERIC: emit-node ( block node -- block' )

: emit-nodes ( block nodes -- block' )
    [ over [ emit-node ] [ drop ] if ] each ;

: begin-word ( block -- block' )
    t >>kill-block?
    ##safepoint, ##prologue, ##branch,
    begin-basic-block ;

: (build-cfg) ( nodes word label -- )
    [ begin-word swap emit-nodes drop ] with-cfg-builder ;

: build-cfg ( nodes word -- procedures )
    V{ } clone [
        procedures [
            dup (build-cfg)
        ] with-variable
    ] keep ;

: emit-loop-call ( successor-block current-block -- )
    ##safepoint, ##branch,
    [ swap connect-bbs ] [ end-basic-block ] bi ;

: emit-call ( block word height -- block' )
    over loops get at [
        2nip swap emit-loop-call f
    ] [ emit-trivial-call ] if* ;

! #recursive
: recursive-height ( #recursive -- n )
    [ label>> return>> in-d>> length ] [ in-d>> length ] bi - ;

: emit-recursive ( block #recursive -- block' )
    [ [ label>> id>> ] [ recursive-height ] bi emit-call ] keep
    [ child>> ] [ label>> word>> ] [ label>> id>> ] tri (build-cfg) ;

: emit-loop ( block #recursive -- block' )
    ##branch, [ begin-basic-block ] dip
    [ label>> id>> loops get set-at ] [ child>> emit-nodes ] 2bi ;

M: #recursive emit-node
    dup label>> loop?>> [ emit-loop ] [ emit-recursive ] if ;

! #if
: emit-branch ( nodes block -- pair/f )
    [ swap emit-nodes ] with-branch ;

: emit-if ( block node -- block' )
    children>> over '[ _ emit-branch ] map emit-conditional ;

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
    [ f cc/= ^^compare-imm ] unary-op ;

: trivial-not-if? ( #if -- ? )
    children>> first2
    [ trivial-branch? [ f eq? ] when ]
    [ trivial-branch? [ t eq? ] when ] bi*
    and ;

: emit-trivial-not-if ( -- )
    [ f cc= ^^compare-imm ] unary-op ;

: emit-actual-if ( block #if -- block' )
    ! Inputs to the final instruction need to be copied because of
    ! loc>vreg sync
    ds-pop any-rep ^^copy f cc/= ##compare-imm-branch, emit-if ;

M: #if emit-node
    {
        { [ dup trivial-if? ] [ drop emit-trivial-if ] }
        { [ dup trivial-not-if? ] [ drop emit-trivial-not-if ] }
        [ emit-actual-if ]
    } cond ;

M: #dispatch emit-node
    ! Inputs to the final instruction need to be copied because of
    ! loc>vreg sync. ^^offset>slot always returns a fresh vreg,
    ! though.
    ds-pop ^^offset>slot next-vreg ##dispatch, emit-if ;

M: #call emit-node
    dup word>> dup "intrinsic" word-prop [
        nip call( block #call -- block' )
    ] [ swap call-height emit-call ] if* ;

M: #call-recursive emit-node
    [ label>> id>> ] [ call-height ] bi emit-call ;

M: #push emit-node
    literal>> ^^load-literal ds-push ;

! #shuffle

! Even though low level IR has its own dead code elimination pass,
! we try not to introduce useless ##peeks here, since this reduces
! the accuracy of global stack analysis.

: make-input-map ( #shuffle -- assoc )
    [ in-d>> ds-loc ] [ in-r>> rs-loc ] bi
    [ over length stack-locs zip ] 2bi@ append ;

: height-changes ( #shuffle -- height-changes )
    { [ out-d>> ] [ in-d>> ] [ out-r>> ] [ in-r>> ] } cleave 4array
    [ length ] map first4 [ - ] 2bi@ 2array ;

: store-height-changes ( #shuffle -- )
    height-changes { ds-loc rs-loc } [ new swap >>n inc-stack ] 2each ;

: extract-outputs ( #shuffle -- pair )
    [ out-d>> ] [ out-r>> ] bi 2array ;

: out-vregs/stack ( #shuffle -- pair )
    [ make-input-map ] [ mapping>> ] [ extract-outputs ] tri
    [ [ of of peek-loc ] 2with map ] 2with map ;

M: #shuffle emit-node
    [ out-vregs/stack ] keep store-height-changes
    first2 [ ds-loc store-vregs ] [ rs-loc store-vregs ] bi* ;

! #return
: end-word ( block -- block' )
    ##branch, begin-basic-block
    t >>kill-block?
    ##safepoint, ##epilogue, ##return, ;

M: #return emit-node
    drop end-word ;

M: #return-recursive emit-node
    label>> id>> loops get key? [ ] [ end-word ] if ;

! #terminate
M: #terminate emit-node
    drop ##no-tco, end-basic-block f ;

! No-op nodes
M: #introduce emit-node drop ;

M: #copy emit-node drop ;

M: #enter-recursive emit-node drop ;

M: #phi emit-node drop ;

M: #declare emit-node drop ;

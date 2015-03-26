! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.builder.blocks compiler.cfg.comparisons
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.tree
compiler.cfg.utilities cpu.architecture fry kernel make math namespaces
sequences words ;
IN: compiler.cfg.builder

SYMBOL: procedures
SYMBOL: loops

: begin-cfg ( word label -- cfg )
    H{ } clone loops set
    <basic-block> dup set-basic-block <cfg> dup cfg set ;

: begin-procedure ( word label -- )
    begin-cfg procedures get push ;

: with-cfg-builder ( nodes word label quot -- )
    '[
        begin-stack-analysis
        begin-procedure
        @
        end-stack-analysis
    ] with-scope ; inline

: with-dummy-cfg-builder ( node quot -- )
    [
        [ V{ } clone procedures ] 2dip
        '[ _ t t [ _ call( node -- ) ] with-cfg-builder ] with-variable
    ] { } make drop ;

GENERIC: emit-node ( node -- )

: emit-nodes ( nodes -- )
    [ basic-block get [ emit-node ] [ drop ] if ] each ;

: begin-word ( -- )
    make-kill-block
    ##safepoint,
    ##prologue,
    ##branch,
    begin-basic-block ;

: (build-cfg) ( nodes word label -- )
    [

        begin-word
        emit-nodes
    ] with-cfg-builder ;

: build-cfg ( nodes word -- procedures )
    V{ } clone [
        procedures [
            dup (build-cfg)
        ] with-variable
    ] keep ;

: emit-loop-call ( basic-block -- )
    ##safepoint,
    ##branch,
    basic-block get swap connect-bbs
    end-basic-block ;

: emit-call ( word height -- )
    over loops get key?
    [ drop loops get at emit-loop-call ]
    [
        [
            [ ##call, ] [ adjust-d ] bi*
            make-kill-block
        ] emit-trivial-block
    ] if ;

! #recursive
: recursive-height ( #recursive -- n )
    [ label>> return>> in-d>> length ] [ in-d>> length ] bi - ;

: emit-recursive ( #recursive -- )
    [ [ label>> id>> ] [ recursive-height ] bi emit-call ]
    [ [ child>> ] [ label>> word>> ] [ label>> id>> ] tri (build-cfg) ] bi ;

: remember-loop ( label -- )
    basic-block get swap loops get set-at ;

: emit-loop ( node -- )
    ##branch,
    begin-basic-block
    [ label>> id>> remember-loop ] [ child>> emit-nodes ] bi ;

M: #recursive emit-node
    dup label>> loop?>> [ emit-loop ] [ emit-recursive ] if ;

! #if
: emit-branch ( obj -- pair/f )
    [ emit-nodes ] with-branch ;

: emit-if ( node -- )
    children>> [ emit-branch ] map emit-conditional ;

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

: emit-actual-if ( #if -- )
    ! Inputs to the final instruction need to be copied because of
    ! loc>vreg sync
    ds-pop any-rep ^^copy f cc/= ##compare-imm-branch, emit-if ;

M: #if emit-node
    {
        { [ dup trivial-if? ] [ drop emit-trivial-if ] }
        { [ dup trivial-not-if? ] [ drop emit-trivial-not-if ] }
        [ emit-actual-if ]
    } cond ;

! #dispatch
M: #dispatch emit-node
    ! Inputs to the final instruction need to be copied because of
    ! loc>vreg sync. ^^offset>slot always returns a fresh vreg,
    ! though.
    ds-pop ^^offset>slot next-vreg ##dispatch, emit-if ;

! #call
M: #call emit-node
    dup word>> dup "intrinsic" word-prop
    [ emit-intrinsic ] [ swap call-height emit-call ] if ;

! #call-recursive
M: #call-recursive emit-node [ label>> id>> ] [ call-height ] bi emit-call ;

! #push
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
    { [ out-d>> ] [ in-d>> ] [ out-r>> ] [ in-r>> ] } cleave
    4array [ length ] map first4 [ - ] 2bi@ 2array ;

: store-height-changes ( #shuffle -- )
    height-changes { ds-loc rs-loc } [ new swap >>n inc-stack ] 2each ;

: extract-outputs ( #shuffle -- seq )
    [ out-d>> ds-loc 2array ] [ out-r>> rs-loc 2array ] bi 2array ;

: out-vregs/stack ( #shuffle -- seq )
    [ make-input-map ] [ mapping>> ] [ extract-outputs ] tri
    [ first2 [ [ of of peek-loc ] 2with map ] dip 2array ] 2with map ;

M: #shuffle emit-node
    [ out-vregs/stack ] keep store-height-changes [ first2 store-vregs ] each ;

! #return
: end-word ( -- )
    ##branch,
    begin-basic-block
    make-kill-block
    ##safepoint,
    ##epilogue,
    ##return, ;

M: #return emit-node drop end-word ;

M: #return-recursive emit-node
    label>> id>> loops get key? [ end-word ] unless ;

! #terminate
M: #terminate emit-node drop ##no-tco, end-basic-block ;

! No-op nodes
M: #introduce emit-node drop ;

M: #copy emit-node drop ;

M: #enter-recursive emit-node drop ;

M: #phi emit-node drop ;

M: #declare emit-node drop ;

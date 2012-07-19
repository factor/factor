! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators hashtables kernel
math fry namespaces make sequences words byte-arrays
layouts alien.c-types
stack-checker.inlining cpu.architecture
compiler.tree
compiler.tree.builder
compiler.tree.combinators
compiler.tree.propagation.info
compiler.cfg
compiler.cfg.hats
compiler.cfg.utilities
compiler.cfg.registers
compiler.cfg.intrinsics
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.cfg.instructions
compiler.cfg.predecessors
compiler.cfg.builder.blocks
compiler.cfg.stacks
compiler.cfg.stacks.local ;
IN: compiler.cfg.builder

! Convert tree SSA IR to CFG IR. The result is not in SSA form; this is
! constructed later by calling compiler.cfg.ssa.construction:construct-ssa.

SYMBOL: procedures
SYMBOL: loops

: begin-cfg ( word label -- cfg )
    initial-basic-block
    H{ } clone loops set
    [ basic-block get ] 2dip <cfg> dup cfg set ;

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
    basic-block get successors>> push
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
: emit-branch ( obj -- final-bb )
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
    ! Assoc maps high-level IR values to stack locations.
    [
        [ in-d>> <reversed> [ <ds-loc> swap ,, ] each-index ]
        [ in-r>> <reversed> [ <rs-loc> swap ,, ] each-index ] bi
    ] H{ } make ;

: make-output-seq ( values mapping input-map -- vregs )
    '[ _ at _ at peek-loc ] map ;

: load-shuffle ( #shuffle mapping input-map -- ds-vregs rs-vregs )
    [ [ out-d>> ] 2dip make-output-seq ]
    [ [ out-r>> ] 2dip make-output-seq ] 3bi ;

: store-shuffle ( #shuffle ds-vregs rs-vregs -- )
    [ [ in-d>> length neg inc-d ] dip ds-store ]
    [ [ in-r>> length neg inc-r ] dip rs-store ]
    bi-curry* bi ;

M: #shuffle emit-node
    dup dup [ mapping>> ] [ make-input-map ] bi load-shuffle store-shuffle ;

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

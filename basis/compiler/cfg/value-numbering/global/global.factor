! Copyright (C) 2011 Alex Vondrak, 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg
compiler.cfg.dataflow-analysis compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.predecessors compiler.cfg.rpo
compiler.cfg.utilities compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph compiler.utilities grouping hashtables kernel locals math namespaces
sequences sorting ;
IN: compiler.cfg.value-numbering.global

! Adapted from compiler.cfg.gvn. Numbering analyzes a fixed instruction
! stream; rewrites, fresh registers and edge changes belong to the local
! simplifier, outside this fixed point.
!
! foldable-insn is a local CSE contract, not a global effect contract.
! In particular, FP state, mutable memory and derived pointers require
! more than congruent inputs before an operation can be reused globally.
UNION: global-value-insn
    ##load-integer ##load-reference
    ##add ##add-imm ##sub ##sub-imm ##mul ##mul-imm
    ##and ##and-imm ##or ##or-imm ##xor ##xor-imm
    ##shl ##shl-imm ##shr ##shr-imm ##sar ##sar-imm
    ##min ##max ##neg ##not
    ##compare-integer ##compare-integer-imm ##test ##test-imm ;

<PRIVATE

SYMBOLS: numbering-changed? eliminated? congruence-classes candidate-vns ;

: set-global-vn ( vn vreg -- )
    vregs>vns get maybe-set-at [ numbering-changed? on ] when ;

:: number-expression ( insn expr -- )
    insn dst>> :> dst
    expr exprs>vns get [ drop dst ] cache dst set-global-vn ;

GENERIC: number-insn ( insn -- )

M: insn number-insn
    defs-vregs [ dup set-global-vn ] each ;

M: global-value-insn number-insn
    dup >expr number-expression ;

M: ##copy number-insn
    [ src>> vreg>vn ] [ dst>> ] bi set-global-vn ;

: phi-expression ( insn -- expr )
    ! Values alone lose the association with predecessor edges. Sort by
    ! predecessor number to make the key independent of hash iteration.
    inputs>> >alist [ first number>> ] sort-by
    [ second vreg>vn ] map
    basic-block get 2array ;

M: ##phi number-insn
    dup inputs>> values [ vreg>vn ] map sift
    dup all-equal? [
        [ dst>> ] [ ?first ] bi* swap set-global-vn
    ] [ drop dup phi-expression number-expression ] if ;

: numbering-iteration ( cfg -- )
    exprs>vns get clear-assoc
    [ [ number-insn ] each ] simple-analysis ;

: determine-value-numbers ( cfg -- )
    init-value-graph
    dup [
        [ defs-vregs [ f swap vregs>vns get set-at ] each ] each
    ] simple-analysis
    '[
        numbering-changed? off
        _ numbering-iteration
        numbering-changed? get
    ] loop ;

: compute-congruence-classes ( -- )
    H{ } clone [
        '[ _ push-at ] vregs>vns get swap assoc-each
    ] keep congruence-classes set ;

: elimination-candidate? ( insn -- ? )
    dup ##phi? [ drop t ] [
        dup global-value-insn?
        swap dup ##load-integer? swap ##load-reference? or not and
    ] if ;

:: compute-candidates ( cfg -- )
    H{ } clone :> counts
    H{ } clone :> candidates
    cfg [
        [| insn |
            insn elimination-candidate? [
                insn dst>> vreg>vn :> vn
                vn [
                    vn counts inc-at
                    insn ##phi? [
                        vn congruence-classes get at length 1 >
                        [ vn vn candidates set-at ] when
                    ] when
                ] when
            ] when
        ] each
    ] simple-analysis
    counts [| vn count |
        count 1 > [ vn vn candidates set-at ] when
    ] assoc-each
    candidates candidate-vns set ;

: candidate-vreg? ( vreg -- ? )
    vreg>vn candidate-vns get key? ;

: defined ( bb -- vregs )
    instructions>> [ defs-vregs ] map concat
    [ candidate-vreg? ] filter unique ;

FORWARD-ANALYSIS: available

M: available transfer-set drop defined assoc-union ;

: value-available? ( vreg -- ? )
    basic-block get available-in key? ;

: available-representative ( vreg -- vreg/f )
    dup candidate-vreg? [
        vreg>vn congruence-classes get at
        [ value-available? ] filter [ f ] [ minimum ] if-empty
    ] [ drop f ] if ;

: make-available ( insn -- )
    defs-vregs [ candidate-vreg? ] filter [
        basic-block get available-ins get
        [ dupd clone ?set-at ] assocs:change-at
    ] each ;

GENERIC: eliminate-insn ( insn -- insn' )

M: insn eliminate-insn ;

: eliminate-congruent ( insn -- insn' )
    dup dst>> available-representative [
        [ dst>> ] dip <copy> eliminated? on
    ] when* ;

M: global-value-insn eliminate-insn eliminate-congruent ;

! Number literals to recognize congruent calculations, but keep their loads
! near their uses. Extending a literal's live range can cause spills while
! saving nothing after immediate folding and dead-code elimination.
M: ##load-integer eliminate-insn ;
M: ##load-reference eliminate-insn ;
M: ##phi eliminate-insn eliminate-congruent ;

: eliminate-block ( insns -- insns' )
    [ eliminate-insn dup make-available ] map
    ! Redundant phis become copies. Keep surviving phis at block entry,
    ! so predecessor maintenance never misses one behind a copy.
    [ ##phi? ] partition append ;

PRIVATE>

: global-value-numbering ( cfg -- changed? )
    [
        dup needs-predecessors
        dup determine-value-numbers
        compute-congruence-classes
        dup compute-candidates
        ! Most SSA values cannot eliminate another calculation. Do not
        ! propagate them through a dense per-block availability analysis.
        candidate-vns get assoc-empty? [ drop f ] [
            dup compute-available-sets
            eliminated? off
            [ eliminate-block ] simple-optimization
            eliminated? get
        ] if
    ] with-scope ;

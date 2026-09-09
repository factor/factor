! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.copy-prop
compiler.cfg.dataflow-analysis compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.rpo compiler.cfg.utilities
kernel locals math namespaces sequences ;
IN: compiler.cfg.memory-optimization

! Experimental until whole-pipeline measurements justify enabling it.
SYMBOL: memory-optimization?
SYMBOL: memory-optimization-statistics

<PRIVATE

SYMBOL: memory-entry

! All writes and unknown effects are barriers, including calls, allocation,
! GC and write barriers. In particular, different incoming objects may alias.
! These operations only read memory or change SSA/stack/control-flow state.
UNION: memory-transparent-insn
    foldable-insn ##peek ##replace ##inc ##branch ##phi
    ##slot ##slot-imm conditional-branch-insn ;

: memory-load-key ( ##slot-imm -- key )
    [ obj>> ] [ slot>> ] [ tag>> ] tri 3array ;

:: update-memory-facts ( insn facts -- )
    insn ##slot-imm? [
        insn dst>> insn memory-load-key facts set-at
    ] [
        insn memory-transparent-insn?
        insn allocation-insn? insn gc-map-insn? or not and
        ! C-type unboxers are configurable C helpers, despite being foldable.
        insn ##unbox? insn ##unbox-long-long? or not and
        [ ] [ facts clear-assoc ] if
    ] if ;

! Core assoc-intersect checks keys alone. Memory availability additionally
! requires the same SSA result on every path; sibling loads cannot supply a
! new join value without a phi, which this pass deliberately does not create.
:: common-memory-facts ( sets -- facts )
    H{ } clone :> facts
    sets empty? [ ] [
        sets first [| key value |
            sets rest [ key swap at value = ] all?
            [ value key facts set-at ] when
        ] assoc-each
    ] if
    facts ;

FORWARD-ANALYSIS: memory-available

M:: memory-available join-sets ( sets bb dfa -- facts )
    bb memory-entry get eq? [ H{ } clone ] [ sets common-memory-facts ] if ;

M:: memory-available transfer-set ( incoming bb dfa -- outgoing )
    incoming H{ } assoc-clone-like :> facts
    bb instructions>> [ facts update-memory-facts ] each
    facts ;

:: eliminate-available-load ( insn facts -- insn' )
    insn ##slot-imm? [
        insn memory-load-key facts at [| source |
            ! Keep original result identities in the analysis. The copy is
            ! still a definition until the following copy-propagation pass.
            "eliminated-loads" memory-optimization-statistics get inc-at
            insn dst>> source <copy>
        ] [ insn ] if*
    ] [ insn ] if ;

:: eliminate-memory-block ( bb -- )
    bb memory-available-in H{ } assoc-clone-like :> facts
    bb [ [| insn |
        insn facts eliminate-available-load
        insn facts update-memory-facts
    ] map ] change-instructions drop ;

PRIVATE>

:: eliminate-redundant-loads ( cfg -- changed? )
    H{ { "eliminated-loads" 0 } } clone memory-optimization-statistics set
    cfg cfg>insns [ ##slot-imm? ] count :> loads
    loads "loads" memory-optimization-statistics get set-at
    loads 1 > [
        [
            cfg entry>> memory-entry set
            cfg compute-memory-available-sets
            cfg reverse-post-order [ kill-block?>> ] reject
            [ eliminate-memory-block ] each
        ] with-scope
    ] when
    memory-optimization-statistics get "eliminated-loads" of 0 > ;

: optimize-memory ( cfg -- )
    memory-optimization? get [
        dup eliminate-redundant-loads
        [ copy-propagation ] [ drop ] if
    ] [ drop f memory-optimization-statistics set ] if ;

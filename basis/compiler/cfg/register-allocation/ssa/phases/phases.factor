! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.ranges compiler.cfg.linearization
compiler.cfg.register-allocation.ssa compiler.cfg.registers
compiler.cfg.renaming.functor compiler.cfg.utilities kernel locals make math
namespaces sequences sets ;
IN: compiler.cfg.register-allocation.ssa.phases

! This is a paired interface. Its endpoints must not be fed to the old
! all-operands-at-once assignment pass. Instruction numbers remain even.
! Calls retain the existing indivisible ABI/synchronization point.
: phase-split-insn? ( insn -- ? )
    dup clobber-insn? swap ##call-gc? or not ;

:: ssa-input-phase ( insn index -- n )
    insn insn#>>
    insn phase-split-insn? [
        index zero? insn def-is-use-insn? not and [ ] [ 1 + ] if
    ] when ;

: ssa-output-phase ( insn -- n )
    dup insn#>> swap phase-split-insn? [ 1 + ] when ;

:: record-phase-temp ( vreg n -- )
    vreg vreg>live-interval :> interval
    n n 1 + interval ranges>> add-range
    n interval f (add-use) vreg rep-of >>def-rep drop ;

:: compute-phase-insn-intervals ( insn -- )
    insn phase-split-insn? [
        insn defs-vregs [ insn ssa-output-phase f record-def ] each
        insn uses-vregs length <iota> <reversed> [| index |
            index insn uses-vregs nth insn index ssa-input-phase f record-use
        ] each
        insn temp-vregs [ insn insn#>> record-phase-temp ] each
    ] [ insn compute-live-intervals* ] if ;

:: compute-phase-ssa-block ( bb -- )
    bb block-from from namespaces:set
    bb block-to 1 + to namespaces:set
    bb handle-live-out
    bb instructions>> <reversed> [
        dup ##phi? [
            dst>> from get over phi-entry-positions get set-at
            from get t record-def
        ] [ compute-phase-insn-intervals ] if
    ] each ;

: compute-phase-ssa-intervals ( cfg -- intervals/sync-points )
    H{ } clone live-intervals namespaces:set
    H{ } clone phi-entry-positions namespaces:set
    [
        linearization-order <reversed> [ compute-phase-ssa-block ] each
        live-intervals get values dup [ finish-live-interval ] each
    ] [ cfg>sync-points ] bi append ;

! A reload at late n+1 runs before the actual instruction. It may overwrite
! a dying early input even though their abstract ranges are disjoint. Final
! unsplit SSA coloring with source-level reload instructions needs no such
! transport. A splitting allocator must move input-bearing reloads to early
! n (and extend their ranges); output-only intervals may still start late.
ERROR: unsafe-late-ssa-reload interval ;

:: check-phase-ssa-transports ( cfg intervals -- )
    cfg cfg>insns [ dup ##phi? not swap phase-split-insn? and ] filter
    [ insn#>> 1 + ] map :> late
    intervals [| interval |
        interval reload-from>> [
            interval live-interval-start late member?
            [ interval unsafe-late-ssa-reload ] when
        ] when
    ] each ;

SYMBOL: phase-input-registers

: phase-input>register ( vreg -- reg/slot )
    phase-input-registers get at ;

RENAMING: phase-assign [ vreg>reg ] [ phase-input>register ] [ vreg>reg ]

:: assign-phase-insn ( insn -- )
    insn insn#>> prepare-insn
    insn ##phi? [ ] [
        insn phase-split-insn? [
            H{ } clone :> inputs
            insn uses-vregs :> uses
            insn def-is-use-insn? uses empty? or [ ] [
                uses first dup vreg>reg swap inputs set-at
            ] if
            insn insn#>> 1 + prepare-insn
            uses [| value index |
                index zero? insn def-is-use-insn? not and [ ] [
                    value vreg>reg value inputs set-at
                ] if
            ] each-index
            inputs phase-input-registers namespaces:set
            insn [ phase-assign-insn-uses ]
                [ phase-assign-insn-defs ]
                [ phase-assign-insn-temps ] tri
        ] [ insn assign-all-registers ] if
        insn emit-insn
    ] if ;

:: assign-phase-ssa-block ( bb -- )
    bb basic-block namespaces:set
    bb block-from unhandled-intervals get activate-new-intervals
    bb compute-ssa-live-in
    bb record-phi-locations
    bb [ [ [ assign-phase-insn ] each ] V{ } make ] change-instructions
    compute-ssa-live-out ;

:: assign-phase-ssa-registers ( cfg intervals -- )
    cfg intervals check-phase-ssa-transports
    intervals init-assignment
    H{ } clone phi-locations namespaces:set
    cfg linearization-order [ kill-block?>> ] reject
    [ assign-phase-ssa-block ] each ;

! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math assocs namespaces sequences heaps
fry make combinators combinators.short-circuit sets locals arrays
cpu.architecture layouts
compiler.cfg
compiler.cfg.def-use
compiler.cfg.liveness
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.linearization
compiler.cfg.ssa.destruction.leaders
compiler.cfg.renaming.functor
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals ;
FROM: namespaces => set ;
IN: compiler.cfg.linear-scan.assignment

! This contains both active and inactive intervals; any interval
! such that start <= insn# <= end is in this set.
SYMBOL: pending-interval-heap
SYMBOL: pending-interval-assoc

: add-pending ( live-interval -- )
    [ dup end>> pending-interval-heap get heap-push ]
    [ [ reg>> ] [ vreg>> ] bi pending-interval-assoc get set-at ]
    bi ;

: remove-pending ( live-interval -- )
    vreg>> pending-interval-assoc get delete-at ;

:: vreg>reg ( vreg -- reg )
    ! If a live vreg is not in the pending set, then it must
    ! have been spilled.
    vreg leader :> leader
    leader pending-interval-assoc get at* [
        drop leader vreg rep-of lookup-spill-slot
    ] unless ;

ERROR: not-spilled-error vreg ;

: vreg>spill-slot ( vreg -- spill-slot )
    dup vreg>reg dup spill-slot? [ nip ] [ drop leader not-spilled-error ] if ;

: vregs>regs ( vregs -- assoc )
    [ f ] [ [ dup vreg>reg ] H{ } map>assoc ] if-empty ;

! Minheap of live intervals which still need a register allocation
SYMBOL: unhandled-intervals

: add-unhandled ( live-interval -- )
    dup start>> unhandled-intervals get heap-push ;

: init-unhandled ( live-intervals -- )
    [ add-unhandled ] each ;

! Liveness info is used by resolve pass

! Mapping from basic blocks to values which are live at the start
! on all incoming CFG edges
SYMBOL: machine-live-ins

: machine-live-in ( bb -- assoc )
    machine-live-ins get at ;

: compute-live-in ( bb -- )
    [ live-in keys vregs>regs ] keep machine-live-ins get set-at ;

! Mapping from basic blocks to predecessors to values which are
! live on a particular incoming edge
SYMBOL: machine-edge-live-ins

: machine-edge-live-in ( predecessor bb -- assoc )
    machine-edge-live-ins get at at ;

: compute-edge-live-in ( bb -- )
    [ edge-live-ins get at [ keys vregs>regs ] assoc-map ] keep
    machine-edge-live-ins get set-at ;

! Mapping from basic blocks to values which are live at the end
SYMBOL: machine-live-outs

: machine-live-out ( bb -- assoc )
    machine-live-outs get at ;

: compute-live-out ( bb -- )
    [ live-out keys vregs>regs ] keep machine-live-outs get set-at ;

: init-assignment ( live-intervals -- )
    <min-heap> pending-interval-heap set
    H{ } clone pending-interval-assoc set
    <min-heap> unhandled-intervals set
    H{ } clone machine-live-ins set
    H{ } clone machine-edge-live-ins set
    H{ } clone machine-live-outs set
    init-unhandled ;

: insert-spill ( live-interval -- )
    [ reg>> ] [ spill-rep>> ] [ spill-to>> ] tri ##spill, ;

: handle-spill ( live-interval -- )
    dup spill-to>> [ insert-spill ] [ drop ] if ;

: expire-interval ( live-interval -- )
    [ remove-pending ] [ handle-spill ] bi ;

: (expire-old-intervals) ( n heap -- )
    dup heap-empty? [ 2drop ] [
        2dup heap-peek nip <= [ 2drop ] [
            dup heap-pop drop expire-interval
            (expire-old-intervals)
        ] if
    ] if ;

: expire-old-intervals ( n -- )
    pending-interval-heap get (expire-old-intervals) ;

: insert-reload ( live-interval -- )
    [ reg>> ] [ reload-rep>> ] [ reload-from>> ] tri ##reload, ;

: handle-reload ( live-interval -- )
    dup reload-from>> [ insert-reload ] [ drop ] if ;

: activate-interval ( live-interval -- )
    [ add-pending ] [ handle-reload ] bi ;

: (activate-new-intervals) ( n heap -- )
    dup heap-empty? [ 2drop ] [
        2dup heap-peek nip = [
            dup heap-pop drop activate-interval
            (activate-new-intervals)
        ] [ 2drop ] if
    ] if ;

: activate-new-intervals ( n -- )
    unhandled-intervals get (activate-new-intervals) ;

: prepare-insn ( n -- )
    [ expire-old-intervals ] [ activate-new-intervals ] bi ;

GENERIC: assign-registers-in-insn ( insn -- )

RENAMING: assign [ vreg>reg ] [ vreg>reg ] [ vreg>reg ]

M: vreg-insn assign-registers-in-insn
    [ assign-insn-defs ] [ assign-insn-uses ] [ assign-insn-temps ] tri ;

: assign-gc-roots ( gc-map -- )
    [ [ vreg>spill-slot ] map ] change-gc-roots drop ;

: assign-derived-roots ( gc-map -- )
    [ [ [ vreg>spill-slot ] bi@ ] assoc-map ] change-derived-roots drop ;

M: gc-map-insn assign-registers-in-insn
    [ [ assign-insn-defs ] [ assign-insn-uses ] [ assign-insn-temps ] tri ]
    [ gc-map>> [ assign-gc-roots ] [ assign-derived-roots ] bi ]
    bi ;

M: insn assign-registers-in-insn drop ;

: begin-block ( bb -- )
    {
        [ basic-block set ]
        [ block-from activate-new-intervals ]
        [ compute-edge-live-in ]
        [ compute-live-in ]
    } cleave ;

:: assign-registers-in-block ( bb -- )
    bb kill-block?>> [
        bb [
            [
                bb begin-block
                [
                    {
                        [ insn#>> 1 - prepare-insn ]
                        [ insn#>> prepare-insn ]
                        [ assign-registers-in-insn ]
                        [ , ]
                    } cleave
                ] each
                bb compute-live-out
            ] V{ } make
        ] change-instructions drop
    ] unless ;

: assign-registers ( live-intervals cfg -- )
    [ init-assignment ] dip
    linearization-order [ assign-registers-in-block ] each ;

! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.linearization compiler.cfg.liveness compiler.cfg.registers
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.renaming.functor
compiler.cfg.ssa.destruction.leaders cpu.architecture
fry heaps kernel locals make math namespaces sequences sets ;
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
    vreg leader :> leader
    leader pending-interval-assoc get at* [
        drop leader vreg rep-of lookup-spill-slot
    ] unless ;

ERROR: not-spilled-error vreg ;

: vreg>spill-slot ( vreg -- spill-slot )
    dup vreg>reg dup spill-slot? [ nip ] [ drop leader not-spilled-error ] if ;

: vregs>regs ( vregs -- assoc )
    [ dup vreg>reg ] H{ } map>assoc ;

SYMBOL: unhandled-intervals

SYMBOL: machine-live-ins

: machine-live-in ( bb -- assoc )
    machine-live-ins get at ;

: compute-live-in ( bb -- )
    [ live-in keys vregs>regs ] keep machine-live-ins get set-at ;

SYMBOL: machine-edge-live-ins

: machine-edge-live-in ( predecessor bb -- assoc )
    machine-edge-live-ins get at at ;

: compute-edge-live-in ( bb -- )
    [ edge-live-ins get at [ keys vregs>regs ] assoc-map ] keep
    machine-edge-live-ins get set-at ;

SYMBOL: machine-live-outs

: machine-live-out ( bb -- assoc )
    machine-live-outs get at ;

: compute-live-out ( bb -- )
    [ live-out keys vregs>regs ] keep machine-live-outs get set-at ;

: init-assignment ( live-intervals -- )
    [ [ start>> ] map ] keep zip >min-heap unhandled-intervals set
    <min-heap> pending-interval-heap set
    H{ } clone pending-interval-assoc set
    H{ } clone machine-live-ins set
    H{ } clone machine-edge-live-ins set
    H{ } clone machine-live-outs set ;

: heap-pop-while ( heap quot: ( key -- ? ) -- values )
    '[ dup heap-empty? [ f f ] [ dup heap-peek @ ] if ]
    [ over heap-pop* ] produce 2nip ; inline

: insert-spill ( live-interval -- )
    [ reg>> ] [ spill-rep>> ] [ spill-to>> ] tri ##spill, ;

: handle-spill ( live-interval -- )
    dup spill-to>> [ insert-spill ] [ drop ] if ;

: expire-interval ( live-interval -- )
    [ remove-pending ] [ handle-spill ] bi ;

: expire-old-intervals ( n -- )
    pending-interval-heap get swap '[ _ < ] heap-pop-while
    [ expire-interval ] each ;

: insert-reload ( live-interval -- )
    [ reg>> ] [ reload-rep>> ] [ reload-from>> ] tri ##reload, ;

: handle-reload ( live-interval -- )
    dup reload-from>> [ insert-reload ] [ drop ] if ;

: activate-interval ( live-interval -- )
    [ add-pending ] [ handle-reload ] bi ;

: activate-new-intervals ( n -- )
    unhandled-intervals get swap '[ _ = ] heap-pop-while
    [ activate-interval ] each ;

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
    bb begin-block
    bb [
        [
            [
                {
                    [ insn#>> 1 - prepare-insn ]
                    [ insn#>> prepare-insn ]
                    [ assign-registers-in-insn ]
                    [ , ]
                } cleave
            ] each
        ] V{ } make
    ] change-instructions drop
    bb compute-live-out ;

: assign-registers ( cfg live-intervals -- )
    init-assignment
    linearization-order [ kill-block?>> not ] filter
    [ assign-registers-in-block ] each ;

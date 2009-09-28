! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math assocs namespaces sequences heaps
fry make combinators sets locals arrays
cpu.architecture
compiler.cfg
compiler.cfg.def-use
compiler.cfg.liveness
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.renaming.functor
compiler.cfg.linearization.order
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals ;
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

ERROR: bad-vreg vreg ;

: (vreg>reg) ( vreg pending -- reg )
    ! If a live vreg is not in the pending set, then it must
    ! have been spilled.
    ?at [ spill-slots get ?at [ ] [ bad-vreg ] if ] unless ;

: vreg>reg ( vreg -- reg )
    pending-interval-assoc get (vreg>reg) ;

: vregs>regs ( vregs -- assoc )
    dup assoc-empty? [
        pending-interval-assoc get
        '[ _ (vreg>reg) ] assoc-map
    ] unless ;

! Minheap of live intervals which still need a register allocation
SYMBOL: unhandled-intervals

: add-unhandled ( live-interval -- )
    dup start>> unhandled-intervals get heap-push ;

: init-unhandled ( live-intervals -- )
    [ add-unhandled ] each ;

! Mapping from basic blocks to values which are live at the start
SYMBOL: register-live-ins

! Mapping from basic blocks to values which are live at the end
SYMBOL: register-live-outs

: init-assignment ( live-intervals -- )
    <min-heap> pending-interval-heap set
    H{ } clone pending-interval-assoc set
    <min-heap> unhandled-intervals set
    H{ } clone register-live-ins set
    H{ } clone register-live-outs set
    init-unhandled ;

: insert-spill ( live-interval -- )
    [ reg>> ] [ vreg>> rep-of ] [ spill-to>> ] tri _spill ;

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
    [ reg>> ] [ vreg>> rep-of ] [ reload-from>> ] tri _reload ;

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

! TODO: needs tagged-rep

: trace-on-gc ( assoc -- assoc' )
    ! When a GC occurs, virtual registers which contain tagged data
    ! are traced by the GC. Outputs a sequence physical registers.
    [ drop rep-of int-rep eq? ] { } assoc-filter-as values ;

: spill-on-gc? ( vreg reg -- ? )
    [ rep-of int-rep? not ] [ spill-slot? not ] bi* and ;

: spill-on-gc ( assoc -- assoc' )
    ! When a GC occurs, virtual registers which contain untagged data,
    ! and are stored in physical registers, are saved to their spill
    ! slots. Outputs sequence of triples:
    ! - physical register
    ! - spill slot
    ! - representation
    [
        [
            2dup spill-on-gc?
            [ swap [ rep-of ] [ vreg-spill-slot ] bi 3array , ] [ 2drop ] if
        ] assoc-each
    ] { } make ;

M: ##gc assign-registers-in-insn
    ! Since ##gc is always the first instruction in a block, the set of
    ! values live at the ##gc is just live-in.
    dup call-next-method
    basic-block get register-live-ins get at
    [ trace-on-gc >>tagged-values ] [ spill-on-gc >>data-values ] bi
    drop ;

M: insn assign-registers-in-insn drop ;

: begin-block ( bb -- )
    dup basic-block set
    dup block-from activate-new-intervals
    [ live-in vregs>regs ] keep register-live-ins get set-at ;

: end-block ( bb -- )
    [ live-out vregs>regs ] keep register-live-outs get set-at ;

: vreg-at-start ( vreg bb -- state )
    register-live-ins get at ?at [ bad-vreg ] unless ;

: vreg-at-end ( vreg bb -- state )
    register-live-outs get at ?at [ bad-vreg ] unless ;

:: assign-registers-in-block ( bb -- )
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
            bb end-block
        ] V{ } make
    ] change-instructions drop ;

: assign-registers ( live-intervals cfg -- )
    [ init-assignment ] dip
    linearization-order [ assign-registers-in-block ] each ;

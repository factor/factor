! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math assocs namespaces sequences heaps
fry make combinators sets locals
cpu.architecture
compiler.cfg
compiler.cfg.def-use
compiler.cfg.liveness
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.linear-scan.mapping
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.assignment

! This contains both active and inactive intervals; any interval
! such that start <= insn# <= end is in this set.
SYMBOL: pending-intervals

: add-active ( live-interval -- )
    dup end>> pending-intervals get heap-push ;

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
    <min-heap> pending-intervals set
    <min-heap> unhandled-intervals set
    H{ } clone register-live-ins set
    H{ } clone register-live-outs set
    init-unhandled ;

: handle-spill ( live-interval -- )
    dup spill-to>> [
        [ reg>> ] [ spill-to>> <spill-slot> ] [ vreg>> reg-class>> ] tri
        register->memory
    ] [ drop ] if ;

: first-split ( live-interval -- live-interval' )
    dup split-before>> [ first-split ] [ ] ?if ;

: next-interval ( live-interval -- live-interval' )
    split-next>> first-split ;

: handle-copy ( live-interval -- )
    dup split-next>> [
        [ reg>> ] [ next-interval reg>> ] [ vreg>> reg-class>> ] tri
        register->register
    ] [ drop ] if ;

: (expire-old-intervals) ( n heap -- )
    dup heap-empty? [ 2drop ] [
        2dup heap-peek nip <= [ 2drop ] [
            dup heap-pop drop [ handle-spill ] [ handle-copy ] bi
            (expire-old-intervals)
        ] if
    ] if ;

: expire-old-intervals ( n -- )
    [
        pending-intervals get (expire-old-intervals)
    ] { } make mapping-instructions % ;

: insert-reload ( live-interval -- )
    {
        [ reg>> ]
        [ vreg>> reg-class>> ]
        [ reload-from>> ]
        [ start>> ]
    } cleave f swap \ _reload boa , ;

: handle-reload ( live-interval -- )
    dup reload-from>> [ insert-reload ] [ drop ] if ;

: activate-new-intervals ( n -- )
    #! Any live intervals which start on the current instruction
    #! are added to the active set.
    unhandled-intervals get dup heap-empty? [ 2drop ] [
        2dup heap-peek drop start>> = [
            heap-pop drop
            [ add-active ] [ handle-reload ] bi
            activate-new-intervals
        ] [ 2drop ] if
    ] if ;

: prepare-insn ( n -- )
    [ expire-old-intervals ] [ activate-new-intervals ] bi ;

GENERIC: assign-registers-in-insn ( insn -- )

: register-mapping ( live-intervals -- alist )
    [ [ vreg>> ] [ reg>> ] bi ] H{ } map>assoc ;

: all-vregs ( insn -- vregs )
    [ defs-vregs ] [ temp-vregs ] [ uses-vregs ] tri 3append ;

SYMBOL: check-assignment?

ERROR: overlapping-registers intervals ;

: check-assignment ( intervals -- )
    dup [ copy-from>> ] map sift '[ vreg>> _ member? not ] filter
    dup [ reg>> ] map all-unique? [ drop ] [ overlapping-registers ] if ;

: active-intervals ( n -- intervals )
    pending-intervals get heap-values [ covers? ] with filter
    check-assignment? get [ dup check-assignment ] when ;

M: vreg-insn assign-registers-in-insn
    dup [ all-vregs ] [ insn#>> active-intervals register-mapping ] bi
    extract-keys >>regs drop ;

M: ##gc assign-registers-in-insn
    ! This works because ##gc is always the first instruction
    ! in a block.
    dup call-next-method
    basic-block get register-live-ins get at >>live-values
    drop ;

M: insn assign-registers-in-insn drop ;

: compute-live-spill-slots ( vregs -- assoc )
    spill-slots get '[ _ at dup [ <spill-slot> ] when ] assoc-map ;

: compute-live-registers ( n -- assoc )
    active-intervals register-mapping ;

ERROR: bad-live-values live-values ;

: check-live-values ( assoc -- assoc )
    check-assignment? get [
        dup values [ not ] any? [ bad-live-values ] when
    ] when ;

: compute-live-values ( vregs n -- assoc )
    ! If a live vreg is not in active or inactive, then it must have been
    ! spilled.
    [ compute-live-spill-slots ] [ compute-live-registers ] bi*
    assoc-union check-live-values ;

: begin-block ( bb -- )
    dup basic-block set
    dup block-from activate-new-intervals
    [ [ live-in ] [ block-from ] bi compute-live-values ] keep
    register-live-ins get set-at ;

: end-block ( bb -- )
    [ [ live-out ] [ block-to ] bi compute-live-values ] keep
    register-live-outs get set-at ;

ERROR: bad-vreg vreg ;

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

: assign-registers ( live-intervals rpo -- )
    [ init-assignment ] dip
    [ assign-registers-in-block ] each ;

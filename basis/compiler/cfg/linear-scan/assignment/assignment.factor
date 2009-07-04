! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math assocs namespaces sequences heaps
fry make combinators sets locals
cpu.architecture
compiler.cfg.def-use
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.assignment

! This contains both active and inactive intervals; any interval
! such that start <= insn# <= end is in this set.
SYMBOL: pending-intervals

: add-active ( live-interval -- )
    pending-intervals get push ;

! Minheap of live intervals which still need a register allocation
SYMBOL: unhandled-intervals

: add-unhandled ( live-interval -- )
    dup start>> unhandled-intervals get heap-push ;

: init-unhandled ( live-intervals -- )
    [ add-unhandled ] each ;

! Mapping spill slots to vregs
SYMBOL: spill-slots

: spill-slots-for ( vreg -- assoc )
    reg-class>> spill-slots get at ;

! Mapping from basic blocks to values which are live at the start
SYMBOL: register-live-ins

! Mapping from basic blocks to values which are live at the end
SYMBOL: register-live-outs

: init-assignment ( live-intervals -- )
    V{ } clone pending-intervals set
    <min-heap> unhandled-intervals set
    [ H{ } clone ] reg-class-assoc spill-slots set
    H{ } clone register-live-ins set
    H{ } clone register-live-outs set
    init-unhandled ;

ERROR: already-spilled ;

: record-spill ( live-interval -- )
    [ dup spill-to>> ] [ vreg>> spill-slots-for ] bi
    2dup key? [ already-spilled ] [ set-at ] if ;

: insert-spill ( live-interval -- )
    {
        [ reg>> ]
        [ vreg>> reg-class>> ]
        [ spill-to>> ]
        [ end>> ]
    } cleave f swap \ _spill boa , ;

: handle-spill ( live-interval -- )
    dup spill-to>> [ [ record-spill ] [ insert-spill ] bi ] [ drop ] if ;

: first-split ( live-interval -- live-interval' )
    dup split-before>> [ first-split ] [ ] ?if ;

: next-interval ( live-interval -- live-interval' )
    split-next>> first-split ;

: insert-copy ( live-interval -- )
    {
        [ next-interval reg>> ]
        [ reg>> ]
        [ vreg>> reg-class>> ]
        [ end>> ]
    } cleave f swap \ _copy boa , ;

: handle-copy ( live-interval -- )
    dup [ spill-to>> not ] [ split-next>> ] bi and
    [ insert-copy ] [ drop ] if ;

: expire-old-intervals ( n -- )
    [ pending-intervals get ] dip '[
        dup end>> _ <
        [ [ handle-spill ] [ handle-copy ] bi f ] [ drop t ] if
    ] filter-here ;

ERROR: already-reloaded ;

: record-reload ( live-interval -- )
    [ reload-from>> ] [ vreg>> spill-slots-for ] bi
    2dup key? [ delete-at ] [ already-reloaded ] if ;

: insert-reload ( live-interval -- )
    {
        [ reg>> ]
        [ vreg>> reg-class>> ]
        [ reload-from>> ]
        [ end>> ]
    } cleave f swap \ _reload boa , ;

: handle-reload ( live-interval -- )
    dup reload-from>> [ [ record-reload ] [ insert-reload ] bi ] [ drop ] if ;

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
    pending-intervals get [ covers? ] with filter
    check-assignment? get [
        dup check-assignment
    ] when ;

M: vreg-insn assign-registers-in-insn
    dup [ insn#>> active-intervals ] [ all-vregs ] bi
    '[ vreg>> _ member? ] filter
    register-mapping
    >>regs drop ;

: compute-live-registers ( n -- assoc )
    active-intervals register-mapping ;

: compute-live-spill-slots ( -- assocs )
    spill-slots get values first2
    [ [ vreg>> swap <spill-slot> ] H{ } assoc-map-as ] bi@
    assoc-union ;

: compute-live-values ( n -- assoc )
    [ compute-live-spill-slots ] dip compute-live-registers
    assoc-union ;

: compute-live-gc-values ( insn -- assoc )
    [ insn#>> compute-live-values ] [ temp-vregs ] bi
    '[ drop _ memq? not ] assoc-filter ;

M: ##gc assign-registers-in-insn
    dup call-next-method
    dup compute-live-gc-values >>live-values
    drop ;

M: insn assign-registers-in-insn drop ;

: begin-block ( bb -- )
    dup block-from prepare-insn
    [ block-from compute-live-values ] keep register-live-ins get set-at ;

: end-block ( bb -- )
    [ block-to compute-live-values ] keep register-live-outs get set-at ;

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
                [ insn#>> prepare-insn ]
                [ assign-registers-in-insn ]
                [ , ]
                tri
            ] each
            bb end-block
        ] V{ } make
    ] change-instructions drop ;

: assign-registers ( live-intervals rpo -- )
    [ init-assignment ] dip
    [ assign-registers-in-block ] each ;

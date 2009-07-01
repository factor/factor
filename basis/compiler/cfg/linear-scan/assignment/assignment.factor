! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math assocs namespaces sequences heaps
fry make combinators sets
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

GENERIC: assign-registers-in-insn ( insn -- )

: register-mapping ( live-intervals -- alist )
    [ [ vreg>> ] [ reg>> ] bi ] { } map>assoc ;

: all-vregs ( insn -- vregs )
    [ defs-vregs ] [ temp-vregs ] [ uses-vregs ] tri 3append ;

SYMBOL: check-assignment?

ERROR: overlapping-registers intervals ;

: check-assignment ( intervals -- )
    dup [ copy-from>> ] map sift '[ vreg>> _ member? not ] filter
    dup [ reg>> ] map all-unique? [ drop ] [ overlapping-registers ] if ;

: active-intervals ( insn -- intervals )
    insn#>> pending-intervals get [ covers? ] with filter
    check-assignment? get [
        dup check-assignment
    ] when ;

M: vreg-insn assign-registers-in-insn
    dup [ active-intervals ] [ all-vregs ] bi
    '[ vreg>> _ member? ] filter
    register-mapping
    >>regs drop ;

: compute-live-registers ( insn -- regs )
    [ active-intervals ] [ temp-vregs ] bi
    '[ vreg>> _ memq? not ] filter
    register-mapping ;

: compute-live-spill-slots ( -- spill-slots )
    spill-slots get values [ values ] map concat
    [ [ vreg>> ] [ reload-from>> ] bi ] { } map>assoc ;

M: ##gc assign-registers-in-insn
    dup call-next-method
    dup compute-live-registers >>live-registers
    compute-live-spill-slots >>live-spill-slots
    drop ;

M: insn assign-registers-in-insn drop ;

: init-assignment ( live-intervals -- )
    V{ } clone pending-intervals set
    <min-heap> unhandled-intervals set
    [ H{ } clone ] reg-class-assoc spill-slots set 
    init-unhandled ;

: assign-registers-in-block ( bb -- )
    [
        [
            [
                [
                    insn#>>
                    [ expire-old-intervals ]
                    [ activate-new-intervals ]
                    bi
                ]
                [ assign-registers-in-insn ]
                [ , ]
                tri
            ] each
        ] V{ } make
    ] change-instructions drop ;

: assign-registers ( live-intervals rpo -- )
    [ init-assignment ] dip
    [ assign-registers-in-block ] each ;

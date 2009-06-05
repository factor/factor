! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math assocs namespaces sequences heaps
fry make combinators
cpu.architecture
compiler.cfg.def-use
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.assignment

! A vector of live intervals. There is linear searching involved
! but since we never have too many machine registers (around 30
! at most) and we probably won't have that many live at any one
! time anyway, it is not a problem to check each element.
TUPLE: active-intervals seq ;

: add-active ( live-interval -- )
    active-intervals get seq>> push ;

: lookup-register ( vreg -- reg )
    active-intervals get seq>> [ vreg>> = ] with find nip reg>> ;

! Minheap of live intervals which still need a register allocation
SYMBOL: unhandled-intervals

: add-unhandled ( live-interval -- )
    dup start>> unhandled-intervals get heap-push ;

: init-unhandled ( live-intervals -- )
    [ add-unhandled ] each ;

: insert-spill ( live-interval -- )
    [ reg>> ] [ vreg>> reg-class>> ] [ spill-to>> ] tri
    dup [ _spill ] [ 3drop ] if ;

: expire-old-intervals ( n -- )
    active-intervals get
    [ swap '[ end>> _ = ] partition ] change-seq drop
    [ insert-spill ] each ;

: insert-reload ( live-interval -- )
    [ reg>> ] [ vreg>> reg-class>> ] [ reload-from>> ] tri
    dup [ _reload ] [ 3drop ] if ;

: activate-new-intervals ( n -- )
    #! Any live intervals which start on the current instruction
    #! are added to the active set.
    unhandled-intervals get dup heap-empty? [ 2drop ] [
        2dup heap-peek drop start>> = [
            heap-pop drop [ add-active ] [ insert-reload ] bi
            activate-new-intervals
        ] [ 2drop ] if
    ] if ;

GENERIC: assign-before ( insn -- )

GENERIC: assign-after ( insn -- )

: all-vregs ( insn -- vregs )
    [ defs-vregs ] [ temp-vregs ] [ uses-vregs ] tri 3append ;

M: vreg-insn assign-before
    active-intervals get seq>> over all-vregs '[ vreg>> _ member? ] filter
    [ [ vreg>> ] [ reg>> ] bi ] { } map>assoc
    >>regs drop ;

M: insn assign-before drop ;

: compute-live-registers ( -- regs )
    active-intervals get seq>> [ [ vreg>> ] [ reg>> ] bi ] { } map>assoc ;

: compute-live-spill-slots ( -- spill-slots )
    unhandled-intervals get
    heap-values [ reload-from>> ] filter
    [ [ vreg>> ] [ reload-from>> ] bi ] { } map>assoc ;

M: ##gc assign-after
    compute-live-registers >>live-registers
    compute-live-spill-slots >>live-spill-slots
    drop ;

M: insn assign-after drop ;

: <active-intervals> ( -- obj )
    V{ } clone active-intervals boa ;

: init-assignment ( live-intervals -- )
    <active-intervals> active-intervals set
    <min-heap> unhandled-intervals set
    init-unhandled ;

: assign-registers-in-block ( bb -- )
    [
        [
            [
                {
                    [ insn#>> activate-new-intervals ]
                    [ assign-before ]
                    [ , ]
                    [ insn#>> expire-old-intervals ]
                    [ assign-after ]
                } cleave
            ] each
        ] V{ } make
    ] change-instructions drop ;

: assign-registers ( rpo live-intervals -- )
    init-assignment
    [ assign-registers-in-block ] each ;

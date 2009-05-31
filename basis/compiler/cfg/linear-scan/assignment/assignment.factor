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
    dup split-before>> [
        [ split-before>> ] [ split-after>> ] bi
        [ add-unhandled ] bi@
    ] [
        dup start>> unhandled-intervals get heap-push
    ] if ;

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

GENERIC: assign-registers-in-insn ( insn -- )

: all-vregs ( insn -- vregs )
    [ defs-vregs ] [ temp-vregs ] [ uses-vregs ] tri 3append ;

M: vreg-insn assign-registers-in-insn
    active-intervals get seq>> over all-vregs '[ vreg>> _ member? ] filter
    [ [ vreg>> ] [ reg>> ] bi ] { } map>assoc
    >>regs drop ;

M: insn assign-registers-in-insn drop ;

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
                [ insn#>> activate-new-intervals ]
                [ [ assign-registers-in-insn ] [ , ] bi ]
                [ insn#>> expire-old-intervals ]
                tri
            ] each
        ] V{ } make
    ] change-instructions drop ;

: assign-registers ( rpo live-intervals -- )
    init-assignment
    [ assign-registers-in-block ] each ;

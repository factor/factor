! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
kernel math namespaces sequences locals compiler.cfg.def-use
compiler.cfg.dominance compiler.cfg.ssa.destruction.live-ranges ;
IN: compiler.cfg.ssa.destruction.interference

<PRIVATE

: kill-after-def? ( vreg1 vreg2 bb -- ? )
    ! If first register is used after second one is defined, they interfere.
    ! If they are used in the same instruction, no interference. If the
    ! instruction is a def-is-use-insn, then there will be a use at +1
    ! (instructions are 2 apart) and so outputs will interfere with
    ! inputs.
    [ kill-index ] [ def-index ] bi-curry bi* > ;

: interferes-same-block? ( vreg1 vreg2 bb1 bb2 -- ? )
    ! If both are defined in the same basic block, they interfere if their
    ! local live ranges intersect.
    drop
    { [ kill-after-def? ] [ swapd kill-after-def? ] } 3|| ;

: interferes-first-dominates? ( vreg1 vreg2 bb1 bb2 -- ? )
    ! If vreg1 dominates vreg2, then they interfere if vreg2's definition
    ! occurs before vreg1 is killed.
    nip
    kill-after-def? ;

: interferes-second-dominates? ( vreg1 vreg2 bb1 bb2 -- ? )
    ! If vreg2 dominates vreg1, then they interfere if vreg1's definition
    ! occurs before vreg2 is killed.
    drop
    swapd kill-after-def? ;

PRIVATE>

: interferes? ( vreg1 vreg2 -- ? )
    2dup [ def-of ] bi@ {
        { [ 2dup eq? ] [ interferes-same-block? ] }
        { [ 2dup dominates? ] [ interferes-first-dominates? ] }
        { [ 2dup swap dominates? ] [ interferes-second-dominates? ] }
        [ 2drop 2drop f ]
    } cond ;

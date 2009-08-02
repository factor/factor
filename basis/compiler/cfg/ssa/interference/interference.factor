! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit fry
kernel math math.order sorting namespaces sequences locals
compiler.cfg.def-use compiler.cfg.dominance
compiler.cfg.ssa.interference.live-ranges ;
IN: compiler.cfg.ssa.interference

<PRIVATE

:: kill-after-def? ( vreg1 vreg2 bb -- ? )
    ! If first register is used after second one is defined, they interfere.
    ! If they are used in the same instruction, no interference. If the
    ! instruction is a def-is-use-insn, then there will be a use at +1
    ! (instructions are 2 apart) and so outputs will interfere with
    ! inputs.
    vreg1 bb kill-index
    vreg2 bb def-index > ;

:: interferes-same-block? ( vreg1 vreg2 bb1 bb2 -- ? )
    ! If both are defined in the same basic block, they interfere if their
    ! local live ranges intersect.
    vreg1 bb1 def-index
    vreg2 bb1 def-index <
    [ vreg1 vreg2 ] [ vreg2 vreg1 ] if
    bb1 kill-after-def? ;

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

: vregs-interfere? ( vreg1 vreg2 -- ? )
    2dup [ def-of ] bi@ {
        { [ 2dup eq? ] [ interferes-same-block? ] }
        { [ 2dup dominates? ] [ interferes-first-dominates? ] }
        { [ 2dup swap dominates? ] [ interferes-second-dominates? ] }
        [ 2drop 2drop f ]
    } cond ;

! Debug this stuff later
<PRIVATE

: quadratic-test? ( seq1 seq2 -- ? ) [ length ] bi@ + 10 < ;

: quadratic-test ( seq1 seq2 -- ? )
    '[ _ [ vregs-interfere? ] with any? ] any? ;

: sort-vregs-by-bb ( vregs -- alist )
    defs get
    '[ dup _ at ] { } map>assoc
    [ [ second pre-of ] compare ] sort ;

: ?last ( seq -- elt/f ) [ f ] [ last ] if-empty ; inline

: find-parent ( dom current -- parent )
    over empty? [ 2drop f ] [
        over last over dominates? [ drop last ] [
            over pop* find-parent
        ] if
    ] if ;

:: linear-test ( seq1 seq2 -- ? )
    ! Instead of sorting, SSA destruction should keep equivalence
    ! classes sorted by merging them on append
    V{ } clone :> dom
    seq1 seq2 append sort-vregs-by-bb [| pair |
        pair first :> current
        dom current find-parent
        dup [ current vregs-interfere? ] when
        [ t ] [ current dom push f ] if
    ] any? ;

PRIVATE>

: sets-interfere? ( seq1 seq2 -- ? )
    quadratic-test ;
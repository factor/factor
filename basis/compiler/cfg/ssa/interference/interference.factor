! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
compiler.cfg.dominance compiler.cfg.ssa.interference.live-ranges
kernel locals math math.order sequences sorting.specification ;
IN: compiler.cfg.ssa.interference

TUPLE: vreg-info vreg value def-index bb pre-of color equal-anc-in equal-anc-out ;

:: <vreg-info> ( vreg value bb -- info )
    vreg-info new
        vreg >>vreg
        bb >>bb
        value >>value
        bb pre-of >>pre-of
        vreg bb def-index >>def-index ;

<PRIVATE

! Our dominance pass computes dominance information on a
! per-basic block level. Rig up a more fine-grained dominance
! test here.
: locally-dominates? ( vreg1 vreg2 -- ? )
    [ def-index>> ] bi@ < ;

:: vreg-dominates? ( vreg1 vreg2 -- ? )
    vreg1 bb>> :> bb1
    vreg2 bb>> :> bb2
    bb1 bb2 eq?
    [ vreg1 vreg2 locally-dominates? ] [ bb1 bb2 dominates? ] if ;

! Testing individual vregs for live range intersection.
: kill-after-def? ( vreg1 vreg2 bb -- ? )
    ! If first register is used after second one is defined, they interfere.
    ! If they are used in the same instruction, no interference. If the
    ! instruction is a def-is-use-insn, then there will be a use at +1
    ! (instructions are 2 apart) and so outputs will interfere with
    ! inputs.
    [ kill-index ] [ def-index ] bi-curry bi* > ;

: interferes-first-dominates? ( vreg1 vreg2 -- ? )
    ! If vreg1 dominates vreg2, then they interfere if vreg2's definition
    ! occurs before vreg1 is killed.
    [ [ vreg>> ] bi@ ] [ nip bb>> ] 2bi kill-after-def? ;

: interferes-second-dominates? ( vreg1 vreg2 -- ? )
    ! If vreg2 dominates vreg1, then they interfere if vreg1's definition
    ! occurs before vreg2 is killed.
    swap interferes-first-dominates? ;

: interferes-same-block? ( vreg1 vreg2 -- ? )
    ! If both are defined in the same basic block, they interfere if their
    ! local live ranges intersect.
    2dup locally-dominates? [ swap ] unless
    interferes-first-dominates? ;

:: vregs-intersect? ( vreg1 vreg2 -- ? )
    vreg1 bb>> :> bb1
    vreg2 bb>> :> bb2
    {
        { [ bb1 bb2 eq? ] [ vreg1 vreg2 interferes-same-block? ] }
        { [ bb1 bb2 dominates? ] [ vreg1 vreg2 interferes-first-dominates? ] }
        { [ bb2 bb1 dominates? ] [ vreg1 vreg2 interferes-second-dominates? ] }
        [ f ]
    } cond ;

! Value-based interference test.
: chain-intersect ( vreg1 vreg2 -- vreg )
    [ 2dup { [ nip ] [ vregs-intersect? not ] } 2&& ]
    [ equal-anc-in>> ]
    while nip ;

: update-equal-anc-out ( vreg1 vreg2 -- )
    dupd chain-intersect >>equal-anc-out drop ;

: same-sets? ( vreg1 vreg2 -- ? )
    [ color>> ] bi@ eq? ;

: same-values? ( vreg1 vreg2 -- ? )
    [ value>> ] bi@ eq? ;

: vregs-interfere? ( vreg1 vreg2 -- ? )
    [ f >>equal-anc-out ] dip

    2dup same-sets? [ equal-anc-out>> ] when

    2dup same-values?
    [ update-equal-anc-out f ] [ chain-intersect >boolean ] if ;

! Merging lists of vregs sorted by dominance.
M: vreg-info <=> ( vreg1 vreg2 -- <=> )
    { { pre-of>> <=> } { def-index>> <=> } } compare-with-spec ;

SYMBOLS: blue red ;

TUPLE: iterator seq n ;
: <iterator> ( seq -- iterator ) 0 iterator boa ; inline
: done? ( iterator -- ? ) [ seq>> length ] [ n>> ] bi = ; inline
: this ( iterator -- obj ) [ n>> ] [ seq>> ] bi nth ; inline
: ++ ( iterator -- ) [ 1 + ] change-n drop ; inline
: take ( iterator -- obj ) [ this ] [ ++ ] bi ; inline

: blue-smaller? ( blue red -- ? )
    [ this ] bi@ before? ; inline

: take-blue? ( blue red -- ? )
    {
        [ nip done? ]
        [
            {
                [ drop done? not ]
                [ blue-smaller? ]
            } 2&&
        ]
    } 2|| ; inline

: merge-sets ( blue red -- seq )
    [ <iterator> ] bi@
    [ 2dup [ done? ] both? not ]
    [
        2dup take-blue?
        [ over take blue >>color ]
        [ dup take red >>color ]
        if
    ] produce 2nip ;

: update-for-merge ( seq -- )
    [
        dup [ equal-anc-in>> ] [ equal-anc-out>> ] bi
        2dup and [ [ vreg-dominates? ] most ] [ or ] if
        >>equal-anc-in
        drop
    ] each ;

! Linear-time live range intersection test in a merged set.
: find-parent ( dom current -- vreg )
    over empty? [ 2drop f ] [
        over last over vreg-dominates?
        [ drop last ] [ over pop* find-parent ] if
    ] if ;

:: linear-interference-test ( seq -- ? )
    V{ } clone :> dom
    seq [| vreg |
        dom vreg find-parent
        { [ ] [ vreg same-sets? not ] [ vreg swap vregs-interfere? ] } 1&&
        [ t ] [ vreg dom push f ] if
    ] any? ;

: sets-interfere-1? ( seq1 seq2 -- merged/f ? )
    [ first ] bi@
    2dup before? [ swap ] unless
    2dup same-values? [
        2dup equal-anc-in<<
        2array f
    ] [
        2dup vregs-intersect?
        [ 2drop f t ] [ 2array f ] if
    ] if ;

PRIVATE>

: sets-interfere? ( seq1 seq2 -- merged/f ? )
    2dup [ length 1 = ] both? [ sets-interfere-1? ] [
        merge-sets dup linear-interference-test
        [ drop f t ] [ dup update-for-merge f ] if
    ] if ;

! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel accessors sequences fry assocs
sets math combinators deques dlists
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.registers
compiler.cfg.dominance
compiler.cfg.instructions
compiler.cfg.renaming
compiler.cfg.renaming.functor
compiler.cfg.ssa.construction.tdmsc ;
FROM: assocs => change-at ;
FROM: namespaces => set ;
IN: compiler.cfg.ssa.construction

! Iterated dominance frontiers are computed using the DJ Graph
! method in compiler.cfg.ssa.construction.tdmsc.

! The renaming algorithm is based on "Practical Improvements to
! the Construction and Destruction of Static Single Assignment
! Form".

! We construct pruned SSA without computing live sets, by
! building a dependency graph for phi instructions, marking the
! transitive closure of a vertex as live if it is referenced by
! some non-phi instruction. Thanks to Cameron Zwarich for the
! trick.

! http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.49.9683

<PRIVATE

! Maps vregs to sets of basic blocks
SYMBOL: defs

! Set of vregs defined in more than one basic block
SYMBOL: defs-multi

GENERIC: compute-insn-defs ( bb insn -- )

M: insn compute-insn-defs 2drop ;

M: vreg-insn compute-insn-defs
    defs-vregs [
        defs get [ adjoin-at ] [ drop ] [ at cardinality 1 > ] 2tri
        [ defs-multi get adjoin ] [ drop ] if
    ] with each ;

: compute-defs ( cfg -- )
    H{ } clone defs set
    HS{ } clone defs-multi set
    [
        [ basic-block get ] dip
        [ compute-insn-defs ] with each
    ] simple-analysis ;

! Maps basic blocks to sequences of ##phi instructions
SYMBOL: inserting-phis

: insert-phi-later ( vreg bb -- )
    [ predecessors>> over '[ _ ] H{ } map>assoc ##phi new-insn ] keep
    inserting-phis get push-at ;

: compute-phis-for ( vreg bbs -- )
    members merge-set [ insert-phi-later ] with each ;

: compute-phis ( -- )
    H{ } clone inserting-phis set
    defs-multi get members
    defs get '[ dup _ at compute-phis-for ] each ;

! Maps vregs to ##phi instructions
SYMBOL: phis

! Worklist of used vregs, to calculate used phis
SYMBOL: used-vregs

! Maps vregs to renaming stacks
SYMBOLS: stacks pushed ;

: init-renaming ( -- )
    H{ } clone phis set
    <hashed-dlist>  used-vregs set
    H{ } clone stacks set ;

: gen-name ( vreg -- vreg' )
    [ next-vreg dup ] dip
    dup pushed get ?adjoin
    [ stacks get push-at ]
    [ stacks get at set-last ]
    if ;

: (top-name) ( vreg -- vreg' )
    stacks get at ?last ;

: top-name ( vreg -- vreg' )
    (top-name)
    dup [ dup used-vregs get push-front ] when ;

RENAMING: ssa-rename [ gen-name ] [ top-name ] [ ]

GENERIC: rename-insn ( insn -- )

M: insn rename-insn drop ;

M: vreg-insn rename-insn
    [ ssa-rename-insn-uses ]
    [ ssa-rename-insn-defs ]
    bi ;

: rename-phis ( bb -- )
    inserting-phis get at [
        [
            [ ssa-rename-insn-defs ]
            [ dup dst>> phis get set-at ] bi
        ] each
    ] when* ;

: rename-insns ( bb -- )
    instructions>> [ rename-insn ] each ;

: rename-successor-phi ( phi bb -- )
    swap inputs>> [ (top-name) ] change-at ;

: rename-successor-phis ( succ bb -- )
    [ inserting-phis get at ] dip
    '[ _ rename-successor-phi ] each ;

: rename-successors-phis ( bb -- )
    [ successors>> ] keep '[ _ rename-successor-phis ] each ;

: pop-stacks ( -- )
    pushed get members stacks get '[ _ at pop* ] each ;

: rename-in-block ( bb -- )
    HS{ } clone pushed set
    {
        [ rename-phis ]
        [ rename-insns ]
        [ rename-successors-phis ]
        [
            pushed get
            [ dom-children [ rename-in-block ] each ] dip
            pushed set
        ]
    } cleave
    pop-stacks ;

: rename ( cfg -- )
    init-renaming
    entry>> rename-in-block ;

! Live phis
SYMBOL: live-phis

: live-phi? ( ##phi -- ? )
    dst>> live-phis get in? ;

: compute-live-phis ( -- )
    HS{ } clone live-phis set
    used-vregs get [
        phis get at [
            [
                dst>>
                [ live-phis get adjoin ]
                [ phis get delete-at ]
                bi
            ]
            [ inputs>> [ nip used-vregs get push-front ] assoc-each ] bi
        ] when*
    ] slurp-deque ;

: insert-phis-in ( phis bb -- )
    [ [ live-phi? ] filter! ] dip
    [ append ] change-instructions drop ;

: insert-phis ( -- )
    inserting-phis get
    [ swap insert-phis-in ] assoc-each ;

PRIVATE>

: construct-ssa ( cfg -- cfg' )
    {
        [ compute-merge-sets ]
        [ compute-defs compute-phis ]
        [ rename compute-live-phis insert-phis ]
        [ ]
    } cleave ;

! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel accessors sequences fry assocs
sets math combinators
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.liveness
compiler.cfg.registers
compiler.cfg.dominance
compiler.cfg.instructions
compiler.cfg.renaming
compiler.cfg.renaming.functor
compiler.cfg.ssa.construction.tdmsc ;
FROM: namespaces => set ;
IN: compiler.cfg.ssa.construction

! The phi placement algorithm is implemented in
! compiler.cfg.ssa.construction.tdmsc.

! The renaming algorithm is based on "Practical Improvements to
! the Construction and Destruction of Static Single Assignment Form",
! however we construct pruned SSA, not semi-pruned SSA.

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
        defs get [ conjoin-at ] [ drop ] [ at assoc-size 1 > ] 2tri
        [ defs-multi get conjoin ] [ drop ] if
    ] with each ;

: compute-defs ( cfg -- )
    H{ } clone defs set
    H{ } clone defs-multi set
    [
        [ basic-block get ] dip
        [ compute-insn-defs ] with each
    ] simple-analysis ;

! Maps basic blocks to sequences of vregs
SYMBOL: inserting-phi-nodes

: insert-phi-node-later ( vreg bb -- )
    2dup live-in key? [
        [ predecessors>> over '[ _ ] H{ } map>assoc \ ##phi new-insn ] keep
        inserting-phi-nodes get push-at
    ] [ 2drop ] if ;

: compute-phi-nodes-for ( vreg bbs -- )
    keys merge-set [ insert-phi-node-later ] with each ;

: compute-phi-nodes ( -- )
    H{ } clone inserting-phi-nodes set
    defs-multi get defs get '[ _ at compute-phi-nodes-for ] assoc-each ;

: insert-phi-nodes-in ( phis bb -- )
    [ append ] change-instructions drop ;

: insert-phi-nodes ( -- )
    inserting-phi-nodes get [ swap insert-phi-nodes-in ] assoc-each ;

SYMBOLS: stacks pushed ;

: init-renaming ( -- )
    H{ } clone stacks set ;

: gen-name ( vreg -- vreg' )
    [ next-vreg dup ] dip
    dup pushed get 2dup key?
    [ 2drop stacks get at set-last ]
    [ conjoin stacks get push-at ]
    if ;

: top-name ( vreg -- vreg' )
    stacks get at last ;

RENAMING: ssa-rename [ gen-name ] [ top-name ] [ ]

GENERIC: rename-insn ( insn -- )

M: insn rename-insn drop ;

M: vreg-insn rename-insn
    [ ssa-rename-insn-uses ]
    [ ssa-rename-insn-defs ]
    bi ;

M: ##phi rename-insn
    ssa-rename-insn-defs ;

: rename-insns ( bb -- )
    instructions>> [ rename-insn ] each ;

: rename-successor-phi ( phi bb -- )
    swap inputs>> [ top-name ] change-at ;

: rename-successor-phis ( succ bb -- )
    [ inserting-phi-nodes get at ] dip
    '[ _ rename-successor-phi ] each ;

: rename-successors-phis ( bb -- )
    [ successors>> ] keep '[ _ rename-successor-phis ] each ;

: pop-stacks ( -- )
    pushed get stacks get '[ drop _ at pop* ] assoc-each ;

: rename-in-block ( bb -- )
    H{ } clone pushed set
    [ rename-insns ]
    [ rename-successors-phis ]
    [
        pushed get
        [ dom-children [ rename-in-block ] each ] dip
        pushed set
    ] tri
    pop-stacks ;

: rename ( cfg -- )
    init-renaming
    entry>> rename-in-block ;

PRIVATE>

: construct-ssa ( cfg -- cfg' )
    {
        [ compute-live-sets ]
        [ compute-merge-sets ]
        [ compute-defs compute-phi-nodes insert-phi-nodes ]
        [ rename ]
        [ ]
    } cleave ;

! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel accessors sequences fry assocs
sets math combinators
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.renaming
compiler.cfg.liveness
compiler.cfg.registers
compiler.cfg.dominance
compiler.cfg.instructions ;
IN: compiler.cfg.ssa

! SSA construction. Predecessors must be computed first.

! This is the classical algorithm based on dominance frontiers, except
! we consult liveness information to build pruned SSA:
! http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.25.8240

! Eventually might be worth trying something fancier:
! http://portal.acm.org/citation.cfm?id=1065887.1065890

<PRIVATE

! Maps vreg to sequence of basic blocks
SYMBOL: defs

! Maps basic blocks to sequences of vregs
SYMBOL: inserting-phi-nodes

: compute-defs ( cfg -- )
    H{ } clone dup defs set
    '[
        dup instructions>> [
            defs-vregs [
                _ conjoin-at
            ] with each
        ] with each
    ] each-basic-block ;

: insert-phi-node-later ( vreg bb -- )
    2dup live-in key? [
        [ predecessors>> over '[ _ ] H{ } map>assoc \ ##phi new-insn ] keep
        inserting-phi-nodes get push-at
    ] [ 2drop ] if ;

: compute-phi-nodes-for ( vreg bbs -- )
    keys dup length 2 >= [
        iterated-dom-frontier [
            insert-phi-node-later
        ] with each
    ] [ 2drop ] if ;

: compute-phi-nodes ( -- )
    H{ } clone inserting-phi-nodes set
    defs get [ compute-phi-nodes-for ] assoc-each ;

: insert-phi-nodes-in ( phis bb -- )
    [ append ] change-instructions drop ;

: insert-phi-nodes ( -- )
    inserting-phi-nodes get [ swap insert-phi-nodes-in ] assoc-each ;

SYMBOLS: stacks originals ;

: init-renaming ( -- )
    H{ } clone stacks set
    H{ } clone originals set ;

: gen-name ( vreg -- vreg' )
    [ reg-class>> next-vreg ] keep
    [ stacks get push-at ]
    [ swap originals get set-at ]
    [ drop ]
    2tri ;

: top-name ( vreg -- vreg' )
    stacks get at last ;

GENERIC: rename-insn ( insn -- )

M: insn rename-insn
    [ dup uses-vregs [ dup top-name ] { } map>assoc renamings set rename-insn-uses ]
    [ dup defs-vregs [ dup gen-name ] { } map>assoc renamings set rename-insn-defs ]
    bi ;

M: ##phi rename-insn
    dup defs-vregs [ dup gen-name ] { } map>assoc renamings set rename-insn-defs ;

: rename-insns ( bb -- )
    instructions>> [ rename-insn ] each ;

: rename-successor-phi ( phi bb -- )
    swap inputs>> [ top-name ] change-at ;

: rename-successor-phis ( succ bb -- )
    [ inserting-phi-nodes get at ] dip
    '[ _ rename-successor-phi ] each ;

: rename-successors-phis ( bb -- )
    [ successors>> ] keep '[ _ rename-successor-phis ] each ;

: pop-stacks ( bb -- )
    instructions>> [
        defs-vregs originals get stacks get
        '[ _ at _ at pop* ] each
    ] each ;

: rename-in-block ( bb -- )
    {
        [ rename-insns ]
        [ rename-successors-phis ]
        [ dom-children [ rename-in-block ] each ]
        [ pop-stacks ]
    } cleave ;

: rename ( cfg -- )
    init-renaming
    entry>> rename-in-block ;

PRIVATE>

: construct-ssa ( cfg -- cfg' )
    {
        [ ]
        [ compute-live-sets ]
        [ compute-dominance ]
        [ compute-defs compute-phi-nodes insert-phi-nodes ]
        [ rename ]
    } cleave ;
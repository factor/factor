! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel accessors sequences fry dlists
deques assocs sets math combinators sorting
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.renaming
compiler.cfg.registers
compiler.cfg.dominance
compiler.cfg.instructions ;
IN: compiler.cfg.ssa

! SSA construction. Predecessors and dominance must be computed first.

! This is the classical algorithm based on dominance frontiers:
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
                _ push-at
            ] with each
        ] with each
    ] each-basic-block ;

SYMBOLS: has-already ever-on-work-list work-list ;

: init-insert-phi-nodes ( bbs -- )
    H{ } clone has-already set
    [ unique ever-on-work-list set ]
    [ <hashed-dlist> [ push-all-front ] keep work-list set ] bi ;

: add-to-work-list ( bb -- )
    dup ever-on-work-list get key? [ drop ] [
        [ ever-on-work-list get conjoin ]
        [ work-list get push-front ]
        bi
    ] if ;

: insert-phi-node-later ( vreg bb -- )
    [ predecessors>> over '[ _ ] H{ } map>assoc \ ##phi new-insn ] keep
    inserting-phi-nodes get push-at ;

: compute-phi-node-in ( vreg bb -- )
    dup has-already get key? [ 2drop ] [
        [ insert-phi-node-later ]
        [ has-already get conjoin ]
        [ add-to-work-list ]
        tri
    ] if ;

: compute-phi-nodes-for ( vreg bbs -- )
    dup length 2 >= [
        init-insert-phi-nodes
        work-list get [
            dom-frontier [
                compute-phi-node-in
            ] with each
        ] with slurp-deque
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
    dup [ compute-defs compute-phi-nodes insert-phi-nodes ] [ rename ] bi ;
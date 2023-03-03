! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg
compiler.cfg.def-use compiler.cfg.dominance
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.renaming.functor compiler.cfg.rpo
compiler.cfg.ssa.construction.tdmsc deques dlists fry kernel
math namespaces sequences sets ;
IN: compiler.cfg.ssa.construction

<PRIVATE

SYMBOL: defs

SYMBOL: defs-multi

GENERIC: compute-insn-defs ( bb insn -- )

M: insn compute-insn-defs 2drop ;

M: vreg-insn compute-insn-defs
    defs-vregs [
        defs get [ adjoin-at ] [ drop ] [ at cardinality 1 > ] 2tri
        [ defs-multi get adjoin ] [ drop ] if
    ] with each ;

: compute-defs ( cfg -- )
    H{ } clone defs namespaces:set
    HS{ } clone defs-multi namespaces:set
    [
        [ basic-block get ] dip
        [ compute-insn-defs ] with each
    ] simple-analysis ;

SYMBOL: inserting-phis

: <##phi> ( vreg bb -- ##phi )
    predecessors>> over '[ _ ] H{ } map>assoc ##phi new-insn ;

: insert-phi-later ( vreg bb -- )
    [ <##phi> ] keep inserting-phis get push-at ;

: compute-phis-for ( vreg bbs -- )
    members merge-set [ insert-phi-later ] with each ;

: compute-phis ( -- )
    H{ } clone inserting-phis namespaces:set
    defs-multi get members
    defs get '[ dup _ at compute-phis-for ] each ;

SYMBOL: phis

SYMBOL: used-vregs

SYMBOLS: stacks pushed ;

: init-renaming ( -- )
    H{ } clone phis namespaces:set
    <hashed-dlist>  used-vregs namespaces:set
    H{ } clone stacks namespaces:set ;

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
    [ dup used-vregs get push-front ] ?call ;

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
    HS{ } clone pushed namespaces:set
    {
        [ rename-phis ]
        [ rename-insns ]
        [ rename-successors-phis ]
        [
            pushed get
            [ dom-children [ rename-in-block ] each ] dip
            pushed namespaces:set
        ]
    } cleave
    pop-stacks ;

: rename ( cfg -- )
    init-renaming entry>> rename-in-block ;

! Live phis
SYMBOL: live-phis

: live-phi? ( ##phi -- ? )
    dst>> live-phis get in? ;

: compute-live-phis ( -- )
    HS{ } clone live-phis namespaces:set
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

: insert-phis ( inserting-phis -- )
    [ swap insert-phis-in ] assoc-each ;

PRIVATE>

: construct-ssa ( cfg -- )
    [ compute-merge-sets ]
    [ compute-defs compute-phis ]
    [ rename compute-live-phis inserting-phis get insert-phis ] tri ;

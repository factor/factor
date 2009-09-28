! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry kernel namespaces
sequences sequences.deep
sets vectors
cpu.architecture
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.renaming
compiler.cfg.registers
compiler.cfg.dominance
compiler.cfg.instructions
compiler.cfg.liveness.ssa
compiler.cfg.ssa.cssa
compiler.cfg.ssa.interference
compiler.cfg.ssa.interference.live-ranges
compiler.cfg.utilities
compiler.utilities ;
IN: compiler.cfg.ssa.destruction

! Maps vregs to leaders.
SYMBOL: leader-map

: leader ( vreg -- vreg' ) leader-map get compress-path ;

! Maps leaders to equivalence class elements.
SYMBOL: class-element-map

: class-elements ( vreg -- elts ) class-element-map get at ;

! Sequence of vreg pairs
SYMBOL: copies

: init-coalescing ( -- )
    H{ } clone leader-map set
    H{ } clone class-element-map set
    V{ } clone copies set ;

: classes-interfere? ( vreg1 vreg2 -- ? )
    [ leader ] bi@ 2dup eq? [ 2drop f ] [
        [ class-elements flatten ] bi@ sets-interfere?
    ] if ;

: update-leaders ( vreg1 vreg2 -- )
    swap leader-map get set-at ;

: merge-classes ( vreg1 vreg2 -- )
    [ [ class-elements ] bi@ push ]
    [ drop class-element-map get delete-at ] 2bi ;

: eliminate-copy ( vreg1 vreg2 -- )
    [ leader ] bi@
    2dup eq? [ 2drop ] [
        [ update-leaders ]
        [ merge-classes ]
        2bi
    ] if ;

: introduce-vreg ( vreg -- )
    [ leader-map get conjoin ]
    [ [ 1vector ] keep class-element-map get set-at ] bi ;

GENERIC: prepare-insn ( insn -- )

: try-to-coalesce ( dst src -- ) 2array copies get push ;

M: insn prepare-insn
    [ defs-vreg ] [ uses-vregs ] bi
    2dup empty? not and [
        first 
        2dup [ rep-of reg-class-of ] bi@ eq?
        [ try-to-coalesce ] [ 2drop ] if
    ] [ 2drop ] if ;

M: ##copy prepare-insn
    [ dst>> ] [ src>> ] bi try-to-coalesce ;

M: ##phi prepare-insn
    [ dst>> ] [ inputs>> values ] bi
    [ eliminate-copy ] with each ;

: prepare-block ( bb -- )
    instructions>> [ prepare-insn ] each ;

: prepare-coalescing ( cfg -- )
    init-coalescing
    defs get keys [ introduce-vreg ] each
    [ prepare-block ] each-basic-block ;

: process-copies ( -- )
    copies get [
        2dup classes-interfere?
        [ 2drop ] [ eliminate-copy ] if
    ] assoc-each ;

: useless-copy? ( ##copy -- ? )
    dup ##copy? [ [ dst>> ] [ src>> ] bi eq? ] [ drop f ] if ;

: perform-renaming ( cfg -- )
    leader-map get keys [ dup leader ] H{ } map>assoc renamings set
    [
        instructions>> [
            [ rename-insn-defs ]
            [ rename-insn-uses ]
            [ [ useless-copy? ] [ ##phi? ] bi or not ] tri
        ] filter-here
    ] each-basic-block ;

: destruct-ssa ( cfg -- cfg' )
    needs-dominance

    dup construct-cssa
    dup compute-defs
    compute-ssa-live-sets
    dup compute-live-ranges
    dup prepare-coalescing
    process-copies
    dup perform-renaming ;
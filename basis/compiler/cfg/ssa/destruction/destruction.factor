! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry kernel namespaces
sequences sequences.deep
sets vectors
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
FROM: namespaces => set ;
IN: compiler.cfg.ssa.destruction

! Maps vregs to leaders.
SYMBOL: leader-map

: leader ( vreg -- vreg' ) leader-map get compress-path ;

! Maps basic blocks to ##phi instruction outputs
SYMBOL: phi-sets

: phi-set ( bb -- vregs ) phi-sets get at ;

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
        2dup [ rep-of ] bi@ eq?
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

GENERIC: rename-insn ( insn -- keep? )

M: vreg-insn rename-insn
    [ rename-insn-defs ] [ rename-insn-uses ] bi t ;

M: ##copy rename-insn
    [ call-next-method drop ]
    [ [ dst>> ] [ src>> ] bi eq? not ] bi ;

SYMBOL: current-phi-set

M: ##phi rename-insn dst>> current-phi-set get push f ;

M: ##call-gc rename-insn
    [ renamings get '[ _ at ] map members ] change-gc-roots drop t ;

M: insn rename-insn drop t ;

: renaming-in-block ( bb -- )
    V{ } clone current-phi-set set
    [ [ current-phi-set ] dip phi-sets get set-at ]
    [ instructions>> [ rename-insn ] filter! drop ]
    bi ;

: perform-renaming ( cfg -- )
    H{ } clone phi-sets set
    leader-map get keys [ dup leader ] H{ } map>assoc renamings set
    [ renaming-in-block ] each-basic-block ;

: destruct-ssa ( cfg -- cfg' )
    needs-dominance

    dup construct-cssa
    dup compute-defs
    dup compute-ssa-live-sets
    dup compute-live-ranges
    dup prepare-coalescing
    process-copies
    dup perform-renaming ;

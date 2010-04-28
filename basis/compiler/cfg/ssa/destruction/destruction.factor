! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry kernel namespaces
sequences sequences.deep
sets vectors
cpu.architecture
compiler.cfg.rpo
compiler.cfg.def-use
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

! Because of the design of the register allocator, this pass
! has three peculiar properties.
!
! 1) Instead of renaming vreg usages in the CFG, a map from
! vregs to canonical representatives is computed. This allows
! the register allocator to use the original SSA names to get
! reaching definitions.
! 2) Useless ##copy instructions, and all ##phi instructions,
! are eliminated, so the register allocator does not have to
! remove any redundant operations.
! 3) A side effect of running this pass is that SSA liveness
! information is computed, so the register allocator does not
! need to compute it again.

SYMBOL: leader-map

: leader ( vreg -- vreg' ) leader-map get compress-path ;

! Maps leaders to equivalence class elements.
SYMBOL: class-element-map

: class-elements ( vreg -- elts ) class-element-map get at ;

<PRIVATE

! Sequence of vreg pairs
SYMBOL: copies

: init-coalescing ( -- )
    defs get keys
    [ [ dup ] H{ } map>assoc leader-map set ]
    [ [ dup 1vector ] H{ } map>assoc class-element-map set ] bi
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

GENERIC: prepare-insn ( insn -- )

: try-to-coalesce ( dst src -- ) 2array copies get push ;

M: insn prepare-insn
    [ temp-vregs [ leader-map get conjoin ] each ]
    [
        [ defs-vreg ] [ uses-vregs ] bi
        2dup empty? not and [
            first
            2dup [ rep-of ] bi@ eq?
            [ try-to-coalesce ] [ 2drop ] if
        ] [ 2drop ] if
    ] bi ;

M: ##copy prepare-insn
    [ dst>> ] [ src>> ] bi try-to-coalesce ;

M: ##tagged>integer prepare-insn
    [ dst>> ] [ src>> ] bi eliminate-copy ;

M: ##phi prepare-insn
    [ dst>> ] [ inputs>> values ] bi
    [ eliminate-copy ] with each ;

: prepare-block ( bb -- )
    instructions>> [ prepare-insn ] each ;

: prepare-coalescing ( cfg -- )
    init-coalescing
    [ prepare-block ] each-basic-block ;

: process-copies ( -- )
    copies get [
        2dup classes-interfere?
        [ 2drop ] [ eliminate-copy ] if
    ] assoc-each ;

GENERIC: useful-insn? ( insn -- ? )

: useful-copy? ( insn -- ? )
    [ dst>> leader ] [ src>> leader ] bi eq? not ; inline

M: ##copy useful-insn? useful-copy? ;

M: ##tagged>integer useful-insn? useful-copy? ;

M: ##phi useful-insn? drop f ;

M: insn useful-insn? drop t ;

: cleanup-block ( bb -- )
    instructions>> [ useful-insn? ] filter! drop ;

: cleanup-cfg ( cfg -- )
    [ cleanup-block ] each-basic-block ;

PRIVATE>

: destruct-ssa ( cfg -- cfg' )
    needs-dominance

    dup construct-cssa
    dup compute-defs
    dup compute-ssa-live-sets
    dup compute-live-ranges
    dup prepare-coalescing
    process-copies
    dup cleanup-cfg ;

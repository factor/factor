! Copyright (C) 2009, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry locals kernel make
namespaces sequences sequences.deep
sets vectors
cpu.architecture
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.registers
compiler.cfg.dominance
compiler.cfg.instructions
compiler.cfg.liveness
compiler.cfg.ssa.cssa
compiler.cfg.ssa.interference
compiler.cfg.ssa.interference.live-ranges
compiler.cfg.parallel-copy
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
! 3) This pass computes live sets and fills out GC maps with
! compiler.cfg.liveness, so the linear scan register allocator
! does not need to compute liveness again.

SYMBOL: leader-map

: leader ( vreg -- vreg' ) leader-map get compress-path ;

! Maps leaders to equivalence class elements.
SYMBOL: class-element-map

: class-elements ( vreg -- elts ) class-element-map get at ;

<PRIVATE

! Sequence of vreg pairs
SYMBOL: copies

: value-of ( vreg -- value )
    dup insn-of dup ##tagged>integer? [ nip src>> ] [ drop ] if ;

: init-coalescing ( -- )
    defs get
    [ [ drop dup ] assoc-map leader-map set ]
    [ [ [ dup dup value-of ] dip <vreg-info> 1array ] assoc-map class-element-map set ] bi
    V{ } clone copies set ;

: coalesce-leaders ( vreg1 vreg2 -- )
    ! leader2 becomes the leader.
    swap leader-map get set-at ;

: coalesce-elements ( merged vreg1 vreg2 -- )
    ! delete leader1's class, and set leader2's class to merged.
    class-element-map get [ delete-at ] [ set-at ] bi-curry bi* ;

: coalesce-vregs ( merged leader1 leader2 -- )
    [ coalesce-leaders ] [ coalesce-elements ] 2bi ;

GENERIC: prepare-insn ( insn -- )

: maybe-eliminate-copy-later ( dst src -- )
    2array copies get push ;

M: insn prepare-insn drop ;

M: alien-call-insn prepare-insn drop ;

M: vreg-insn prepare-insn
    [ temp-vregs [ leader-map get conjoin ] each ]
    [
        [ defs-vregs ] [ uses-vregs ] bi
        2dup [ empty? not ] both? [
            [ first ] bi@
            2dup [ rep-of reg-class-of ] bi@ eq?
            [ maybe-eliminate-copy-later ] [ 2drop ] if
        ] [ 2drop ] if
    ] bi ;

M: ##copy prepare-insn
    [ dst>> ] [ src>> ] bi maybe-eliminate-copy-later ;

M: ##parallel-copy prepare-insn
    values>> [ first2 maybe-eliminate-copy-later ] each ;

: leaders ( vreg1 vreg2 -- vreg1' vreg2' )
    [ leader ] bi@ ;

: vregs-interfere? ( vreg1 vreg2 -- merged/f ? )
    [ class-elements ] bi@ sets-interfere? ;

ERROR: vregs-shouldn't-interfere vreg1 vreg2 ;

:: must-eliminate-copy ( vreg1 vreg2 -- )
    ! Eliminate a copy.
    vreg1 vreg2 eq? [
        vreg1 vreg2 vregs-interfere?
        [ vreg1 vreg2 vregs-shouldn't-interfere ]
        [ vreg1 vreg2 coalesce-vregs ]
        if
    ] unless ;

M: ##tagged>integer prepare-insn
    [ dst>> ] [ src>> ] bi leaders must-eliminate-copy ;

M: ##phi prepare-insn
    [ dst>> ] [ inputs>> values ] bi
    [ leaders must-eliminate-copy ] with each ;

: prepare-coalescing ( cfg -- )
    init-coalescing
    [ [ prepare-insn ] each ] simple-analysis ;

:: maybe-eliminate-copy ( vreg1 vreg2 -- )
    ! Eliminate a copy if possible.
    vreg1 vreg2 eq? [
        vreg1 vreg2 vregs-interfere?
        [ drop ] [ vreg1 vreg2 coalesce-vregs ] if
    ] unless ;

: process-copies ( -- )
    copies get [ leaders maybe-eliminate-copy ] assoc-each ;

GENERIC: cleanup-insn ( insn -- )

: useful-copy? ( insn -- ? )
    [ dst>> ] [ src>> ] bi leaders eq? not ; inline

M: ##copy cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##parallel-copy cleanup-insn
    values>>
    [ first2 leaders 2array ] map [ first2 eq? not ] filter
    [ parallel-copy-rep ] unless-empty ;

M: ##tagged>integer cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##phi cleanup-insn drop ;

M: insn cleanup-insn , ;

: cleanup-cfg ( cfg -- )
    [ [ [ cleanup-insn ] each ] V{ } make ] simple-optimization ;

PRIVATE>

: destruct-ssa ( cfg -- cfg' )
    needs-dominance

    dup construct-cssa
    dup compute-defs
    dup compute-insns
    dup compute-live-sets
    dup compute-live-ranges
    dup prepare-coalescing
    process-copies
    dup cleanup-cfg
    dup compute-live-sets ;

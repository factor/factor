! Copyright (C) 2009, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg.def-use
compiler.cfg.dominance compiler.cfg.instructions
compiler.cfg.liveness compiler.cfg.parallel-copy
compiler.cfg.registers compiler.cfg.rpo compiler.cfg.ssa.cssa
compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.interference
compiler.cfg.ssa.interference.live-ranges compiler.cfg.utilities
cpu.architecture kernel locals make namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.ssa.destruction

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
    [
        [ [ dup dup value-of ] dip <vreg-info> 1array ] assoc-map
        class-element-map set
    ] bi
    V{ } clone copies set ;

: coalesce-elements ( merged vreg1 vreg2 -- )
    ! delete leader1's class, and set leader2's class to merged.
    class-element-map get [ delete-at ] [ set-at ] bi-curry bi* ;

: coalesce-vregs ( merged leader1 leader2 -- )
    2dup swap leader-map get set-at coalesce-elements ;

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
    vreg1 vreg2 = [
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
    vreg1 vreg2 = [
        vreg1 vreg2 vregs-interfere?
        [ drop ] [ vreg1 vreg2 coalesce-vregs ] if
    ] unless ;

: process-copies ( copies -- )
    [ leaders maybe-eliminate-copy ] assoc-each ;

: perform-coalescing ( cfg -- )
    prepare-coalescing copies get process-copies ;

GENERIC: cleanup-insn ( insn -- )

: useful-copy? ( insn -- ? )
    [ dst>> ] [ src>> ] bi leaders = not ; inline

M: ##copy cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##parallel-copy cleanup-insn
    values>> [ leaders ] assoc-map [ first2 = not ] filter
    parallel-copy-rep % ;

M: ##tagged>integer cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##phi cleanup-insn drop ;

M: insn cleanup-insn , ;

: cleanup-cfg ( cfg -- )
    [ [ [ cleanup-insn ] each ] V{ } make ] simple-optimization ;

PRIVATE>

: destruct-ssa ( cfg -- )
    {
        needs-dominance
        construct-cssa
        compute-defs
        compute-insns
        compute-live-sets
        compute-live-ranges
        perform-coalescing
        cleanup-cfg
        compute-live-sets
    } apply-passes ;

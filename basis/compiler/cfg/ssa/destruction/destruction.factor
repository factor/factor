! Copyright (C) 2009, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg.def-use
compiler.cfg.dominance compiler.cfg.instructions
compiler.cfg.liveness compiler.cfg.parallel-copy
compiler.cfg.registers compiler.cfg.rpo compiler.cfg.ssa.cssa
compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.interference
compiler.cfg.ssa.interference.live-ranges compiler.cfg.utilities
cpu.architecture kernel make namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.ssa.destruction

SYMBOL: class-element-map

<PRIVATE

SYMBOL: copies

: value-of ( vreg -- value )
    dup insn-of dup ##tagged>integer? [ nip src>> ] [ drop ] if ;

: init-coalescing ( -- )
    defs get
    [ keys unique leader-map set ]
    [
        [ [ dup dup value-of ] dip <vreg-info> 1array ] assoc-map
        class-element-map set
    ] bi
    V{ } clone copies set ;

: coalesce-elements ( merged follower leader -- )
    class-element-map get [ delete-at ] [ set-at ] bi-curry bi* ;

: coalesce-vregs ( merged follower leader -- )
    2dup swap leader-map get set-at coalesce-elements ;

GENERIC: prepare-insn ( insn -- )

M: insn prepare-insn drop ;

M: alien-call-insn prepare-insn drop ;

M: vreg-insn prepare-insn
    [ temp-vregs [ leader-map get conjoin ] each ]
    [
        [ defs-vregs ] [ uses-vregs ] bi
        2dup [ empty? not ] both? [
            [ first ] bi@
            2dup [ rep-of reg-class-of ] bi@ eq?
            [ 2array copies get push ] [ 2drop ] if
        ] [ 2drop ] if
    ] bi ;

M: ##copy prepare-insn
    [ dst>> ] [ src>> ] bi 2array copies get push ;

M: ##parallel-copy prepare-insn
    values>> copies get push-all ;

: leaders ( vreg1 vreg2 -- vreg1' vreg2' )
    [ leader ] bi@ ;

: vregs-interfere? ( vreg1 vreg2 -- merged/f ? )
    [ class-element-map get at ] bi@ sets-interfere? ;

ERROR: vregs-shouldn't-interfere vreg1 vreg2 ;

: try-eliminate-copy ( follower leader must? -- )
    -rot leaders 2dup = [ 3drop ] [
        2dup vregs-interfere? [
            drop rot [ vregs-shouldn't-interfere ] [ 2drop ] if
        ] [ -rot coalesce-vregs drop ] if
    ] if ;

M: ##tagged>integer prepare-insn
    [ dst>> ] [ src>> ] bi t try-eliminate-copy ;

M: ##phi prepare-insn
    [ dst>> ] [ inputs>> values ] bi [ t try-eliminate-copy ] with each ;

: prepare-coalescing ( cfg -- )
    init-coalescing [ [ prepare-insn ] each ] simple-analysis ;

: process-copies ( copies -- )
    [ f try-eliminate-copy ] assoc-each ;

: perform-coalescing ( cfg -- )
    prepare-coalescing copies get process-copies ;

GENERIC: cleanup-insn ( insn -- )

: useful-copy? ( insn -- ? )
    [ dst>> ] [ src>> ] bi leaders = not ; inline

M: ##copy cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##parallel-copy cleanup-insn
    values>> [ leaders ] assoc-map [ first2 = ] reject
    parallel-copy-rep % ;

M: ##tagged>integer cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##phi cleanup-insn drop ;

M: insn cleanup-insn , ;

: cleanup-cfg ( cfg -- )
    [ [ [ cleanup-insn ] each ] V{ } make ] simple-optimization ;

PRIVATE>

: destruct-ssa ( cfg -- )
    f leader-map set
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

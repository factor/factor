! Copyright (C) 2008, 2010 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.rpo kernel namespaces sequences sets ;
IN: compiler.cfg.dce

! Maps vregs to sequences of vregs
SYMBOL: liveness-graph

! vregs which participate in side effects and thus are always live
SYMBOL: live-vregs

: live-vreg? ( vreg -- ? )
    live-vregs get in? ;

! vregs which are the result of an allocation
SYMBOL: allocations

: allocation? ( vreg -- ? )
    allocations get in? ;

: init-dead-code ( -- )
    H{ } clone liveness-graph namespaces:set
    HS{ } clone live-vregs namespaces:set
    HS{ } clone allocations namespaces:set ;

GENERIC: build-liveness-graph ( insn -- )

: add-edges ( uses def -- )
    liveness-graph get [ union ] change-at ;

: setter-liveness-graph ( insn vreg -- )
    dup allocation? [ [ uses-vregs ] dip add-edges ] [ 2drop ] if ;

M: ##set-slot build-liveness-graph
    dup obj>> setter-liveness-graph ;

M: ##set-slot-imm build-liveness-graph
    dup obj>> setter-liveness-graph ;

M: ##write-barrier build-liveness-graph
    dup src>> setter-liveness-graph ;

M: ##write-barrier-imm build-liveness-graph
    dup src>> setter-liveness-graph ;

M: ##allot build-liveness-graph
    [ dst>> allocations get adjoin ] [ call-next-method ] bi ;

M: vreg-insn build-liveness-graph
    [ uses-vregs ] [ defs-vregs ] bi [ add-edges ] with each ;

M: insn build-liveness-graph drop ;

GENERIC: compute-live-vregs ( insn -- )

: (record-live) ( vregs -- )
    [
        dup live-vregs get ?adjoin [
            liveness-graph get at (record-live)
        ] [ drop ] if
    ] each ;

: record-live ( insn -- )
    uses-vregs (record-live) ;

: setter-live-vregs ( insn vreg -- )
    allocation? [ drop ] [ record-live ] if ;

M: ##set-slot compute-live-vregs
    dup obj>> setter-live-vregs ;

M: ##set-slot-imm compute-live-vregs
    dup obj>> setter-live-vregs ;

M: ##write-barrier compute-live-vregs
    dup src>> setter-live-vregs ;

M: ##write-barrier-imm compute-live-vregs
    dup src>> setter-live-vregs ;

M: flushable-insn compute-live-vregs drop ;

M: vreg-insn compute-live-vregs record-live ;

M: insn compute-live-vregs drop ;

GENERIC: live-insn? ( insn -- ? )

M: ##set-slot live-insn? obj>> live-vreg? ;

M: ##set-slot-imm live-insn? obj>> live-vreg? ;

M: ##write-barrier live-insn? src>> live-vreg? ;

M: ##write-barrier-imm live-insn? src>> live-vreg? ;

: filter-alien-outputs ( outputs -- live-outputs dead-outputs )
    [ first live-vreg? ] partition
    [ first3 2array nip ] map ;

M: alien-call-insn live-insn?
    dup reg-outputs>> filter-alien-outputs [ >>reg-outputs ] [ >>dead-outputs ] bi*
    drop t ;

M: ##callback-inputs live-insn?
    [ filter-alien-outputs drop ] change-reg-outputs
    [ filter-alien-outputs drop ] change-stack-outputs
    drop t ;

M: flushable-insn live-insn? defs-vregs [ live-vreg? ] any? ;

M: insn live-insn? drop t ;

: eliminate-dead-code ( cfg -- )
    init-dead-code
    {
        [ needs-predecessors ]
        [ [ [ build-liveness-graph ] each ] simple-analysis ]
        [ [ [ compute-live-vregs ] each ] simple-analysis ]
        [ [ [ live-insn? ] filter! ] simple-optimization ]
    } cleave ;

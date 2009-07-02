! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sets kernel namespaces sequences
compiler.cfg.instructions compiler.cfg.def-use
compiler.cfg.rpo ;
IN: compiler.cfg.dce

! Maps vregs to sequences of vregs
SYMBOL: liveness-graph

! vregs which participate in side effects and thus are always live
SYMBOL: live-vregs

: live-vreg? ( vreg -- ? )
    live-vregs get key? ;

! vregs which are the result of an allocation
SYMBOL: allocations

: allocation? ( vreg -- ? )
    allocations get key? ;

: init-dead-code ( -- )
    H{ } clone liveness-graph set
    H{ } clone live-vregs set
    H{ } clone allocations set ;

GENERIC: build-liveness-graph ( insn -- )

: add-edges ( insn register -- )
    [ uses-vregs ] dip liveness-graph get [ union ] change-at ;

: setter-liveness-graph ( insn vreg -- )
    dup allocation? [ add-edges ] [ 2drop ] if ;

M: ##set-slot build-liveness-graph
    dup obj>> setter-liveness-graph ;

M: ##set-slot-imm build-liveness-graph
    dup obj>> setter-liveness-graph ;

M: ##write-barrier build-liveness-graph
    dup src>> setter-liveness-graph ;

M: ##flushable build-liveness-graph
    dup dst>> add-edges ;

M: ##allot build-liveness-graph
    [ dst>> allocations get conjoin ]
    [ call-next-method ] bi ;

M: insn build-liveness-graph drop ;

GENERIC: compute-live-vregs ( insn -- )

: (record-live) ( vregs -- )
    [
        dup live-vregs get key? [ drop ] [
            [ live-vregs get conjoin ]
            [ liveness-graph get at (record-live) ]
            bi
        ] if
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

M: ##flushable compute-live-vregs drop ;

M: insn compute-live-vregs
    record-live ;

GENERIC: live-insn? ( insn -- ? )

M: ##flushable live-insn? dst>> live-vreg? ;

M: ##set-slot live-insn? obj>> live-vreg? ;

M: ##set-slot-imm live-insn? obj>> live-vreg? ;

M: ##write-barrier live-insn? src>> live-vreg? ;

M: insn live-insn? drop t ;

: eliminate-dead-code ( cfg -- cfg' )
    init-dead-code
    dup
    [ [ instructions>> [ build-liveness-graph ] each ] each-basic-block ]
    [ [ instructions>> [ compute-live-vregs ] each ] each-basic-block ]
    [ [ [ [ live-insn? ] filter ] change-instructions drop ] each-basic-block ]
    tri ;

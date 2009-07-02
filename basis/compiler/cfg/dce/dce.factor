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

! vregs which are the result of an allocation
SYMBOL: allocations

: init-dead-code ( -- )
    H{ } clone liveness-graph set
    H{ } clone live-vregs set
    H{ } clone allocations set ;

GENERIC: update-liveness-graph ( insn -- )

: add-edges ( insn register -- )
    [ uses-vregs ] dip liveness-graph get [ union ] change-at ;

M: ##flushable update-liveness-graph
    dup dst>> add-edges ;

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

M: insn update-liveness-graph record-live ;

: update-allocation-liveness ( insn vreg -- )
    dup allocations get key? [ add-edges ] [ drop record-live ] if ;

M: ##set-slot update-liveness-graph
    dup obj>> update-allocation-liveness ;

M: ##set-slot-imm update-liveness-graph
    dup obj>> update-allocation-liveness ;

M: ##write-barrier update-liveness-graph
    dup src>> update-allocation-liveness ;

M: ##allot update-liveness-graph
    [ dst>> allocations get conjoin ]
    [ call-next-method ] bi ;

GENERIC: live-insn? ( insn -- ? )

: live-vreg? ( vreg -- ? )
    live-vregs get key? ;

M: ##flushable live-insn? dst>> live-vreg? ;

M: ##set-slot live-insn? obj>> live-vreg? ;

M: ##set-slot-imm live-insn? obj>> live-vreg? ;

M: ##write-barrier live-insn? src>> live-vreg? ;

M: insn live-insn? drop t ;

: eliminate-dead-code ( cfg -- cfg' )
    init-dead-code
    [ [ instructions>> [ update-liveness-graph ] each ] each-basic-block ]
    [ [ [ [ live-insn? ] filter ] change-instructions drop ] each-basic-block ]
    [ ]
    tri ;

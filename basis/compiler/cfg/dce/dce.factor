! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces sequences
compiler.cfg.instructions compiler.cfg.def-use
compiler.cfg.rpo compiler.cfg.predecessors hash-sets sets ;
FROM: namespaces => set ;
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
    H{ } clone liveness-graph set
    HS{ } clone live-vregs set
    HS{ } clone allocations set ;

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

M: ##write-barrier-imm build-liveness-graph
    dup src>> setter-liveness-graph ;

M: ##allot build-liveness-graph
    [ dst>> allocations get adjoin ] [ call-next-method ] bi ;

M: vreg-insn build-liveness-graph
    dup defs-vreg dup [ add-edges ] [ 2drop ] if ;

M: insn build-liveness-graph drop ;

GENERIC: compute-live-vregs ( insn -- )

: (record-live) ( vregs -- )
    [
        dup live-vreg? [ drop ] [
            [ live-vregs get adjoin ]
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

M: ##write-barrier-imm compute-live-vregs
    dup src>> setter-live-vregs ;

M: ##fixnum-add compute-live-vregs record-live ;

M: ##fixnum-sub compute-live-vregs record-live ;

M: ##fixnum-mul compute-live-vregs record-live ;

M: vreg-insn compute-live-vregs
    dup defs-vreg [ drop ] [ record-live ] if ;

M: insn compute-live-vregs drop ;

GENERIC: live-insn? ( insn -- ? )

M: ##set-slot live-insn? obj>> live-vreg? ;

M: ##set-slot-imm live-insn? obj>> live-vreg? ;

M: ##write-barrier live-insn? src>> live-vreg? ;

M: ##write-barrier-imm live-insn? src>> live-vreg? ;

M: ##fixnum-add live-insn? drop t ;

M: ##fixnum-sub live-insn? drop t ;

M: ##fixnum-mul live-insn? drop t ;

M: vreg-insn live-insn? defs-vreg [ live-vreg? ] [ t ] if* ;

M: insn live-insn? defs-vreg drop t ;

: eliminate-dead-code ( cfg -- cfg' )
    ! Even though we don't use predecessors directly, we depend
    ! on the predecessors pass updating phi nodes to remove dead
    ! inputs.
    needs-predecessors

    init-dead-code
    dup
    [ [ [ build-liveness-graph ] each ] simple-analysis ]
    [ [ [ compute-live-vregs ] each ] simple-analysis ]
    [ [ [ live-insn? ] filter! ] simple-optimization ]
    tri ;

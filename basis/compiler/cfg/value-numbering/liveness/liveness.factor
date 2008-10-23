! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs sets accessors
compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions ;
IN: compiler.cfg.value-numbering.liveness

! A set of VNs which are (transitively) used by effect-ops. This
! is precisely the set of VNs whose value is needed outside of
! the basic block.
SYMBOL: live-vns

GENERIC: live-expr ( expr -- )

: live-vn ( vn -- )
    #! Mark a VN and all VNs used in its computation as live.
    dup live-vns get key? [ drop ] [
        [ live-vns get conjoin ] [ vn>expr live-expr ] bi
    ] if ;

: live-vreg ( vreg -- ) vreg>vn live-vn ;

M: expr live-expr drop ;
M: unary-expr live-expr in>> live-vn ;
M: binary-expr live-expr [ in1>> live-vn ] [ in2>> live-vn ] bi ;

: live? ( vreg -- ? )
    dup vreg>vn tuck vn>vreg =
    [ live-vns get key? ] [ drop f ] if ;

: init-liveness ( -- )
    H{ } clone live-vns set ;

GENERIC: eliminate ( insn -- insn' )

M: ##flushable eliminate dup dst>> live? [ drop f ] unless ;
M: insn eliminate ;

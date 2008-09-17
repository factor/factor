! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel assocs sets accessors compiler.vops
compiler.cfg.vn.graph compiler.cfg.vn.expressions ;
IN: compiler.cfg.vn.liveness

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
M: literal-expr live-expr in>> live-vn ;
M: unary-expr live-expr in>> live-vn ;
M: binary-expr live-expr [ in1>> live-vn ] [ in2>> live-vn ] bi ;

: live? ( vreg -- ? )
    dup vreg>vn tuck vn>vreg =
    [ live-vns get key? ] [ drop f ] if ;

: init-liveness ( -- )
    H{ } clone live-vns set ;

GENERIC: eliminate ( insn -- insn' )

M: flushable-op eliminate dup out>> live? ?nop ;
M: vop eliminate ;

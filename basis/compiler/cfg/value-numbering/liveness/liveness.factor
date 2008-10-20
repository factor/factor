! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.cfg.value-numbering.liveness

! A set of VNs which are (transitively) used by side-effecting
! instructions.
SYMBOL: live-vns

GENERIC: live-expr ( expr -- )

: live-vn ( vn -- )
    #! Mark a VN and all VNs used in its computation as live.
    dup live-vns get key? [ drop ] [
        [ live-vns get conjoin ] [ vn>expr live-expr ] bi
    ] if ;

M: peek-expr live-expr drop ;
M: unary-expr live-expr in>> live-vn ;
M: load-literal-expr live-expr in>> live-vn ;

: live-vreg ( vreg -- ) vreg>vn live-vn ;

: live? ( vreg -- ? )
    dup vreg>vn tuck vn>vreg =
    [ live-vns get key? ] [ drop f ] if ;

: init-liveness ( -- )
    H{ } clone live-vns set ;

GENERIC: eliminate ( insn -- insn/f )

: (eliminate) ( insn -- insn/f )
    dup dst>> live? [ drop f ] unless ;

M: ##peek eliminate (eliminate) ;
M: ##unary eliminate (eliminate) ;
M: ##load-literal eliminate (eliminate) ;
M: insn eliminate ;

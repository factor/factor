! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs sequences kernel accessors
compiler.vops
compiler.cfg.vn.graph ;
IN: compiler.cfg.vn.propagate

! If two vregs compute the same value, replace references to
! the latter with the former.

: resolve ( vreg -- vreg' ) vreg>vn vn>vreg ;

GENERIC: propogate ( insn -- insn )

M: effect-op propogate
    [ resolve ] change-in ;

M: unary-op propogate
    [ resolve ] change-in ;

M: binary-op propogate
    [ resolve ] change-in1
    [ resolve ] change-in2 ;

M: %phi propogate
    [ [ resolve ] map ] change-in ;

M: %%slot propogate
    [ resolve ] change-obj
    [ resolve ] change-slot ;

M: %%set-slot propogate
    call-next-method
    [ resolve ] change-obj
    [ resolve ] change-slot ;

M: %store propogate
    call-next-method
    [ resolve ] change-addr ;

M: nullary-op propogate ;

M: flushable-op propogate ;

! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs sequences kernel accessors
compiler.cfg.instructions compiler.cfg.value-numbering.graph ;
IN: compiler.cfg.value-numbering.propagate

! If two vregs compute the same value, replace references to
! the latter with the former.

: resolve ( vreg -- vreg' ) vreg>vn vn>vreg ; inline

GENERIC: propagate ( insn -- insn )

M: ##effect propagate
    [ resolve ] change-src ;

M: ##unary propagate
    [ resolve ] change-src ;

M: ##binary propagate
    [ resolve ] change-src1
    [ resolve ] change-src2 ;

M: ##binary-imm propagate
    [ resolve ] change-src1 ;

M: ##slot propagate
    [ resolve ] change-obj
    [ resolve ] change-slot ;

M: ##slot-imm propagate
    [ resolve ] change-obj ;

M: ##set-slot propagate
    call-next-method
    [ resolve ] change-obj
    [ resolve ] change-slot ;

M: ##string-nth propagate
    [ resolve ] change-obj
    [ resolve ] change-index ;

M: ##set-slot-imm propagate
    call-next-method
    [ resolve ] change-obj ;

M: ##alien-getter propagate
    call-next-method
    [ resolve ] change-src ;

M: ##alien-setter propagate
    call-next-method
    [ resolve ] change-value ;

M: ##conditional-branch propagate
    [ resolve ] change-src1
    [ resolve ] change-src2 ;

M: ##compare-imm-branch propagate
    [ resolve ] change-src1 ;

M: ##dispatch propagate
    [ resolve ] change-src ;

M: ##fixnum-overflow propagate
    [ resolve ] change-src1
    [ resolve ] change-src2 ;

M: insn propagate ;

! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.cfg.value-numbering.propagate

! If two vregs compute the same value, replace references to
! the latter with the former.

: resolve ( vreg -- vreg' ) vreg>vn vn>vreg ;

GENERIC: propogate ( insn -- insn )

M: ##unary-branch propagate [ resolve ] change-src ;

M: ##unary propogate [ resolve ] change-src ;

M: ##flushable propagate ;

M: ##replace propagate [ resolve ] change-src ;

M: ##inc-d propagate ;

M: ##inc-r propagate ;

M: ##stack-frame propagate ;

M: ##call propagate ;

M: ##jump propagate ;

M: ##return propagate ;

M: ##intrinsic propagate
    [ [ resolve ] assoc-map ] change-defs-vregs
    [ [ resolve ] assoc-map ] change-uses-vregs ;

M: ##dispatch propagate [ resolve ] change-src ;

M: ##dispatch-label propagate ;

M: ##write-barrier propagate [ resolve ] change-src ;

M: ##alien-invoke propagate ;

M: ##alien-indirect propagate ;

M: ##alien-callback propagate ;

M: ##callback-return propagate ;

M: ##prologue propagate ;

M: ##epilogue propagate ;

M: ##branch propagate ;

M: ##if-intrinsic propagate
    [ [ resolve ] assoc-map ] change-defs-vregs
    [ [ resolve ] assoc-map ] change-uses-vregs ;

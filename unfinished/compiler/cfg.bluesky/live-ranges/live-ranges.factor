! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs accessors math.order sequences
compiler.vops ;
IN: compiler.cfg.live-ranges

TUPLE: live-range from to ;

! Maps vregs to live ranges
SYMBOL: live-ranges

: def ( n vreg -- )
    [ dup live-range boa ] dip live-ranges get set-at ;

: use ( n vreg -- )
    live-ranges get at [ max ] change-to drop ;

GENERIC: compute-live-ranges* ( n insn -- )

M: nullary-op compute-live-ranges*
    2drop ;

M: flushable-op compute-live-ranges*
    out>> def ;

M: effect-op compute-live-ranges*
    in>> use ;

M: unary-op compute-live-ranges*
    [ out>> def ] [ in>> use ] 2bi ;

M: binary-op compute-live-ranges*
    [ call-next-method ] [ in1>> use ] [ in2>> use ] 2tri ;

M: %store compute-live-ranges*
    [ call-next-method ] [ addr>> use ] 2bi ;

: compute-live-ranges ( insns -- )
    H{ } clone live-ranges set
    [ swap compute-live-ranges* ] each-index ;

! Copyright (C) 2012 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.utilities kernel namespaces ;
IN: compiler.cfg.ssa.destruction.leaders

SYMBOL: leader-map

: leader ( vreg -- vreg' ) leader-map get compress-path ;

: ?leader ( vreg -- vreg' ) [ leader ] keep or ; inline

: leaders ( vreg1 vreg2 -- vreg1' vreg2' )
    [ leader ] bi@ ;

! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors kernel assocs compiler.cfg.liveness compiler.cfg.rpo ;
IN: compiler.cfg.local

: optimize-basic-block ( bb init-quot insn-quot -- )
    [ '[ live-in keys @ ] ] [ '[ _ change-instructions drop ] ] bi* bi ; inline

: local-optimization ( cfg init-quot: ( live-in -- ) insn-quot: ( insns -- insns' ) -- cfg' )
    [ dup ] 2dip '[ _ _ optimize-basic-block ] each-basic-block ; inline
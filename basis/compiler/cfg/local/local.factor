! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals accessors kernel assocs namespaces
compiler.cfg compiler.cfg.liveness compiler.cfg.rpo ;
IN: compiler.cfg.local

:: optimize-basic-block ( bb init-quot insn-quot -- )
    bb basic-block set
    bb live-in keys init-quot call
    bb insn-quot change-instructions drop ; inline

:: local-optimization ( cfg init-quot: ( live-in -- ) insn-quot: ( insns -- insns' ) -- cfg' )
    cfg [ init-quot insn-quot optimize-basic-block ] each-basic-block
    cfg ; inline
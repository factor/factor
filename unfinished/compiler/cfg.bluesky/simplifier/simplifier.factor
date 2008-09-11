! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel
compiler.cfg
compiler.cfg.predecessors
compiler.cfg.stack
compiler.cfg.alias
compiler.cfg.write-barrier
compiler.cfg.elaboration
compiler.cfg.vn
compiler.cfg.vn.conditions
compiler.cfg.kill-nops ;
IN: compiler.cfg.simplifier

: simplify ( insns -- insns' )
    normalize-height
    alias-analysis
    elaboration
    value-numbering
    eliminate-write-barrier
    kill-nops ;

: simplify-cfg ( procedure -- procedure )
    dup compute-predecessors
    dup [ [ simplify ] change-instructions drop ] each-block ;

! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs biassocs classes kernel math accessors
sorting sets sequences
compiler.cfg.rpo
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.propagate
compiler.cfg.value-numbering.simplify
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering

: number-input-values ( live-in -- )
    [ [ f next-input-expr ] dip set-vn ] each ;

: init-value-numbering ( live-in -- )
    init-value-graph
    init-expressions
    number-input-values ;

: value-numbering-step ( insns -- insns' )
    [ [ number-values ] [ rewrite propagate ] bi ] map ;

: value-numbering ( rpo -- )
    [ init-value-numbering ] [ value-numbering-step ] local-optimization ;

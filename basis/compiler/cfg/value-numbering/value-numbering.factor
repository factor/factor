! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs biassocs classes kernel math accessors
sorting sets sequences
compiler.cfg.liveness
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.propagate
compiler.cfg.value-numbering.simplify
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering

: number-input-values ( basic-block -- )
    live-in keys [ [ next-input-expr ] dip set-vn ] each ;

: value-numbering-step ( basic-block -- )
    init-value-graph
    init-expressions
    dup number-input-values
    [ [ [ number-values ] [ rewrite propagate ] bi ] map ] change-instructions drop ;

: value-numbering ( rpo -- )
    [ value-numbering-step ] each ;

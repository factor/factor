! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs biassocs classes kernel math accessors
sorting sets sequences
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.propagate
compiler.cfg.value-numbering.simplify
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering

: value-numbering ( insns -- insns' )
    init-value-graph
    init-expressions
    [ [ number-values ] [ rewrite propagate ] bi ] map ;

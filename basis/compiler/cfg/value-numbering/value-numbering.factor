! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs biassocs classes kernel math accessors
sorting sets sequences
compiler.cfg.def-use
compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.liveness
compiler.cfg.value-numbering.propagate
compiler.cfg.value-numbering.simplify ;
IN: compiler.cfg.value-numbering

: insn>vn ( insn -- vn ) >expr simplify ; inline

GENERIC: number-values ( insn -- )

M: ##flushable number-values
    dup ##pure? [ dup call-next-method ] unless
    [ insn>vn ] [ dst>> ] bi set-vn ;

M: insn number-values uses-vregs [ live-vreg ] each ;

: init-value-numbering ( -- )
    init-value-graph
    init-expressions
    init-liveness ;

: value-numbering ( insns -- insns' )
    init-value-numbering
    [ [ number-values ] each ]
    [ [ eliminate propagate ] map sift ]
    bi ;

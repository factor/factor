! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs biassocs classes kernel math accessors
sorting sets sequences compiler.vops
compiler.cfg.vn.graph
compiler.cfg.vn.expressions
compiler.cfg.vn.simplify
compiler.cfg.vn.liveness
compiler.cfg.vn.constant-fold
compiler.cfg.vn.propagate ;
IN: compiler.cfg.vn

: insn>vn ( insn -- vn ) >expr simplify ; inline

GENERIC: make-value-node ( insn -- )
M: flushable-op make-value-node [ insn>vn ] [ out>> ] bi set-vn ;
M: effect-op make-value-node in>> live-vreg ;
M: %store make-value-node [ in>> live-vreg ] [ addr>> live-vreg ] bi ;
M: %%set-slot make-value-node [ in>> live-vreg ] [ obj>> live-vreg ] bi ;
M: nullary-op make-value-node drop ;

: init-value-numbering ( -- )
    init-value-graph
    init-expressions
    init-liveness ;

: value-numbering ( instructions -- instructions )
    init-value-numbering
    [ [ make-value-node ] each ]
    [ [ eliminate constant-fold propogate ] map ]
    bi ;

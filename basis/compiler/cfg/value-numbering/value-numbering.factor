! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.cfg.value-numbering

: insn>vn ( insn -- vn ) >expr simplify ; inline

GENERIC: make-value-node ( insn -- )

M: ##unary-branch make-value-node src>> live-vreg ;
M: ##unary make-value-node [ insn>vn ] [ dst>> ] bi set-vn ;
M: ##flushable make-value-node drop ;
M: ##load-literal make-value-node [ insn>vn ] [ dst>> ] bi set-vn ;
M: ##peek make-value-node [ insn>vn ] [ dst>> ] bi set-vn ;
M: ##replace make-value-node reset-value-graph ;
M: ##inc-d make-value-node reset-value-graph ;
M: ##inc-r make-value-node reset-value-graph ;
M: ##stack-frame make-value-node reset-value-graph ;
M: ##call make-value-node reset-value-graph ;
M: ##jump make-value-node reset-value-graph ;
M: ##return make-value-node reset-value-graph ;
M: ##intrinsic make-value-node uses-vregs [ live-vreg ] each ;
M: ##dispatch make-value-node reset-value-graph ;
M: ##dispatch-label make-value-node reset-value-graph ;
M: ##allot make-value-node drop ;
M: ##write-barrier make-value-node drop ;
M: ##gc make-value-node reset-value-graph ;
M: ##replace make-value-node reset-value-graph ;
M: ##alien-invoke make-value-node reset-value-graph ;
M: ##alien-indirect make-value-node reset-value-graph ;
M: ##alien-callback make-value-node reset-value-graph ;
M: ##callback-return make-value-node reset-value-graph ;
M: ##prologue make-value-node reset-value-graph ;
M: ##epilogue make-value-node reset-value-graph ;
M: ##branch make-value-node reset-value-graph ;
M: ##if-intrinsic make-value-node uses-vregs [ live-vreg ] each ;

: init-value-numbering ( -- )
    init-value-graph
    init-expressions
    init-liveness ;

: value-numbering ( instructions -- instructions )
    init-value-numbering
    [ [ make-value-node ] [ propagate ] bi ] map
    [ eliminate ] map
    sift ;

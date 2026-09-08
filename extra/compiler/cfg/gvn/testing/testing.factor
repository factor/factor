! Copyright (C) 2011 Alex Vondrak, 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.graphviz compiler.cfg.gvn
compiler.cfg.optimizer compiler.cfg.utilities compiler.test
kernel namespaces sequences words ;
QUALIFIED: compiler.cfg.value-numbering
IN: compiler.cfg.gvn.testing

! Graphs now show the production passes. The fixed-point analysis itself
! does not rewrite instructions or allocate registers between iterations.
: gvn-passes ( -- passes ) \ optimize-cfg def>> first ;

: test-gvn ( path quot -- )
    t compiler.cfg.value-numbering:global-value-numbering? [
        gvn-passes passes [ watch-optimizer* ] with-variable
    ] with-variable ;

: watch-gvn ( path quot -- ) test-gvn ;

: watch-gvn-cfg ( path cfg -- )
    { value-numbering } passes [ watch-cfg ] with-variable ;

: watch-gvn-bb ( path insns -- )
    0 test-bb 0 get block>cfg watch-gvn-cfg ;

! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.tree.builder compiler.tree.cleanup
compiler.tree.dead-code compiler.tree.def-use
compiler.tree.normalization compiler.tree.propagation
compiler.tree.recursive namespaces sequences ;
IN: compiler.tree.late-optimizations

: splice-quot ( quot -- nodes )
    [
        build-tree
        analyze-recursive
        normalize
        propagate
        cleanup-tree
        compute-def-use
        remove-dead-code
        but-last
    ] with-scope ;

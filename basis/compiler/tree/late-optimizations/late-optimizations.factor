! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.tree.builder compiler.tree.cleanup
compiler.tree.dead-code compiler.tree.def-use
compiler.tree.normalization compiler.tree.propagation
compiler.tree.recursive namespaces sequences ;
IN: compiler.tree.late-optimizations

! Late optimizations modify the tree such that stack flow
! information is no longer accurate, since we punt in
! 'splice-quot' and don't update everything that we should;
! this simplifies the code, improves performance, and we
! don't need the stack flow information after this pass anyway.

: splice-quot ( quot -- nodes )
    [
        build-tree
        analyze-recursive
        normalize
        propagate
        cleanup
        compute-def-use
        remove-dead-code
        but-last
    ] with-scope ;

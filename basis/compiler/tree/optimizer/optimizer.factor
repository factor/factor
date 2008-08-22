! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.tree.normalization
compiler.tree.propagation
compiler.tree.cleanup
compiler.tree.escape-analysis
compiler.tree.tuple-unboxing
compiler.tree.def-use
compiler.tree.dead-code
compiler.tree.strength-reduction
compiler.tree.loop.detection
compiler.tree.loop.inversion
compiler.tree.branch-fusion
compiler.tree.checker ;
IN: compiler.tree.optimizer

: optimize-tree ( nodes -- nodes' )
    normalize
    propagate
    cleanup
    detect-loops
    ! invert-loops
    ! fuse-branches
    escape-analysis
    unbox-tuples
    compute-def-use
    remove-dead-code
    ! strength-reduce
    USE: kernel
    compute-def-use
    dup check-nodes
    ;

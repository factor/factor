! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.tree.normalization compiler.tree.copy-equiv
compiler.tree.propagation compiler.tree.cleanup
compiler.tree.def-use compiler.tree.untupling
compiler.tree.dead-code compiler.tree.strength-reduction
compiler.tree.loop-detection compiler.tree.branch-fusion ;
IN: compiler.tree.optimizer

: optimize-tree ( nodes -- nodes' )
    normalize
    compute-copy-equiv
    propagate
    cleanup
    compute-def-use
    unbox-tuples
    compute-def-use
    remove-dead-code
    strength-reduce
    detect-loops
    fuse-branches
    elaborate ;

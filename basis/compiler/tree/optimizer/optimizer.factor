! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces
compiler.tree.recursive
compiler.tree.normalization
compiler.tree.propagation
compiler.tree.cleanup
compiler.tree.escape-analysis
compiler.tree.escape-analysis.check
compiler.tree.tuple-unboxing
compiler.tree.identities
compiler.tree.def-use
compiler.tree.dead-code
compiler.tree.modular-arithmetic
compiler.tree.finalization
compiler.tree.checker ;
IN: compiler.tree.optimizer

SYMBOL: check-optimizer?

: ?check ( nodes -- nodes' )
    check-optimizer? get [
        compute-def-use
        dup check-nodes
    ] when ;

: optimize-tree ( nodes -- nodes' )
    analyze-recursive
    normalize
    propagate
    cleanup
    dup run-escape-analysis? [
        escape-analysis
        unbox-tuples
    ] when
    apply-identities
    compute-def-use
    remove-dead-code
    ?check
    compute-def-use
    optimize-modular-arithmetic
    finalize ;
